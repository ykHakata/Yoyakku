package Yoyakku::Model::Mainte;
use strict;
use warnings;
use utf8;
use Time::Piece;
use Time::Seconds;
use FormValidator::Lite qw{Email URL DATE TIME};
use Yoyakku::Util qw{switch_header_params};
use Yoyakku::Model::Master qw{$HOUR_00 $HOUR_06};
use Yoyakku::Model qw{$teng};
use Exporter 'import';
our @EXPORT_OK = qw{
    switch_stash_mainte_list
    search_id_single_or_all_rows
    get_single_row_search_id
    writing_db
    get_update_form_params
    get_msg_validator
    check_login_name
    get_init_valid_params
    chenge_hour_6_for_30
    split_time
    join_time
};

# time 形式を組み立て
sub join_time {
    my $split_t = shift;

    my $FIELD_SEPARATOR_TIME = q{:};

    my $start_time = join $FIELD_SEPARATOR_TIME,
        $split_t->{start_hour},
        $split_t->{start_min},
        $split_t->{start_sec};

    my $end_time = join $FIELD_SEPARATOR_TIME,
        $split_t->{end_hour},
        $split_t->{end_min},
        $split_t->{end_sec};

    $start_time = sprintf '%08s', $start_time;
    $end_time   = sprintf '%08s', $end_time;

    return ( $start_time, $end_time, );
}

# time 形式を分解
sub split_time {
    my $start_time = shift;
    my $end_time   = shift;

    my $FIELD_SEPARATOR_TIME = q{:};
    my $FIELD_COUNT_TIME     = 3;

    my ( $start_hour, $start_min, $start_sec ) = split $FIELD_SEPARATOR_TIME,
        $start_time, $FIELD_COUNT_TIME + 1;

    my ( $end_hour, $end_min, $end_sec ) = split $FIELD_SEPARATOR_TIME,
        $end_time, $FIELD_COUNT_TIME + 1;

    return +{
        start_hour => $start_hour,
        start_min  => $start_min,
        start_sec  => $start_sec,
        end_hour   => $end_hour,
        end_min    => $end_min,
        end_sec    => $end_sec,
    };
}

# バリデート用パラメータ初期値
sub get_init_valid_params {
    my $valid_params = shift;

    my $valid_params_stash = +{};
    for my $param ( @{$valid_params} ) {
        $valid_params_stash->{$param} = '';
    }
    return $valid_params_stash;
}

# 各テーブルカラム取得
sub get_table_columns {
    my $table = shift;

    my $table_columns = +{
        admin   => [qw{id login password status create_on modify_on}],
        general => [qw{id login password status create_on modify_on}],
        profile => [
            qw{id general_id admin_id nick_name full_name
                phonetic_name tel mail status create_on modify_on}
        ],
        storeinfo => [
            qw{id region_id admin_id name icon post state cities addressbelow
                tel mail remarks url locationinfor status create_on modify_on}
        ],
        roominfo => [
            qw{id storeinfo_id name starttime_on endingtime_on rentalunit
                time_change pricescomments privatepermit privatepeople
                privateconditions bookinglimit cancellimit remarks
                webpublishing webreserve status create_on modify_on}
        ],
        reserve => [
            qw{id roominfo_id getstarted_on enduse_on useform message
                general_id admin_id tel status create_on modify_on}
        ],
    };
    return $table_columns->{$table};
}

# ログイン名の重複確認
sub check_login_name {
    my $params = shift;
    my $table  = shift;

    my $login = $params->{login};
    my $id    = $params->{id};

    my $row = $teng->single( $table, +{ login => $login, }, );

    # 新規
    return '既に利用されています' if $row && !$id;

    # 更新
    return '既に利用されています'
        if $row && $id && ( $id ne $row->id );

    return;
}

# 入力値バリデート処理
sub get_msg_validator {
    my $params       = shift;
    my $check_params = shift;
    my $msg_params   = shift;

    my $validator = FormValidator::Lite->new($params);

    $validator->check( @{$check_params} );
    $validator->set_message( @{$msg_params} );

    my $error_params = [ map {$_} keys %{ $validator->errors() } ];

    my $msg = +{};
    for my $error_param ( @{$error_params} ) {
        $msg->{$error_param}
            = $validator->get_error_messages_from_param($error_param);
        $msg->{$error_param} = shift @{ $msg->{$error_param} };
    }

    return $msg if $validator->has_error();
    return;
}
use Data::Dumper;
# update 用フィルインパラメーター作成
sub get_update_form_params {
    my $params  = shift;
    my $table   = shift;

    my $columns = get_table_columns($table);
    my $row = get_single_row_search_id( $table, $params->{id} );

    for my $param ( @{$columns} ) {
        $params->{$param} = $row->$param;
    }

    # roominfo のみ 開始、終了時刻はデータを調整する00->24表示にする
    if ( $table eq 'roominfo' ) {

        my ($start_hour, $start_minute, $start_second,
            $end_hour,   $end_minute,   $end_second,
            )
            = chenge_hour_6_for_30(
            $params->{starttime_on},
            $params->{endingtime_on},
            );

            $params->{starttime_on} = join ':', $start_hour, $start_minute,
                $start_second;
            $params->{endingtime_on} = join ':', $end_hour, $end_minute,
                $end_second;
    }

    # reserve のみ 日付変換
    if ( $table eq 'reserve' ) {
        my $day_and_time = get_startend_day_and_time($row);
        $params->{getstarted_on_day}  = $day_and_time->{getstarted_on_day};
        $params->{getstarted_on_time} = $day_and_time->{getstarted_on_time};
        $params->{enduse_on_day}      = $day_and_time->{enduse_on_day};
        $params->{enduse_on_time}     = $day_and_time->{enduse_on_time};
    }

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
    ) = chenge_hour_6_for_30( $getstarted_on_time, $enduse_on_time );

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

# chenge_hour_6_for_30 6:00 を 30:00
sub chenge_hour_6_for_30 {
    my $start_time = shift;
    my $end_time   = shift;

    my $split_t = split_time( $start_time, $end_time, );

    # 数字にもどす
    $split_t->{start_hour} += 0;
    $split_t->{end_hour}   += 0;

    # 時間の表示を変換
    if (   $split_t->{start_hour} >= $HOUR_00
        && $split_t->{start_hour} < $HOUR_06 )
    {
        $split_t->{start_hour} += 24;
    }

    if (   $split_t->{end_hour} >= $HOUR_00
        && $split_t->{end_hour} <= $HOUR_06 )
    {
        $split_t->{end_hour} += 24;
    }
    # die '$split_t',Dumper($split_t);
    return (
        $split_t->{start_hour}, $split_t->{start_min},
        $split_t->{start_sec},  $split_t->{end_hour},
        $split_t->{end_min},    $split_t->{end_sec},
    );
}

# データベースへの書き込み
sub writing_db {
    my $table     = shift;
    my $type      = shift;
    my $params    = shift;
    my $update_id = shift;

    my $insert_row;
    if ( $type eq 'insert' ) {
        $insert_row = $teng->insert( $table, $params, );
    }
    elsif ( $type eq 'update' ) {
        delete $params->{create_on};
        $insert_row = $teng->single( $table, +{ id => $update_id }, );
        $insert_row->update($params);
    }
    die 'not $insert_row' if !$insert_row;

    return $insert_row;
}

# レコード更新の為の情報取得
sub get_single_row_search_id {
    my $table     = shift;
    my $search_id = shift;

    my $row = $teng->single( $table, +{ id => $search_id, }, );

    die 'not row!!' if !$row;

    return $row;
}

# テーブル一覧表示の為の検索
sub search_id_single_or_all_rows {
    my $table     = shift;
    my $search_id = shift;

    my $search_column = 'id';

    if ( $table eq 'roominfo' ) {
        $search_column = 'storeinfo_id';
    }

    my @rows;

    if ( defined $search_id ) {
        @rows = $teng->search( $table, +{ $search_column => $search_id, }, );
        if ( !scalar @rows ) {

            # id 検索しないときはテーブルの全てを出力
            @rows = $teng->search( $table, +{}, );
        }
    }
    else {
        # id 検索しないときはテーブルの全てを出力
        @rows = $teng->search( $table, +{}, );
    }

    return \@rows;
}

# ログイン成功時に作成する初期値
sub switch_stash_mainte_list {
    my $id    = shift;
    my $table = shift;

    # id table ないとき強制終了
    die 'not id table!: ' if !$id || !$table;

    # ヘッダー表示用の名前
    my $login_name = $id;

    # ヘッダーの切替(システム管理者用)
    my $switch_header = 1;

    my $header_params = switch_header_params( $switch_header, $login_name );

    my $header_params_hash_ref = +{
        site_title_link        => $header_params->{site_title_link},
        header_heading_link    => $header_params->{header_heading_link},
        header_heading_name    => $header_params->{header_heading_name},
        header_navi_class_name => $header_params->{header_navi_class_name},
        header_navi_link_name  => $header_params->{header_navi_link_name},
        header_navi_row_name   => $header_params->{header_navi_row_name},
    };

    # Time::Piece オブジェクト
    my $today = localtime;

    my $stash_mainte = +{
        login_data => +{    # 初期値表示のため
            today => $today,    # アクセス時刻表示
        },
        %{$header_params_hash_ref},    # ヘッダー各値
    };

    return $stash_mainte;
}

1;

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model::Mainte - システム管理者用 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Mainte version 0.0.1

=head1 SYNOPSIS (概要)

Mainte コントローラーのロジック API

=head2 switch_stash_mainte_list

    use Yoyakku::Model::Mainte qw{switch_stash_mainte_list};

    # スタッシュに引き渡す値を作成
    my $stash_mainte = switch_stash_mainte_list( $id, $table, );

    $self->stash($stash_mainte);

Mainte アクションログイン時の初期値作成

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<Time::Piece>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
