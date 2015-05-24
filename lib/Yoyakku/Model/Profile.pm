package Yoyakku::Model::Profile;
use strict;
use warnings;
use utf8;
use Time::Piece;
use Time::Seconds;
use Exporter 'import';
our @EXPORT_OK = qw{
    chang_date_6
};

# 午前６時を日付変更線にした日付情報
sub chang_date_6 {
    my $now_date = localtime;

    # 今の時刻が0時〜6時未満の場合日付を一日前
    my $hour = $now_date->hour;

    my $chang_date = $now_date;

    if ( $hour >= 0 && $hour < 6 ) {
        $chang_date = $now_date - ONE_DAY * 1;
    }

    my $first_day
        = localtime->strptime( $chang_date->strftime('%Y-%m-01'),
        '%Y-%m-%d' );

    my $last_day
        = localtime->strptime(
        $chang_date->strftime( '%Y-%m-' . $chang_date->month_last_day ),
        '%Y-%m-%d' );

    my $next1m_date
        = localtime->strptime(
        $chang_date->strftime( '%Y-%m-' . $chang_date->month_last_day ),
        '%Y-%m-%d' )
        + 86400;

    my $next2m_date
        = localtime->strptime(
        $next1m_date->strftime( '%Y-%m-' . $next1m_date->month_last_day ),
        '%Y-%m-%d' )
        + 86400;

    my $next3m_date
        = localtime->strptime(
        $next2m_date->strftime( '%Y-%m-' . $next2m_date->month_last_day ),
        '%Y-%m-%d' )
        + 86400;

    my $chang_date_ref = {
        now_date    => $chang_date,
        next1m_date => $next1m_date,
        next2m_date => $next2m_date,
        next3m_date => $next3m_date,
    };

    return $chang_date_ref;
}

1;

__END__

#====================================================
# 午前６時を日付変更線にした日付情報
sub chang_date_6 {
    my ($now_date) = @_;

    # 今の時刻が0時〜6時未満の場合日付を一日前
    my $hour = $now_date->hour;

    my $chang_date;

    if ($hour >= 0 and $hour < 6) {
        $chang_date   = $now_date - ONE_DAY * 1;
    }
    else {
        $chang_date   = $now_date;
    }

    my $first_day   = localtime->strptime($chang_date->strftime( '%Y-%m-01'                             ),'%Y-%m-%d');
    my $last_day    = localtime->strptime($chang_date->strftime( '%Y-%m-' . $chang_date->month_last_day ),'%Y-%m-%d');
    my $next1m_date = localtime->strptime($chang_date->strftime( '%Y-%m-' . $chang_date->month_last_day ),'%Y-%m-%d') + 86400;
    my $next2m_date = localtime->strptime($next1m_date->strftime('%Y-%m-' . $next1m_date->month_last_day),'%Y-%m-%d') + 86400;
    my $next3m_date = localtime->strptime($next2m_date->strftime('%Y-%m-' . $next2m_date->month_last_day),'%Y-%m-%d') + 86400;

    my $chang_date_ref = {
        now_date    => $chang_date,
        next1m_date => $next1m_date,
        next2m_date => $next2m_date,
        next3m_date => $next3m_date,
    };

    return $chang_date_ref;
}
#====================================================


=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model::Profile - プロフィール用 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Profile version 0.0.1

=head1 SYNOPSIS (概要)

    use Yoyakku::Model::Profile qw{chang_date_6};

    # 日付変更線を６時に変更 (日付のオブジェクトで変換される)
    my $chang_date = chang_date_6();

プロフィール関連の API を提供

=head1 DEPENDENCIES (依存モジュール)

=over 2

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<Exporter>

=item * L<Time::Piece>

=item * L<Time::Seconds>

=back

=head1 SEE ALSO (参照)

L<Yoyakku::Guides>
