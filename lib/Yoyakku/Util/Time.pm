package Yoyakku::Util::Time;
use Mojo::Base -strict;
use Time::Piece::Over24;
use Time::Seconds;
use Exporter 'import';
our @EXPORT_OK = qw{
    tp_now
    tp_from_date
    tp_from_datetime
    tp_from_datetime_over24
    tp_now_over24
    tp_month_head
    tp_next_month
    tp_next_month_after
    parse_datetime
    tp_next_day
    now_datetime
};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Util::Time - ユーティリティー API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Util version 0.0.1

=head1 SYNOPSIS (概要)

    Yoyakku アプリケーションのユーティリティー

=cut

=head2 split_datetime

    datetime 形式を date, time へ

=cut

sub split_datetime {
    my $datetime = shift;
    my ( $date, $time ) = split ' ', $datetime;
    return +{ date => $date, time => $time, };
}

=head2 split_date

    date 形式を year, mon, mday へ

=cut

sub split_date {
    my $date = shift;
    my ( $year, $mon, $mday ) = split '-', $date;
    return +{ year => $year, mon => $mon, mday => $mday, };
}

=head2 split_time

    time 形式を hour, min, sec へ

=cut

sub split_time {
    my $time = shift;
    my ( $hour, $min, $sec ) = split ':', $time;
    my $hour_min = $hour . ':' . $min;
    return +{
        hour     => $hour,
        min      => $min,
        sec      => $sec,
        hour_min => $hour_min,
    };
}

=head2 parse_datetime

    datetime 形式を分解

    my $parse = parse_datetime('2016-10-15 12:30:20');

    # $parse = +{
    #     date     => '2016-10-15',
    #     time     => '12:30:20',
    #     year     => '2016',
    #     mon      => '10',
    #     mday     => '15',
    #     hour     => '12',
    #     min      => '30',
    #     sec      => '20',
    #     hour_min => '12:30',
    # };

=cut

sub parse_datetime {
    my $datetime       = shift;
    my $split_datetime = split_datetime($datetime);
    my $split_date     = split_date( $split_datetime->{date} );
    my $split_time     = split_time( $split_datetime->{time} );
    return +{ %{$split_datetime}, %{$split_date}, %{$split_time}, };
}

=head2 tp_now

    Time Piece で現在時刻を取得

    # 現在時刻の Time::Piece オブジェクト取得
    my $tp = tp_now();

=cut

sub tp_now {
    my $tp = localtime;
    return $tp;
}

=head2 now_datetime

    # 今の日時を datatime 形式の文字列で取得
    now_datetime(); # 2015-06-01 23:55:30

=cut

sub now_datetime { return tp_now()->datetime( T => ' ' ); }

=head2 tp_from_date

    日付のテキストから Time Piece を取得

    my $tp = tp_from_date('2016-10-15');

    # "2016-10-15T00:00:00"
    $tp->datetime;

=cut

sub tp_from_date {
    my $date = shift;
    my $tp = localtime->strptime( $date, '%Y-%m-%d' );
    return $tp;
}

=head2 tp_from_datetime

    日付と時刻のテキストから Time Piece を取得

    my $tp = tp_from_date('2016-10-15 12:30:10');

    # "2016-10-15T12:30:10"
    $tp->datetime;

=cut

sub tp_from_datetime {
    my $datetime = shift;
    my $tp = localtime->strptime( $datetime, '%Y-%m-%d %T' );
    return $tp;
}

=head2 tp_from_datetime_over24

    日付と時刻のテキストから日付変更を指定して Time Piece を取得

    my $tp = tp_from_datetime_over24('2016-10-15 02:20:30', '06:00:00');

    # "2016-10-15T02:20:30"
    $tp->datetime;

    # "2016-10-14 26:20:30"
    $tp->over24_datetime;

    # 境界線
    $tp = tp_from_datetime_over24('2016-10-15 06:00:00', '06:00:00');

    # "2016-10-15T06:00:00" "2016-10-15 06:00:00"
    $tp->datetime; $tp->over24_datetime;

    $tp = tp_from_datetime_over24('2016-10-15 05:59:59', '06:00:00');

    # "2016-10-15T05:59:59" "2016-10-14 29:59:59"
    $tp->datetime; $tp->over24_datetime;

=cut

sub tp_from_datetime_over24 {
    my $datetime  = shift;
    my $over_time = shift;
    my $tp        = tp_from_datetime($datetime);
    $tp->over24_offset($over_time);
    return $tp;
}

=head2 tp_now_over24

    Time Piece で現在時刻を日付変更を指定して取得

=cut

sub tp_now_over24 {
    my $over_time = shift;
    my $tp_obj    = tp_now();
    $tp_obj->over24_offset($over_time);
    return $tp_obj;
}

=head2 tp_month_head

    日付を月の頭にもどす

=cut

sub tp_month_head {
    my $tp_obj  = shift;
    my $now_day = $tp_obj->mday;

    # 月の頭 1日 より大きい場合は計算
    if ( 1 < $now_day ) {
        my $pull_day = $now_day - 1;
        $tp_obj = $tp_obj - ONE_DAY * $pull_day;
    }
    return $tp_obj;
}

=head2 tp_next_month

    日付を翌月の頭にする

=cut

sub tp_next_month {
    my $tp_obj = shift;

    # 月頭にもどす
    $tp_obj = tp_month_head($tp_obj);

    my $push_day = $tp_obj->month_last_day;
    $tp_obj = $tp_obj + ONE_DAY * $push_day;

    return $tp_obj;
}

=head2 tp_next_month_after

    日付を任意の月の数だけすすめて月の頭にする

=cut

sub tp_next_month_after {
    my $tp    = shift;
    my $after = shift;

    if ( !$after ) {
        $tp = tp_month_head($tp);
        return $tp;
    }

    for my $int ( 1 .. $after ) {
        $tp = tp_next_month($tp);
    }

    return $tp;
}

=head2 tp_next_day

    日付を次の日にすすめる

=cut

sub tp_next_day {
    my $tp = shift;
    $tp = $tp + ONE_DAY * 1;
    return $tp;
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Time::Piece>

=item * L<Time::Seconds>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
