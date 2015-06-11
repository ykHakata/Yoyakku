package Yoyakku::Model::Mainte::Reserve;
use strict;
use warnings;
use utf8;
use Time::Piece;
use Yoyakku::Model qw{$teng};
use Yoyakku::Util qw{now_datetime};
use Yoyakku::Model::Mainte qw{search_id_single_or_all_rows writing_db};
use Yoyakku::Model::Master qw{$HOUR_00 $HOUR_06};
use Exporter 'import';
our @EXPORT_OK = qw{
    search_reserve_id_rows
    get_general_rows_all
    get_admin_rows_all
    get_reserve_fillIn_values
    change_start_and_endtime
    change_format_datetime
    check_reserve_dupli
    writing_reserve
    search_reserve_id_row
    get_startend_day_and_time
    check_reserve_use_time
};
use Data::Dumper;

# 入力された利用希望時間の適正をチェック
sub check_reserve_use_time {
    my $getstarted_on_day  = shift;
    my $getstarted_on_time = shift;
    my $enduse_on_day      = shift;
    my $enduse_on_time     = shift;

    # datetime 形式の文字列に
    my $start_datetime = $getstarted_on_day . ' ' . $getstarted_on_time;
    my $end_datetime   = $enduse_on_day . ' ' . $enduse_on_time;

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
    my $getstarted_on_day  = shift;
    my $getstarted_on_time = shift;
    my $enduse_on_day      = shift;
    my $enduse_on_time     = shift;

    $getstarted_on_time = sprintf '%08s', $getstarted_on_time;
    $enduse_on_time     = sprintf '%08s', $enduse_on_time;

    my $change_format_datetime = +{
        getstarted_on => $getstarted_on_day . ' ' . $getstarted_on_time,
        enduse_on     => $enduse_on_day . ' ' . $enduse_on_time,
    };

    return $change_format_datetime;
}

# 予約の重複確認
sub check_reserve_dupli {
    my $type = shift;
    my $args = shift;

    my $reserve_id    = $args->{reserve_id};
    my $roominfo_id   = $args->{roominfo_id};
    my $getstarted_on = $args->{getstarted_on};
    my $enduse_on     = $args->{enduse_on};

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

sub get_startend_day_and_time {
    my $getstarted_on = shift;
    my $enduse_on     = shift;

    my $FIELD_SEPARATOR = q{ };
    my $FIELD_COUNT     = 2;

    my ( $getstarted_on_day, $getstarted_on_time ) = split $FIELD_SEPARATOR,
        $getstarted_on, $FIELD_COUNT + 1;

    my ( $enduse_on_day, $enduse_on_time ) = split $FIELD_SEPARATOR,
        $enduse_on, $FIELD_COUNT + 1;

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
    if ( $start_hour >= $HOUR_00 && $start_hour < $HOUR_06 ) {
        $start_hour += 24;
    }

    if ( $end_hour >= $HOUR_00 && $end_hour <= $HOUR_06 ) {
        $end_hour += 24;
    }

    $getstarted_on_time
        = $start_hour
        . $FIELD_SEPARATOR_TIME
        . $start_minute
        . $FIELD_SEPARATOR_TIME
        . $start_second;

    $enduse_on_time
        = $end_hour
        . $FIELD_SEPARATOR_TIME
        . $end_minute
        . $FIELD_SEPARATOR_TIME
        . $end_second;

    # 整形して出力
    my $startend_day_time = +{
        getstarted_on_day  => $getstarted_on_day,
        getstarted_on_time => $getstarted_on_time,
        enduse_on_day      => $enduse_on_day,
        enduse_on_time     => $enduse_on_time,
    };

    return $startend_day_time;
}

sub change_start_and_endtime {
    my $reserve_fillIn_values = shift;

    my $starttime_on  = $reserve_fillIn_values->starttime_on;
    my $endingtime_on = $reserve_fillIn_values->endingtime_on;

    my $FIELD_SEPARATOR = q{:};
    my $FIELD_COUNT     = 2;

    my ( $start_hour, $start_minute ) = split $FIELD_SEPARATOR,
        $starttime_on, $FIELD_COUNT + 1;

    my ( $end_hour, $end_minute ) = split $FIELD_SEPARATOR,
        $endingtime_on, $FIELD_COUNT + 1;

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

    my $change_start_and_endtime = +{
        start_hour => $start_hour,
        end_hour   => $end_hour,
    };

    return $change_start_and_endtime;
}

sub search_reserve_id_rows {
    my $reserve_id = shift;

    return search_id_single_or_all_rows( 'reserve', $reserve_id );
}

sub get_general_rows_all {
    my @rows = $teng->search('general', +{}, );

    return \@rows;
}

sub get_admin_rows_all {
    my @rows = $teng->search('admin', +{}, );

    return \@rows;
}

sub get_reserve_fillIn_values {
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

    my @reserve_fillIn_values = $teng->search_named( $sql, $bind_values );

    return $reserve_fillIn_values[0];
}


# sub search_zipcode_for_address {
#     my $self = shift;
#     my $post = shift;

#     my $address_params = +{
#         region_id => undef,
#         post      => $post,
#         state     => undef,
#         cities    => undef,
#     };

#     my $post_row = $teng->single( 'post', +{ post_id => $post }, );

#     if ($post_row) {
#         $address_params = +{
#             region_id => $post_row->region_id,
#             post      => $post_row->post,
#             state     => $post_row->state,
#             cities    => $post_row->cities,
#         };
#     }

#     return $address_params;
# }


sub search_reserve_id_row {
    my $reserve_id = shift;

    die 'not $reserve_id!!' if !$reserve_id;

    my $reserve_row
        = $teng->single( 'reserve', +{ id => $reserve_id, }, );

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
