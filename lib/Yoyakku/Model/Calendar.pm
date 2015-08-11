package Yoyakku::Model::Calendar;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model';
use Yoyakku::Util qw{chang_date_6};
use Calendar::Simple;

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model::Calendar - オープニングカレンダー用 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Calendar version 0.0.1

=head1 SYNOPSIS (概要)

Calendar コントローラーのロジック API

=cut

=head2 get_cal_info_ads_rows

    今月のイベント広告データ取得

=cut

sub get_cal_info_ads_rows {
    my $self      = shift;
    my $date_info = shift;

    my $teng      = $self->teng();
    my $like_date = $date_info->strftime('%Y-%m');

    # 今月のイベント広告データ取得
    my $sql = q{
        SELECT * FROM ads
        WHERE kind=1 AND displaystart_on
        like :like_date
        ORDER BY displaystart_on ASC;
    };
    my $bind_values = +{ like_date => $like_date . "%", };
    my @ads_rows = $teng->search_named( $sql, $bind_values );
    return \@ads_rows;
}

=head2 get_calendar_info

    カレンダー情報の取得

=cut

sub get_calendar_info {
    my $self          = shift;
    my $date_info     = shift;
    my $calendar_info = calendar( $date_info->mon, $date_info->year );
    return $calendar_info;
}

=head2 get_calender_caps

    カレンダー表示用の曜日

=cut

sub get_calender_caps {
    my $self = shift;
    my $caps = [qw{日 月 火 水 木 金 土}];
    return $caps;
}

=head2 get_date_info

    カレンダー表示用の日付情報取得

=cut

sub get_date_info {
    my $self      = shift;
    my $date_type = shift;
    my $date_6    = chang_date_6();
    my $date_info = $date_6->{$date_type};
    return $date_info;
}

=head2 get_header_stash_index

    ヘッダー初期値取得

=cut

sub get_header_stash_index {
    my $self = shift;

    my $table      = $self->login_table();
    my $login_row  = $self->login_row();
    my $login_name = $self->login_name();

    return if $login_row && !$login_row->status;

    my $switch_header = 2;

    if ( $table eq 'admin' ) {
        $switch_header = 4;
        if ( $self->storeinfo_row()->status eq 0 ) {
            $switch_header = 9;
        }
    }
    elsif ( $table eq 'general' ) {
        $switch_header = 3;
    }

    return $self->get_header_stash_params( $switch_header, $login_name );
}

1;

__END__
