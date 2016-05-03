package Yoyakku::Model::Management::Reserve;
use Mojo::Base 'Yoyakku::Model::Management::Base';
use Yoyakku::Util::Time qw{
    tp_from_datetime_over24
    tp_now_over24
    tp_next_month_after
    parse_datetime
};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Management::Reserve - 店舗管理 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Management::Reserve version 0.0.1

=head1 SYNOPSIS (概要)

    Management::Reserve コントローラーのロジック API

=cut

my $YOYAKKU_TIME = '06:00:00';

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
