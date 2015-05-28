package Yoyakku::Util;
use strict;
use warnings;
use utf8;
use Time::Piece;
use Time::Seconds;
use Exporter 'import';
our @EXPORT_OK = qw{
    chang_date_6
    switch_header_params
};

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

sub switch_header_params {
    my $switch_header = shift;
    my $login_name    = shift;

    #日付変更線を６時に変更
    my $chang_date = chang_date_6();

    # 時刻(日付)取得、現在、1,2,3ヶ月後(ヘッダー用)
    my $now_data    = $chang_date->{now_date};
    my $next1m_data = $chang_date->{next1m_date};
    my $next2m_data = $chang_date->{next2m_date};
    my $next3m_data = $chang_date->{next3m_date};

    my @header_navi_row_name_value1 = (
        'region',
        'post',
        "store\ninfo",
        "room\ninfo",
        'reserve',
        'ads',
        'admin',
        'general',
        'profile',
        'acting',
        undef,
        $login_name,
    );

    my @header_navi_row_name_value2 = (
        $now_data->mon . '月',
        $next1m_data->mon . '月',
        $next2m_data->mon . '月',
        $next3m_data->mon . '月',
        '予約',
        undef,
        '登録',
        undef,
        undef,
        undef,
        undef,
        'login',
    );

    my @header_navi_row_name_value3 = @header_navi_row_name_value2;

    $header_navi_row_name_value3[5]  = '履歴';
    $header_navi_row_name_value3[6]  = 'プロフィール';
    $header_navi_row_name_value3[11] = $login_name;

    my @header_navi_row_name_value4 = @header_navi_row_name_value3;
    $header_navi_row_name_value4[5]  = '管理';
    $header_navi_row_name_value4[6]  = 'プロフィール';
    $header_navi_row_name_value4[11] = $login_name;

    my @header_navi_row_name_value5  = @header_navi_row_name_value2;
    $header_navi_row_name_value5[0]  = undef;
    $header_navi_row_name_value5[1]  = undef;
    $header_navi_row_name_value5[2]  = undef;
    $header_navi_row_name_value5[3]  = undef;

    my @header_navi_row_name_value6 = @header_navi_row_name_value3;
    $header_navi_row_name_value6[0]  = undef;
    $header_navi_row_name_value6[1]  = undef;
    $header_navi_row_name_value6[2]  = undef;
    $header_navi_row_name_value6[3]  = undef;

    my @header_navi_row_name_value7 = @header_navi_row_name_value4;
    $header_navi_row_name_value7[0]  = undef;
    $header_navi_row_name_value7[1]  = undef;
    $header_navi_row_name_value7[2]  = undef;
    $header_navi_row_name_value7[3]  = undef;

    my @header_navi_row_name_value8 = @header_navi_row_name_value7;
    $header_navi_row_name_value8[4]  = undef;
    $header_navi_row_name_value8[5]  = undef;
    $header_navi_row_name_value8[6]  = undef;

    #

    my @header_navi_link_name_value1 = (
        'mainte_region_serch',
        'mainte_post_serch',
        'mainte_storeinfo_serch',
        'mainte_roominfo_serch',
        'mainte_reserve_serch',
        'mainte_ads_serch',
        'mainte_registrant_serch',
        'mainte_general_serch',
        'mainte_profile_serch',
        'mainte_acting_serch',
        '#',
        'up_logout',
    );

    my @header_navi_link_name_value2 = (
        'index',
        'index_next_m',
        'index_next_two_m',
        'index_next_three_m',
        'region_state',
        '#',
        'entry',
        '#',
        '#',
        '#',
        '#',
        'up_login',
    );

    my @header_navi_link_name_value3 = @header_navi_link_name_value2;
    $header_navi_link_name_value3[5]  = 'history';
    $header_navi_link_name_value3[6]  = 'profile_comp';
    $header_navi_link_name_value3[11] = 'up_logout';

    my @header_navi_link_name_value4 = @header_navi_link_name_value3;
    $header_navi_link_name_value4[5]  = 'admin_store_edit';
    $header_navi_link_name_value4[11] = 'up_logout';

    my @header_navi_link_name_value9 = @header_navi_link_name_value4;
    $header_navi_link_name_value9[5] = 'admin_reserv_list';

    #

    my @header_navi_class_name_value1;

    for my $i ( 0 .. 11 ) {
        my $value
            = ( $i <= 8 ) ? 'header_navi_col'
            : ( $i >= 9 and $i <= 10 ) ? 'header_navi_col_delete'
            :                            'header_navi_col_in_login';
        $header_navi_class_name_value1[$i] = $value;
    }

    my @header_navi_class_name_value2;

    for my $i ( 0 .. 11 ) {
        my $value
            = ( $i <= 10 )
            ? 'header_navi_col'
            : 'header_navi_col_wait_login';
        $header_navi_class_name_value2[$i] = $value;
    }

    #

    my $site_title_link
        = ( $switch_header eq 8 )
        ? '#'
        : 'index';

    my $header_heading_name
        = ( $switch_header eq 1 )
        ? 'list'
        : '九州版';

    my $header_heading_link
        = ( $switch_header eq 1 )
        ? 'mainte_list'
        : '#';

    my @header_navi_row_name
        = ( $switch_header eq 1 ) ? @header_navi_row_name_value1
        : ( $switch_header eq 2 )  ? @header_navi_row_name_value2
        : ( $switch_header eq 3 )  ? @header_navi_row_name_value3
        : ( $switch_header eq 4 )  ? @header_navi_row_name_value4
        : ( $switch_header eq 5 )  ? @header_navi_row_name_value5
        : ( $switch_header eq 6 )  ? @header_navi_row_name_value6
        : ( $switch_header eq 7 )  ? @header_navi_row_name_value7
        : ( $switch_header eq 8 )  ? @header_navi_row_name_value8
        : ( $switch_header eq 9 )  ? @header_navi_row_name_value4
        : ( $switch_header eq 10 ) ? @header_navi_row_name_value7
        :                            @header_navi_row_name_value2;

    my @header_navi_link_name
        = ( $switch_header eq 1 ) ? @header_navi_link_name_value1
        : ( $switch_header eq 2 )  ? @header_navi_link_name_value2
        : ( $switch_header eq 3 )  ? @header_navi_link_name_value3
        : ( $switch_header eq 4 )  ? @header_navi_link_name_value4
        : ( $switch_header eq 5 )  ? @header_navi_link_name_value2
        : ( $switch_header eq 6 )  ? @header_navi_link_name_value3
        : ( $switch_header eq 7 )  ? @header_navi_link_name_value4
        : ( $switch_header eq 8 )  ? @header_navi_link_name_value3
        : ( $switch_header eq 9 )  ? @header_navi_link_name_value9
        : ( $switch_header eq 10 ) ? @header_navi_link_name_value9
        :                            @header_navi_link_name_value2;

    my @header_navi_class_name
        = ( $switch_header eq 1 ) ? @header_navi_class_name_value2
        : ( $switch_header eq 2 )  ? @header_navi_class_name_value2
        : ( $switch_header eq 3 )  ? @header_navi_class_name_value1
        : ( $switch_header eq 4 )  ? @header_navi_class_name_value1
        : ( $switch_header eq 5 )  ? @header_navi_class_name_value2
        : ( $switch_header eq 6 )  ? @header_navi_class_name_value1
        : ( $switch_header eq 7 )  ? @header_navi_class_name_value1
        : ( $switch_header eq 8 )  ? @header_navi_class_name_value1
        : ( $switch_header eq 9 )  ? @header_navi_class_name_value1
        : ( $switch_header eq 10 ) ? @header_navi_class_name_value1
        :                            @header_navi_class_name_value2;

    my $switch_header_params = +{
        site_title_link        => $site_title_link,
        header_heading_name    => $header_heading_name,
        header_heading_link    => $header_heading_link,
        header_navi_row_name   => \@header_navi_row_name,
        header_navi_link_name  => \@header_navi_link_name,
        header_navi_class_name => \@header_navi_class_name,
    };

    return $switch_header_params;
}

1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Util - ユーティリティー API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Util version 0.0.1

=head1 SYNOPSIS (概要)

Yoyakku アプリケーションのユーティリティー

=head2 chang_date_6

    use Yoyakku::Util qw{chang_date_6};

    # 日付変更線を６時に変更 (日付のオブジェクトで変換される)
    my $chang_date = chang_date_6();

日付の始まりを午前６時にした日付のオブジェクトを提供

=head2 switch_header_params

    use Yoyakku::Util qw{switch_header_params};

    # ヘッダーナビ、各パラメーターを取得
    my $header_params = switch_header_params( $switch_header, $login_name );

    my $header_params_hash_ref = +{
        site_title_link        => $header_params->{site_title_link},
        header_heading_link    => $header_params->{header_heading_link},
        header_heading_name    => $header_params->{header_heading_name},
        header_navi_class_name => $header_params->{header_navi_class_name},
        header_navi_link_name  => $header_params->{header_navi_link_name},
        header_navi_row_name   => $header_params->{header_navi_row_name},
    };

    # ヘッダーを識別するステータスとログイン名を引き渡し、ハッシュリファレンス返却

ヘッダーナビ、各パラメーターを取得

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
