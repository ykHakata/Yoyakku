package Yoyakku::Model::Management::Reserve;
use Mojo::Base 'Yoyakku::Model::Management::Base';
use Yoyakku::Util::Time qw{
    tp_from_datetime_over24
    tp_now_over24
    tp_next_month_after
    parse_datetime
};
use Mojo::Util qw{dumper};
=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Management::Reserve - 店舗管理 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Management::Reserve version 0.0.1

=head1 SYNOPSIS (概要)

    Management::Reserve コントローラーのロジック API

=cut

my $YOYAKKU_TIME = '06:00:00';

=head2 cond_input_form

    入力フォーム切替の為の値取得

=cut

sub cond_input_form {
    my $self = shift;
    my $c    = $self->app->build_controller;

    my $cond_input = +{
        cancel_conf  => undef,
        switch_input => undef,
    };

    # 予約取消が押されたときのスクリプト
    if ( $c->param('res_cancel') ) {
        $cond_input->{cancel_conf} = 1;
        return $cond_input;
    }

    if ( $c->param('reserve_id') ) {
        $cond_input->{switch_input} = 1;
        return $cond_input;
    }

    if ( $c->param('new_res_room_id') ) {
        $cond_input->{switch_input} = 2;
        return $cond_input;
    }

    $cond_input->{switch_input} = 0;
    return $cond_input;
}

=head2 get_timeout_room

    現在時刻が予約の時間枠をすぎた場合予約不可 (本日の場合のみ)

    # $timeout_room = +{
    #     "timeout_10_10" => "timeout",
    #     "timeout_10_11" => "timeout",
    #     ...
    # };

=cut

sub get_timeout_room {
    my $self        = shift;
    my $login_row   = shift;
    my $select_date = shift;

    my $timeout_room = +{};

    # 現在時刻を取得
    my $tp_now_over24  = tp_now_over24($YOYAKKU_TIME);
    my $parse_datetime = parse_datetime( $tp_now_over24->over24_datetime );

    # 現在時刻と選択されている予約表の日程が同じ場合のみ
    return if ( $select_date->date ne $parse_datetime->{date} );

    my $roominfo_ids = $login_row->fetch_storeinfo->get_roominfo_ids();
    my $time_over    = $tp_now_over24->over24_hour;

    for my $roominfo_id ( @{$roominfo_ids} ) {
        for my $hour ( 6 .. 29 ) {
            next if ( $hour >= $time_over );
            my $key = join '_', 'timeout', $roominfo_id, $hour;
            $timeout_room->{$key} = 'timeout';
        }
    }
    return $timeout_room;
}

=head2 get_outside_room

    利用停止になっている部屋を特定

    # $outside_room = +{
    #     "outside_2_10" => "outside",
    #     "outside_2_11" => "outside",
    #     ...
    # };

=cut

sub get_outside_room {
    my $self      = shift;
    my $login_row = shift;

    # 利用停止になっている部屋はすべての時間をステータスoutside
    my $args = +{ status => 0, };

    my $roominfo_rows = $login_row->fetch_storeinfo->search_roominfos($args);
    my $outside_room  = +{};

    for my $roominfo_row ( @{$roominfo_rows} ) {
        for my $hour ( 6 .. 29 ) {
            my $id = $roominfo_row->id;
            my $key = join '_', 'outside', $id, $hour;
            $outside_room->{$key} = 'outside';
        }
    }
    return $outside_room;
}

=head2 get_reserve_history

    管理者予約履歴のための値を取得

=cut

sub get_reserve_history {
    my $self      = shift;
    my $login_row = shift;

    # 現在時刻を取得
    my $tp_now_over24 = tp_now_over24($YOYAKKU_TIME);

    # 今月、１ヶ月後、２ヶ月後、３ヶ月後
    my $month = [qw{now next1 next2 next3}];

    # 検索条件から実行、検索結果まとめ
    my $history = +{};
    my $args = +{
        tp        => $tp_now_over24,
        after     => 0,
        login_row => $login_row,
    };

    for my $mon ( @{$month} ) {
        my $reserves = $self->_get_fetch_reserves($args);

        # コントローラーに送り込む形式にまとめ
        $history->{$mon} = +{
            reserve => $reserves->{reserve},
            year    => $reserves->{year},
            mon     => $reserves->{mon},
        };
        $args->{after} += 1;
    }
    return $history;
}

=head2 _get_fetch_reserves

    検索条件作成および、予約テーブル検索実行

=cut

sub _get_fetch_reserves {
    my $self = shift;
    my $args = shift;

    my $tp        = $args->{tp};
    my $after     = $args->{after};
    my $login_row = $args->{login_row};

    # 指定の月の月頭取得
    my $tp_month_head = tp_next_month_after( $tp, $after );
    my $tp_month_next = tp_next_month_after( $tp, $after + 1 );

    my $parse_month_head = parse_datetime( $tp_month_head->over24_datetime );
    my $parse_month_next = parse_datetime( $tp_month_next->over24_datetime );

    # 検索条件 例: '2016-05-03 06:00:00'
    my $search = +{
        start => $parse_month_head->{date} . ' ' . $YOYAKKU_TIME,
        end   => $parse_month_next->{date} . ' ' . $YOYAKKU_TIME,
    };

    # 検索実行
    my $reserve_rows = $login_row->fetch_reserve($search);

    # 検索結果のテキストを加工
    my $recom_reserve = $self->_recom_reserve($reserve_rows);

    return +{
        reserve => $recom_reserve,
        year    => $tp_month_head->over24_year,
        mon     => $tp_month_head->over24_mon,
    };
}

=head2 _recom_reserve

    予約情報を履歴表示用に加工

=cut

sub _recom_reserve {
    my $self          = shift;
    my $reserve_rows  = shift;
    my $hist_reserves = [];
    for my $reserve_row ( @{$reserve_rows} ) {
        my $start_tp = tp_from_datetime_over24( $reserve_row->getstarted_on,
            $YOYAKKU_TIME );
        my $end_tp
            = tp_from_datetime_over24( $reserve_row->enduse_on, $YOYAKKU_TIME );

        my $parse_start = parse_datetime( $start_tp->over24_datetime );
        my $parse_end   = parse_datetime( $end_tp->over24_datetime );

        # 例: '2016-05-03 10:00-12:00 ->'
        my $date
            = $parse_start->{date} . ' '
            . $parse_start->{hour_min} . '-'
            . $parse_end->{hour_min} . ' ->';

        push @{$hist_reserves},
            +{
            id      => $reserve_row->id,
            date    => $date,
            date_ym => $parse_start->{date},
            };
    }
    return $hist_reserves;
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::Model::Management>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
