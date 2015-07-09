package Yoyakku::Model::Mainte::Reserve;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model::Mainte';
use Yoyakku::Util qw{
    now_datetime
    join_time
    split_time
    chenge_time_over
    next_day_ymd
    join_date_time
    get_start_end_tp
    get_fill_in_params
};
use Yoyakku::Model::Master qw{$HOUR_00 $HOUR_06};

sub search_reserve_id_rows {
    my $self = shift;
    return $self->search_id_single_or_all_rows( 'reserve',
        $self->params()->{reserve_id} );
}

sub get_init_valid_params_reserve {
    my $self = shift;
    return $self->get_init_valid_params(
        [   qw{id roominfo_id getstarted_on_day getstarted_on_time enduse_on_day
                enduse_on_time useform message general_id admin_id tel status}
        ]
    );
}

sub get_input_support {
    my $self   = shift;
    my $params = $self->params();
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

# 日付と時刻に分かれたものを datetime 形式にもどす
sub change_format_datetime {
    my $self   = shift;
    my $params = $self->params();

    my $start_date = $params->{getstarted_on_day};
    my $start_time = $params->{getstarted_on_time};
    my $end_date   = $params->{enduse_on_day};
    my $end_time   = $params->{enduse_on_time};

    # time 24:00 ~ 30:30 までの表示の場合 0:00 ~ 06:30 用に変換
    # 時間の表示を24:00表記にもどす
    my $split_t = chenge_time_over(
        +{ start_time => $start_time, end_time => $end_time, }, 'normal', );

    # 時間の表示を変換 日付を１日進める
    if ( $split_t->{start_hour} >= 0 && $split_t->{start_hour} < 6 ) {
        $start_date = next_day_ymd( $start_date );
    }

    if ( $split_t->{end_hour} >= 0 && $split_t->{end_hour} <= 6 ) {
        $end_date = next_day_ymd( $end_date );
    }

    ( $start_time, $end_time, ) = join_time($split_t);

    ( $params->{getstarted_on}, $params->{enduse_on}, ) = join_date_time(
        +{  start_date => $start_date,
            start_time => $start_time,
            end_date   => $end_date,
            end_time   => $end_time,
        },
    );

    return $params;
}

sub get_update_form_params_reserve {
    my $self = shift;
    $self->get_update_form_params('reserve');
    return $self;
}

sub check_reserve_validator {
    my $self   = shift;
    my $params = $self->params();

    my $check_params = [
        roominfo_id        => [ 'INT', ],
        getstarted_on_day  => [ 'NOT_NULL', 'DATE', ],
        enduse_on_day      => [ 'NOT_NULL', 'DATE', ],
        getstarted_on_time => [ 'NOT_NULL', ],
        enduse_on_time     => [ 'NOT_NULL', ],
        +{ on_day => [ 'getstarted_on_day', 'enduse_on_day', ], } =>
            ['DUPLICATION'],
        useform    => [ 'INT', ],
        message    => [ [ 'LENGTH', 0, 20, ], ],
        general_id => [ 'INT', ],
        admin_id   => [ 'INT', ],
        tel        => [ 'NOT_NULL', [ 'LENGTH', 0, 20, ], ],
        status     => [ 'INT', ],
    ];

    my $msg_params = [
        'roominfo_id.int' => '指定の形式で入力してください',
        'getstarted_on_day.not_null' => '必須入力',
        'enduse_on_day.not_null'     => '必須入力',
        'getstarted_on_day.date' =>
            '日付の形式で入力してください',
        'enduse_on_day.date' => '日付の形式で入力してください',
        'on_day.duplication' => '開始と同じ日付にして下さい',
        'useform.int'        => '指定の形式で入力してください',
        'message.length'     => '文字数!!',
        'general_id.int'     => '指定の形式で入力してください',
        'admin_id.int'       => '指定の形式で入力してください',
        'tel.not_null'       => '必須入力',
        'tel.length'         => '文字数!!',
        'status.int'         => '指定の形式で入力してください',
    ];

    my $msg = $self->get_msg_validator( $check_params, $msg_params, );

    my $valid_msg_reserve = +{
        id                 => '',
        roominfo_id        => $msg->{roominfo_id},
        getstarted_on_day  => $msg->{getstarted_on_day},
        getstarted_on_time => $msg->{getstarted_on_time},
        enduse_on_day      => $msg->{enduse_on_day} || $msg->{on_day},
        enduse_on_time     => $msg->{enduse_on_time},
        useform            => $msg->{useform},
        message            => $msg->{message},
        general_id         => $msg->{general_id},
        admin_id           => $msg->{admin_id},
        tel                => $msg->{tel},
        status             => $msg->{status},
    };

    return $valid_msg_reserve if scalar values %{$msg};

    # 日付の計算をするために通常の日時の表記に変更
    $params = $self->change_format_datetime();

    # 利用終了時刻が開始時刻より早くなっていないか？
    my $check_reserve_use_time = _check_reserve_use_time($params);

    $valid_msg_reserve->{enduse_on_time} = $check_reserve_use_time;

    return $valid_msg_reserve if $check_reserve_use_time;

    return;
}

# 入力された利用希望時間の適正をチェック
sub _check_reserve_use_time {
    my $params = shift;

    my $start_date_time = $params->{getstarted_on};
    my $end_date_time   = $params->{enduse_on};

    # 日付のオブジェクトに変換
    my ( $start_tp, $end_tp, )
        = get_start_end_tp( $start_date_time, $end_date_time, );

    # 日付のオブジェクトで比較
    return '開始時刻より遅くして下さい' if $start_tp >= $end_tp;

    # 不合格時はメッセージ、合格時は undef
    return;
}

# DB 問い合わせバリデート
sub check_reserve_validator_db {
    my $self   = shift;
    my $type   = $self->type();
    my $params = $self->params();

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

# 予約の重複確認
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

# 部屋の利用開始と終了時刻の範囲内かを調べる
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

# 入力された利用希望時間が貸出単位に適合しているか
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

# 利用形態名 useform->バンド、個人練習、利用停止、いずれも許可が必要
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

sub writing_reserve {
    my $self = shift;

    my $create_data = +{
        roominfo_id   => $self->params()->{roominfo_id},
        getstarted_on => $self->params()->{getstarted_on},
        enduse_on     => $self->params()->{enduse_on},
        useform       => $self->params()->{useform},
        message       => $self->params()->{message},
        general_id    => $self->params()->{general_id},
        admin_id      => $self->params()->{admin_id},
        tel           => $self->params()->{tel},
        status        => $self->params()->{status},
        create_on     => now_datetime(),
        modify_on     => now_datetime(),
    };
    return $self->writing_db( 'reserve', $create_data,
        $self->params()->{id} );
}

sub get_fill_in_reserve {
    my $self   = shift;
    my $html   = $self->html();
    my $params = $self->params();
    my $output = get_fill_in_params( $html, $params );
    return $output;
}

1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model::Mainte::Reserve - reserve テーブル管理用 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Mainte::Reserve version 0.0.1

=head1 SYNOPSIS (概要)

Reserve コントローラーのロジック API

=head2 search_zipcode_for_address

    use Yoyakku::Model::Mainte::Reserve qw{search_zipcode_for_address};

    # 郵便番号から住所検索のアクション時
    if ( $params->{kensaku} && $params->{kensaku} eq '検索する' ) {

        my $address_params
            = $self->search_zipcode_for_address( $params->{post} );

        $params->{region_id} = $address_params->{region_id};
        $params->{post}      = $address_params->{post};
        $params->{state}     = $address_params->{state};
        $params->{cities}    = $address_params->{cities};

        return $self->_render_reserve($params);
    }

    # 該当の住所なき場合、各項目は undef を返却

郵便番号から住所を検索、値を返却

=head2 search_reserve_id_rows

    use Yoyakku::Model::Mainte::Reserve qw{search_reserve_id_rows};

    # 指定の id に該当するレコードを row オブジェクトを配列リファレンスで返却
    my $reserve_rows = $self->search_reserve_id_rows($reserve_id);

    # 指定の id に該当するレコードなき場合 reserve 全てのレコード返却

reserve テーブル一覧作成時に利用

=head2 search_reserve_id_row

    use Yoyakku::Model::Mainte::Reserve qw{search_reserve_id_row};

    # 指定の id に該当するレコードを row オブジェクト単体で返却
    my $reserve_row = $self->search_reserve_id_row( $params->{id} );

    # 指定の id に該当するレコードなき場合エラー発生

reserve テーブル修正フォーム表示などに利用

=head2 writing_reserve

    use Yoyakku::Model::Mainte::Reserve qw{writing_reserve};

    # reserve テーブルレコード修正時
    $self->writing_reserve( 'update', $params );
    $self->flash( henkou => '修正完了' );

reserve テーブル書込み、修正に対応

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<Yoyakku::Model>

=item * L<Yoyakku::Util>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
