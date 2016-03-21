package Yoyakku::Model::Mainte::Reserve;
use Mojo::Base 'Yoyakku::Model::Mainte::Base';
use Yoyakku::Util qw{split_time chenge_time_over};
use Yoyakku::Master qw{$HOUR_00 $HOUR_06};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Mainte::Reserve - reserve テーブル管理用 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Mainte::Reserve version 0.0.1

=head1 SYNOPSIS (概要)

    Reserve コントローラーのロジック API

=cut

sub get_input_support {
    my $self   = shift;
    my $params = shift;
    my $teng   = $self->teng();

    my $reserve_id  = $params->{id};
    my $roominfo_id = $params->{roominfo_id};

    if ( !$roominfo_id ) {
        my $reserve_row = $teng->single( 'reserve', +{ id => $reserve_id, }, );
        $roominfo_id = $reserve_row->roominfo_id;
    }

    my $reserve_fillIn_row = $self->_get_reserve_fillIn_row($roominfo_id);

    # 開始時刻表示切り替え 時間の表示を6:00-30:00
    my $change_start_and_endtime = chenge_time_over(
        +{  start_time => $reserve_fillIn_row->starttime_on,
            end_time   => $reserve_fillIn_row->endingtime_on,
        }
    );

    my @rows = $teng->search( 'general', +{}, );
    my $get_general_rows_all = \@rows;

    return +{
        reserve_fillIn_values => $reserve_fillIn_row,
        start_hour            => $change_start_and_endtime->{start_hour},
        end_hour              => $change_start_and_endtime->{end_hour},
        general_rows          => $get_general_rows_all,
    };
}

sub _get_reserve_fillIn_row {
    my $self        = shift;
    my $roominfo_id = shift;
    my $teng        = $self->teng();

    my $sql = q{
        SELECT
            roominfo.id AS roominfo_id,
            roominfo.name AS roominfo_name,
            storeinfo.name AS storeinfo_name,
            roominfo.time_change,
            roominfo.privatepermit,
            roominfo.starttime_on,
            roominfo.endingtime_on,
            admin.id AS admin_id,
            admin.login
        FROM roominfo
        INNER JOIN storeinfo
        ON roominfo.storeinfo_id = storeinfo.id
        INNER JOIN admin
        ON admin.id = storeinfo.admin_id
        WHERE roominfo.id = :roominfo_id
        AND roominfo.status = :roominfo_status
    };

    my $bind_values = +{
        roominfo_id     => $roominfo_id,
        roominfo_status => 1,
    };

    my @reserve_fillIn_rows = $teng->search_named( $sql, $bind_values );

    return $reserve_fillIn_rows[0];
}

=head2 check_reserve_validator_db

    DB 問い合わせバリデート

=cut

sub check_reserve_validator_db {
    my $self   = shift;
    my $params = shift;
    my $type   = shift;

    my $valid_msg_reserve_db = +{};

    # 予約の重複確認
    my $check_reserve_dupli = $self->_check_reserve_dupli( $type, $params, );

    if ($check_reserve_dupli) {
        $valid_msg_reserve_db = +{ id => $check_reserve_dupli, };
    }

    return $valid_msg_reserve_db if $check_reserve_dupli;

    # 部屋の利用開始と終了時刻の範囲内かを調べる
    my $check_roominfo_open_time = $self->_check_roominfo_open_time($params);

    if ($check_roominfo_open_time) {
        $valid_msg_reserve_db
            = +{ getstarted_on_time => $check_roominfo_open_time, };
    }

    return $valid_msg_reserve_db if $check_roominfo_open_time;

    # 入力された利用希望時間が貸出単位に適合しているか
    my $check_lend_unit = $self->_check_lend_unit($params);

    if ($check_lend_unit) {
        $valid_msg_reserve_db = +{ enduse_on_time => $check_lend_unit, };
    }

    return $valid_msg_reserve_db if $check_lend_unit;

    # 利用形態名バンド、個人練習、利用停止、許可が必要
    my $check_useform = $self->_check_useform($params);

    if ($check_useform) {
        $valid_msg_reserve_db = +{ useform => $check_useform, };
    }

    return $valid_msg_reserve_db if $check_useform;

    return;
}

=head2 _check_reserve_dupli

    予約の重複確認

=cut

sub _check_reserve_dupli {
    my $self   = shift;
    my $type   = shift;
    my $params = shift;

    my $teng = $self->teng();

    my $reserve_id    = $params->{id};
    my $roominfo_id   = $params->{roominfo_id};
    my $getstarted_on = $params->{getstarted_on};
    my $enduse_on     = $params->{enduse_on};

    my $search_condition = +{
        roominfo_id   => $roominfo_id,
        status        => 0,
        getstarted_on => [ +{ '>=' => $getstarted_on }, ],
        enduse_on     => [ +{ '<=' => $enduse_on }, ],
    };

    if ( $type eq 'update' ) {
        $search_condition->{id} = +{ '!=' => $reserve_id };
    }

    my $reserve_row = $teng->single( 'reserve', $search_condition, );

    return '既に予約が存在します' if $reserve_row;

    return;
}

=head2 _check_roominfo_open_time

    部屋の利用開始と終了時刻の範囲内かを調べる

=cut

sub _check_roominfo_open_time {
    my $self   = shift;
    my $params = shift;

    my $teng = $self->teng();

    # 予約希望した roominfo を取得し、営業時間を調べる
    my $roominfo_row
        = $teng->single( 'roominfo', +{ id => $params->{roominfo_id} }, );

    # 比較するため、両方を6:00-29:00の表記
    # roominfo -> reserve 入力
    my $change_start_and_endtime = chenge_time_over(
        +{  start_time => $roominfo_row->starttime_on,
            end_time   => $roominfo_row->endingtime_on,
        },
    );

    # reserve 入力(そのままの)
    my $split_t = split_time(
        $params->{getstarted_on_time},
        $params->{enduse_on_time},
    );

    # 入力した値の方が早い(少ない)場合エラーメッセージ
    if ( $split_t->{start_hour} < $change_start_and_endtime->{start_hour} ) {
        return '営業時間外です';
    }

    if ( $split_t->{end_hour} > $change_start_and_endtime->{end_hour} ) {
        return '営業時間外です';
    }

    return;
}

=head2 _check_lend_unit

    入力された利用希望時間が貸出単位に適合しているか

=cut

sub _check_lend_unit {
    my $self   = shift;
    my $params = shift;

    my $teng = $self->teng();

    # 予約希望した roominfo を取得し、貸出単位を調べる
    my $roominfo_row
        = $teng->single( 'roominfo', +{ id => $params->{roominfo_id} }, );

    # rentalunit:INTEGER(例: 1: 1時間, 2: 2時間)貸出単位
    my $rentalunit = $roominfo_row->{rentalunit};

    # reserve 入力(そのままの)
    my $split_t = split_time(
        $params->{getstarted_on_time},
        $params->{enduse_on_time},
    );

    # 希望している時間
    my $lend_time = $split_t->{end_hour} - $split_t->{start_hour};

    if ( $lend_time % 2 ) {
        return '2時間単位でしか予約できません';
    }

    return;
}

=head2 _check_useform

    利用形態名 useform->バンド、個人練習、利用停止、いずれも許可が必要

=cut

sub _check_useform {
    my $self   = shift;
    my $params = shift;

    my $teng = $self->teng();

    # 予約希望したroominfoを取得し、利用形態名調査
    my $roominfo_row
        = $teng->single( 'roominfo', +{ id => $params->{roominfo_id} }, );

    # privatepermit:(0: 許可する, 1: 許可しない)個人練習許可
    $roominfo_row->privatepermit;

    # reserve 入力 0:バンド, 1:個人, 2:利用停止
    my $useform = $params->{useform};

    if ( ( $useform eq 1 ) && ( $roominfo_row->privatepermit && 1 ) ) {
        return '個人練習が許可されてない';
    }

    # 一般ユーザー選択時、利用停止選択不可
    my $general_id = $params->{general_id};

    if ( ( $useform eq 2 ) && $general_id ) {
        return '一般ユーザーは利用できない';
    }

    return;
}

=head2 writing_reserve

    reserve テーブル書込み、修正に対応

=cut

sub writing_reserve {
    my $self   = shift;
    my $params = shift;
    my $type   = shift;

    my $create_data = $self->get_create_data( 'reserve', $params );

    my $args = +{
        table       => 'reserve',
        create_data => $create_data,
        update_id   => $params->{id},
        type        => $type,
    };

    return $self->writing_from_db($args);
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::Model::Mainte>

=item * L<Yoyakku::Util>

=item * L<Yoyakku::Master>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
