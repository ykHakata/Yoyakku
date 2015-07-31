package Yoyakku::Model::Mainte;
use strict;
use warnings;
use utf8;
use Time::Piece;
use Time::Seconds;
use parent 'Yoyakku::Model';
use Yoyakku::Util qw{
    switch_header_params
    join_time
    split_time
    chenge_time_over
    previous_day_ymd
    split_date_time
};
use Yoyakku::Model::Master qw{$HOUR_00 $HOUR_06};

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
        acting => [qw{id general_id storeinfo_id status create_on modify_on}],
        ads    => [
            qw{id kind storeinfo_id region_id url displaystart_on
                displayend_on name event_date content create_on modify_on}
        ],
    };
    return $table_columns->{$table};
}

# 指定パラメーターの存在確認
sub check_table_column {
    my $self         = shift;
    my $check_params = shift;

    my $teng = $self->teng();

    my $column = $check_params->{column};
    my $param  = $check_params->{param};
    my $table  = $check_params->{table};
    my $id     = $check_params->{id};

    my $row = $teng->single( $table, +{ $column => $param, }, );

    # 新規
    return '既に利用されています' if $row && !$id;

    # 更新
    return '既に利用されています'
        if $row && $id && ( $id ne $row->id );

    return;
}

# ログイン名の重複確認
sub check_login_name {
    my $self   = shift;
    my $table  = shift;
    my $params = $self->params();

    my $login = $params->{login};
    my $id    = $params->{id};

    my $check_params = +{
        column => 'login',
        param  => $login,
        table  => $table,
        id     => $id,
    };

    return $self->check_table_column($check_params);
}

# update 用フィルインパラメーター作成
sub get_update_form_params {
    my $self   = shift;
    my $table  = shift;
    my $params = $self->params();

    my $columns = get_table_columns($table);
    my $row = $self->get_single_row_search_id( $table, $params->{id} );

    for my $param ( @{$columns} ) {
        $params->{$param} = $row->$param;
    }

    # roominfo のみ 開始、終了時刻はデータを調整する00->24表示にする
    if ( $table eq 'roominfo' ) {

        my $split_t = chenge_time_over(
            +{  start_time => $params->{starttime_on},
                end_time   => $params->{endingtime_on},
            }
        );

        ( $params->{starttime_on}, $params->{endingtime_on}, )
            = join_time($split_t, 'none');
    }

    # reserve のみ 日付変換
    if ( $table eq 'reserve' ) {
        my $day_and_time = get_startend_day_and_time($row);
        $params->{getstarted_on_day}  = $day_and_time->{getstarted_on_day};
        $params->{getstarted_on_time} = $day_and_time->{getstarted_on_time};
        $params->{enduse_on_day}      = $day_and_time->{enduse_on_day};
        $params->{enduse_on_time}     = $day_and_time->{enduse_on_time};
    }

    $self->params( $params );
    return $self;
}

# roominfo の開始時刻を入力フォーム用に変換
sub get_startend_day_and_time {
    my $reserve_row = shift;

    my $getstarted_on = $reserve_row->getstarted_on;
    my $enduse_on     = $reserve_row->enduse_on;

    my $split_dt = split_date_time( $getstarted_on, $enduse_on, );

    # 時間の表示を6:00-30:00
    my $split_t = chenge_time_over(
        +{  start_time => $split_dt->{start_time},
            end_time   => $split_dt->{end_time},
        }
    );

    # 24 - 30 の場合日付をもどす 時間の表示を変換
    if ( $split_t->{start_hour} >= 24 && $split_t->{start_hour} <= 30 ) {
        $split_dt->{start_date} = previous_day_ymd( $split_dt->{start_date} );
    }

    if ( $split_t->{end_hour} >= 24 && $split_t->{end_hour} <= 30 ) {
        $split_dt->{end_date} = previous_day_ymd( $split_dt->{end_date} );
    }

    ( $split_dt->{start_time}, $split_dt->{end_time}, )
        = join_time( $split_t, 'none' );

    my $startend_day_time = +{
        getstarted_on_day  => $split_dt->{start_date},
        getstarted_on_time => $split_dt->{start_time},
        enduse_on_day      => $split_dt->{end_date},
        enduse_on_time     => $split_dt->{end_time},
    };

    return $startend_day_time;
}

# レコード更新の為の情報取得
sub get_single_row_search_id {
    my $self      = shift;
    my $table     = shift;
    my $search_id = shift;

    my $teng = $self->teng();

    my $row = $teng->single( $table, +{ id => $search_id, }, );

    die 'not row!!' if !$row;

    return $row;
}

# テーブル一覧表示の為の検索
sub search_id_single_or_all_rows {
    my $self      = shift;
    my $table     = shift;
    my $search_id = shift;

    my $teng = $self->teng();

    my $search_column = 'id';

    if ( $table eq 'roominfo' ) {
        $search_column = 'storeinfo_id';
    }

    if ( $table eq 'post' ) {
        $search_column = 'post_id';
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

# ログイン確認、ヘッダー初期値取得
sub get_header_stash_auth_mainte {
    my $self    = shift;
    my $session = $self->session();
    return if !$session;
    my $id = $self->auth_mainte($session);
    return if !$id;
    return switch_stash_mainte_list( $id, 'root', );
}

# 管理者画面用のログイン確認
sub auth_mainte {
    my $self    = shift;
    my $session = shift;
    return if !$session;
    $session = $self->check_auth_db( $session, 'mainte' );
    return $session;
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
