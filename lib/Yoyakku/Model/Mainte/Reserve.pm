package Yoyakku::Model::Mainte::Reserve;
use strict;
use warnings;
use utf8;
use Time::Piece;
use Time::Seconds;
use FormValidator::Lite qw{DATE TIME};
use Yoyakku::Model qw{$teng};
use Yoyakku::Util qw{now_datetime};
use Yoyakku::Model::Mainte qw{search_id_single_or_all_rows writing_db};
use Yoyakku::Model::Master qw{$HOUR_00 $HOUR_06};
use Exporter 'import';
our @EXPORT_OK = qw{
    search_reserve_id_rows
    change_format_datetime
    writing_reserve
    search_reserve_id_row
    get_startend_day_and_time
    get_init_valid_params_reserve
    get_input_support
    check_reserve_validator
    check_reserve_validator_db
};
use Data::Dumper;

# _chenge_hour_6_for_30 6:00 を 30:00
sub _chenge_hour_6_for_30 {
    my $start_time = shift;
    my $end_time   = shift;

    my $FIELD_SEPARATOR_TIME = q{:};
    my $FIELD_COUNT_TIME     = 3;

    my ( $start_hour, $start_min, $start_sec ) = split $FIELD_SEPARATOR_TIME,
        $start_time, $FIELD_COUNT_TIME + 1;

    my ( $end_hour, $end_min, $end_sec ) = split $FIELD_SEPARATOR_TIME,
        $end_time, $FIELD_COUNT_TIME + 1;

    # 数字にもどす
    $start_hour += 0;
    $end_hour   += 0;

    # 時間の表示を変換
    if ( $start_hour >= $HOUR_00 && $start_hour < $HOUR_06 ) {
        $start_hour += 24;
    }

    if ( $end_hour >= $HOUR_00 && $end_hour <= $HOUR_06 ) {
        $end_hour += 24;
    }

    return (
        $start_hour, $start_min, $start_sec,
        $end_hour,   $end_min,   $end_sec,
    );
}

# DB 問い合わせバリデート
sub check_reserve_validator_db {
    my $type   = shift;
    my $params = shift;

    my $valid_msg_reserve_db = +{};

    # 予約の重複確認
    my $check_reserve_dupli = _check_reserve_dupli( $type, $params, );

    if ($check_reserve_dupli) {
        $valid_msg_reserve_db = +{ id => $check_reserve_dupli, };
    }

    return $valid_msg_reserve_db if $check_reserve_dupli;

    # 部屋の利用開始と終了時刻の範囲内かを調べる
    my $check_roominfo_open_time = _check_roominfo_open_time($params);

    if ($check_roominfo_open_time) {
        $valid_msg_reserve_db
            = +{ getstarted_on_time => $check_roominfo_open_time, };
    }

    return $valid_msg_reserve_db if $check_roominfo_open_time;

    # 入力された利用希望時間が貸出単位に適合しているか
    my $check_lend_unit = _check_lend_unit($params);

    if ($check_lend_unit) {
        $valid_msg_reserve_db = +{ enduse_on_time => $check_lend_unit, };
    }

    return $valid_msg_reserve_db if $check_lend_unit;

# 利用形態名 useform->バンド、個人練習、利用停止、いずれも許可が必要
    my $check_useform = _check_useform($params);

    if ($check_useform) {
        $valid_msg_reserve_db = +{ useform => $check_useform, };
    }

    return $valid_msg_reserve_db if $check_useform;

    return;
}

# 利用形態名 useform->バンド、個人練習、利用停止、いずれも許可が必要
sub _check_useform {
    my $params = shift;

# 予約希望した roominfo を取得し、利用形態名 useformを調べる
    my $roominfo_row
        = $teng->single( 'roominfo', +{ id => $params->{roominfo_id} }, );

# privatepermit:  INTEGER (例: 0: 許可する, 1: 許可しない) 個人練習許可
    $roominfo_row->privatepermit;

    # reserve 入力 # 0:バンド, 1:個人, 2:利用停止
    my $useform = $params->{useform};

    if ( ( $useform eq 1 ) && ( $roominfo_row->privatepermit && 1 ) ) {
        return '個人練習が許可されてない';
    }

# 一般ユーザーが選択されてる時に利用停止->2が選択されてはいけない
    my $general_id = $params->{general_id};

    if ( ( $useform eq 2 ) && $general_id ) {
        return '一般ユーザーは利用できない';
    }

    return;
}

# 入力された利用希望時間が貸出単位に適合しているか
sub _check_lend_unit {
    my $params = shift;

    # 予約希望した roominfo を取得し、貸出単位を調べる
    my $roominfo_row
        = $teng->single( 'roominfo', +{ id => $params->{roominfo_id} }, );

# 貸出単位 rentalunit:     INTEGER (例: 1: 1時間, 2: 2時間) 貸出単位
    my $rentalunit = $roominfo_row->{rentalunit};

    # reserve 入力(そのままの)
    my $getstarted_on_time = $params->{getstarted_on_time};
    my $enduse_on_time     = $params->{enduse_on_time};

    my $FIELD_SEPARATOR = q{:};
    my $FIELD_COUNT     = 2;

    my ( $start_hour, $start_minute ) = split $FIELD_SEPARATOR,
        $getstarted_on_time, $FIELD_COUNT + 1;

    my ( $end_hour, $end_minute ) = split $FIELD_SEPARATOR,
        $enduse_on_time, $FIELD_COUNT + 1;

    # 希望している時間
    my $lend_time = $end_hour - $start_hour;

    if ( $lend_time % 2 ) {
        return '2時間単位でしか予約できません';
    }

    return;
}

# 部屋の利用開始と終了時刻の範囲内かを調べる
sub _check_roominfo_open_time {
    my $params = shift;

    # 予約希望した roominfo を取得し、営業時間を調べる
    my $roominfo_row
        = $teng->single( 'roominfo', +{ id => $params->{roominfo_id} }, );

    # roominfo に登録してある設定時間
    $roominfo_row->starttime_on;

    # 比較するため、両方を6:00-29:00の表記

    # roominfo -> reserve 入力
    my $change_start_and_endtime = _change_start_and_endtime($roominfo_row);

    # reserve 入力(そのままの)
    my $getstarted_on_time = $params->{getstarted_on_time};
    my $enduse_on_time     = $params->{enduse_on_time};

    my $FIELD_SEPARATOR = q{:};
    my $FIELD_COUNT     = 2;

    my ( $start_hour, $start_minute ) = split $FIELD_SEPARATOR,
        $getstarted_on_time, $FIELD_COUNT + 1;

    my ( $end_hour, $end_minute ) = split $FIELD_SEPARATOR,
        $enduse_on_time, $FIELD_COUNT + 1;

    # 入力した値の方が早い(少ない)場合エラーメッセージ
    if ( $start_hour < $change_start_and_endtime->{start_hour} ) {
        return '営業時間外です';
    }

    if ( $end_hour > $change_start_and_endtime->{end_hour} ) {
        return '営業時間外です';
    }

    return;
}

# 予約の重複確認
sub _check_reserve_dupli {
    my $type   = shift;
    my $params = shift;

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

# 入力補助の値取得
sub get_input_support {
    my $reserve_id  = shift;
    my $roominfo_id = shift;

    if ( !$roominfo_id ) {
        my $reserve_row = search_reserve_id_row($reserve_id);
        $roominfo_id = $reserve_row->roominfo_id;
    }

    my $reserve_fillIn_row = _get_reserve_fillIn_row($roominfo_id);

    # 開始時刻表示切り替え
    my $change_start_and_endtime
        = _change_start_and_endtime($reserve_fillIn_row);

    my @rows = $teng->search( 'general', +{}, );
    my $get_general_rows_all = \@rows;

    return +{
        reserve_fillIn_values => $reserve_fillIn_row,
        start_hour            => $change_start_and_endtime->{start_hour},
        end_hour              => $change_start_and_endtime->{end_hour},
        general_rows          => $get_general_rows_all,
    };
}

# roominfo の開始時刻、入力補完で使用する時用に変更
sub _change_start_and_endtime {
    my $reserve_fillIn_row = shift;

    my $starttime_on  = $reserve_fillIn_row->starttime_on;
    my $endingtime_on = $reserve_fillIn_row->endingtime_on;

    # 時間の表示を6:00-30:00
    my ($start_hour, $start_minute, $start_second,
        $end_hour,   $end_minute,   $end_second,
    ) = _chenge_hour_6_for_30( $starttime_on, $endingtime_on );

    my $change_start_and_endtime = +{
        start_hour => $start_hour,
        end_hour   => $end_hour,
    };

    return $change_start_and_endtime;
}

# 入力フォームの補助値取得、値は該当する roominfo, storeinfo, admin
sub _get_reserve_fillIn_row {
    my $roominfo_id = shift;

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

# バリデートエラー表示値の初期化
sub get_init_valid_params_reserve {

    my $valid_params = [
        qw{
            id
            roominfo_id
            getstarted_on_day
            getstarted_on_time
            enduse_on_day
            enduse_on_time
            useform
            message
            general_id
            admin_id
            tel
            status
            }
    ];

    my $valid_params_stash = +{};

    for my $param ( @{$valid_params} ) {
        $valid_params_stash->{$param} = '';
    }

    return $valid_params_stash;
}

# バリデート一式
sub check_reserve_validator {
    my $params = shift;

    my $validator = FormValidator::Lite->new($params);

    $validator->check(
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
    );

    $validator->set_message(
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
    );

    my $error_params = [ map {$_} keys %{ $validator->errors() } ];

    my $msg = +{};
    for my $error_param ( @{$error_params} ) {
        $msg->{$error_param}
            = $validator->get_error_messages_from_param($error_param);

        $msg->{$error_param} = shift @{ $msg->{$error_param} };
    }

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

    return $valid_msg_reserve if $validator->has_error();

    # 日付の計算をするために通常の日時の表記に変更
    $params = change_format_datetime($params);

# 入力された利用終了時刻が開始時刻より早くなっていないか？(入力値チェック)
    my $check_reserve_use_time = _check_reserve_use_time($params);

    $valid_msg_reserve->{enduse_on_time} = $check_reserve_use_time,

        return $valid_msg_reserve if $check_reserve_use_time;

    return;
}

# 入力された利用希望時間の適正をチェック
sub _check_reserve_use_time {
    my $params = shift;

    my $start_datetime = $params->{getstarted_on};
    my $end_datetime   = $params->{enduse_on};

    # 日付のオブジェクトに変換
    my $start_tp = localtime->strptime( $start_datetime, '%Y-%m-%d %T' );
    my $end_tp   = localtime->strptime( $end_datetime,   '%Y-%m-%d %T' );

    # 日付のオブジェクトで比較
    return '開始時刻より遅くして下さい' if $start_tp >= $end_tp;

    # 不合格時はメッセージ、合格時は undef
    return;
}

# 日付と時刻に分かれたものを datetime 形式にもどす
sub change_format_datetime {
    my $params = shift;

    my $getstarted_on_day  = $params->{getstarted_on_day};
    my $getstarted_on_time = $params->{getstarted_on_time};
    my $enduse_on_day      = $params->{enduse_on_day};
    my $enduse_on_time     = $params->{enduse_on_time};

    # time 24:00 ~ 30:30 までの表示の場合 0:00 ~ 06:30 用に変換
    # 日付を一日進めておく
    my $FIELD_SEPARATOR_TIME = q{:};
    my $FIELD_COUNT_TIME     = 3;

    my ( $start_hour, $start_minute, $start_second, )
        = split $FIELD_SEPARATOR_TIME, $getstarted_on_time,
        $FIELD_COUNT_TIME + 1;

    my ( $end_hour, $end_minute, $end_second, ) = split $FIELD_SEPARATOR_TIME,
        $enduse_on_time, $FIELD_COUNT_TIME + 1;

    # 数字にもどす
    $start_hour += 0;
    $end_hour   += 0;

    # 時間の表示を変換
    if ( $start_hour >= 24 && $start_hour <= 30 ) {
        $start_hour -= 24;

        # 日付を１日すすめる
        my $getstarted_on_day_tp
            = localtime->strptime( $getstarted_on_day, '%Y-%m-%d' );
        $getstarted_on_day_tp = $getstarted_on_day_tp + ONE_DAY;
        $getstarted_on_day    = $getstarted_on_day_tp->ymd;
    }

    if ( $end_hour >= 24 && $end_hour <= 30 ) {
        $end_hour -= 24;

        # 日付を１日すすめる
        my $enduse_on_day_tp
            = localtime->strptime( $enduse_on_day, '%Y-%m-%d' );
        $enduse_on_day_tp = $enduse_on_day_tp + ONE_DAY;
        $enduse_on_day    = $enduse_on_day_tp->ymd;
    }

    $getstarted_on_time = join ':', $start_hour, $start_minute, $start_second;
    $enduse_on_time     = join ':', $end_hour,   $end_minute,   $end_second;

    $getstarted_on_time = sprintf '%08s', $getstarted_on_time;
    $enduse_on_time     = sprintf '%08s', $enduse_on_time;

    my $change_format_datetime = +{
        getstarted_on => $getstarted_on_day . ' ' . $getstarted_on_time,
        enduse_on     => $enduse_on_day . ' ' . $enduse_on_time,
    };

    $params->{getstarted_on} = $change_format_datetime->{getstarted_on};
    $params->{enduse_on}     = $change_format_datetime->{enduse_on};

    return $params;
}

# roominfo の開始時刻を入力フォーム用に変換
sub get_startend_day_and_time {
    my $reserve_row = shift;

    my $getstarted_on = $reserve_row->getstarted_on;
    my $enduse_on     = $reserve_row->enduse_on;

    my $FIELD_SEPARATOR = q{ };
    my $FIELD_COUNT     = 2;

    my ( $getstarted_on_day, $getstarted_on_time ) = split $FIELD_SEPARATOR,
        $getstarted_on, $FIELD_COUNT + 1;

    my ( $enduse_on_day, $enduse_on_time ) = split $FIELD_SEPARATOR,
        $enduse_on, $FIELD_COUNT + 1;

    # 時間の表示を6:00-30:00
    my ($start_hour, $start_minute, $start_second,
        $end_hour,   $end_minute,   $end_second,
    ) = _chenge_hour_6_for_30( $getstarted_on_time, $enduse_on_time );

    # 24 - 30 の場合日付をもどす 時間の表示を変換
    if ( $start_hour >= 24 && $start_hour <= 30 ) {
        my $getstarted_on_day_tp
            = localtime->strptime( $getstarted_on_day, '%Y-%m-%d' );
        $getstarted_on_day_tp = $getstarted_on_day_tp - ONE_DAY;
        $getstarted_on_day    = $getstarted_on_day_tp->ymd;
    }

    if ( $end_hour >= 24 && $end_hour <= 30 ) {
        my $enduse_on_day_tp
            = localtime->strptime( $enduse_on_day, '%Y-%m-%d' );
        $enduse_on_day_tp = $enduse_on_day_tp - ONE_DAY;
        $enduse_on_day    = $enduse_on_day_tp->ymd;
    }

    $getstarted_on_time = join ':', $start_hour, $start_minute, $start_second;
    $enduse_on_time     = join ':', $end_hour,   $end_minute,   $end_second;

    # 整形して出力
    my $startend_day_time = +{
        getstarted_on_day  => $getstarted_on_day,
        getstarted_on_time => $getstarted_on_time,
        enduse_on_day      => $enduse_on_day,
        enduse_on_time     => $enduse_on_time,
    };

    return $startend_day_time;
}

# reserve 一覧取得
sub search_reserve_id_rows {
    my $reserve_id = shift;

    return search_id_single_or_all_rows( 'reserve', $reserve_id );
}

sub search_reserve_id_row {
    my $reserve_id = shift;

    die 'not $reserve_id!!' if !$reserve_id;

    my $reserve_row = $teng->single( 'reserve', +{ id => $reserve_id, }, );

    die 'not $reserve_row!!' if !$reserve_row;

    return $reserve_row;
}

sub writing_reserve {
    my $type   = shift;
    my $params = shift;

    my $create_data = +{
        roominfo_id   => $params->{roominfo_id},
        getstarted_on => $params->{getstarted_on},
        enduse_on     => $params->{enduse_on},
        useform       => $params->{useform},
        message       => $params->{message},
        general_id    => $params->{general_id},
        admin_id      => $params->{admin_id},
        tel           => $params->{tel},
        status        => $params->{status},
        create_on     => now_datetime(),
        modify_on     => now_datetime(),
    };

    return writing_db( 'reserve', $type, $create_data, $params->{id} );
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
