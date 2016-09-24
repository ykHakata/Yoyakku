package Yoyakku::Util;
use strict;
use warnings;
use utf8;
use Time::Piece;
use Time::Seconds;
use Calendar::Simple;
use Yoyakku::Master qw{$HOUR_00 $HOUR_06 $SPACE};
use Exporter 'import';
our @EXPORT_OK = qw{
    chang_date_6
    switch_header_params
    now_datetime
    join_time
    split_time
    chenge_time_over
    previous_day_ymd
    split_date_time
    next_day_ymd
    join_date_time
    get_start_end_tp
    get_month_last_date
    get_calendar
    get_tp_obj_strptime
    get_tp_obj
    calendar_move
    chang_datetime_24for29
};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Util - ユーティリティー API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Util version 0.0.1

=head1 SYNOPSIS (概要)

    Yoyakku アプリケーションのユーティリティー

=cut

=head2 get_tp_obj

    Time Piece オブジェクト取得

=cut

sub get_tp_obj {
    my $tp_obj = localtime;
    return $tp_obj;
}

=head2 get_tp_obj_strptime

    Time Piece オブジェクト取得(フォーマット指定)

=cut

sub get_tp_obj_strptime {
    my $string = shift;
    my $format = shift;
    my $tp_obj = localtime->strptime( $string, $format, );
    return $tp_obj;
}

=head2 get_calendar

    カレンダー情報を取得

=cut

sub get_calendar {
    my $month = shift;
    my $year  = shift;
    my $cal   = calendar( $month, $year, );
    return $cal;
}

=head2 get_start_end_tp

    開始、終了日付を time::Piece オブジェクト変換

=cut

sub get_start_end_tp {
    my $start_date_time = shift;
    my $end_date_time   = shift;

    my $start_tp = localtime->strptime( $start_date_time, '%Y-%m-%d %T' );
    my $end_tp   = localtime->strptime( $end_date_time,   '%Y-%m-%d %T' );

    return ( $start_tp, $end_tp, );
}

=head2 join_date_time

    datetime 形式を組み立て

=cut

sub join_date_time {
    my $split_dt = shift;

    my $start_date = $split_dt->{start_date};
    my $start_time = $split_dt->{start_time};
    my $end_date   = $split_dt->{end_date};
    my $end_time   = $split_dt->{end_time};

    my $start_date_time = join $SPACE, $split_dt->{start_date},
        $split_dt->{start_time};

    my $end_date_time = join $SPACE, $split_dt->{end_date},
        $split_dt->{end_time};

    return ( $start_date_time, $end_date_time, );
}

=head2 split_date_time

    日付と時間をわける

=cut

sub split_date_time {
    my $start_date_time = shift;
    my $end_date_time   = shift;

    my $FIELD_COUNT = 2;

    my ( $start_date, $start_time, ) = split $SPACE, $start_date_time,
        $FIELD_COUNT + 1;

    my ( $end_date, $end_time, ) = split $SPACE, $end_date_time,
        $FIELD_COUNT + 1;

    return +{
        start_date => $start_date,
        start_time => $start_time,
        end_date   => $end_date,
        end_time   => $end_time,
    };
}

=head2 next_day_ymd

    日付を一日進める

=cut

sub next_day_ymd {
    my $date = shift;
    my $date_tp = localtime->strptime( $date, '%Y-%m-%d' );
    $date_tp = $date_tp + ONE_DAY;
    $date    = $date_tp->ymd;
    return $date;
}

=head2 previous_day_ymd

    日付を一日もどす

=cut

sub previous_day_ymd {
    my $date = shift;
    my $date_tp = localtime->strptime( $date, '%Y-%m-%d' );
    $date_tp = $date_tp - ONE_DAY;
    $date    = $date_tp->ymd;
    return $date;
}

=head2 chenge_time_over

    24:00 表記と 30:00 表記を切り替え normal, over,

=cut

sub chenge_time_over {
    my $times = shift;
    my $type  = shift;

    my $start_time = $times->{start_time};
    my $end_time   = $times->{end_time};

    my $split_t = split_time( $start_time, $end_time, );

    # 数字にもどす
    $split_t->{start_hour} += 0;
    $split_t->{end_hour}   += 0;

    # type 指定ない場合は over 30:00 表記に
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
    # die;
    if ($type && $type eq 'normal') {
        if ( $split_t->{start_hour} >= 24 && $split_t->{start_hour} <= 30 ) {
            $split_t->{start_hour} -= 24;
        }
        # die;
        if ( $split_t->{end_hour} >= 24 && $split_t->{end_hour} <= 30 ) {
            $split_t->{end_hour} -= 24;
        }
    }

    return $split_t;
}

=head2 join_time

    time 形式を組み立て none 時間の頭の0つけない

=cut

sub join_time {
    my $split_t = shift;
    my $type    = shift;

    my $FIELD_SEPARATOR_TIME = q{:};

    my $start_time = join $FIELD_SEPARATOR_TIME,
        $split_t->{start_hour},
        $split_t->{start_min},
        $split_t->{start_sec};

    my $end_time = join $FIELD_SEPARATOR_TIME,
        $split_t->{end_hour},
        $split_t->{end_min},
        $split_t->{end_sec};

    if (!$type) {
        $start_time = sprintf '%08s', $start_time;
        $end_time   = sprintf '%08s', $end_time;
    }

    return ( $start_time, $end_time, );
}

=head2 split_time

    time 形式を分解

=cut

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

=head2 now_datetime

    use Yoyakku::Util qw{now_datetime};

    now_datetime(), # 2015-06-01 23:55:30

    今の日時を datatime 形式の文字列で取得

=cut

sub now_datetime {
    my $now = localtime;

    return $now->datetime( T => $SPACE );
}

=head2 chang_datetime_24for29

    use Yoyakku::Util qw{chang_datetime_24for29};

    my $chang_datetime_ref
        = chang_datetime_24for29( $reserve_ref->getstarted_on,
        $reserve_ref->enduse_on );

    24時間を29時間に変更(datetime形式)

=cut

sub chang_datetime_24for29 {
    my $datetime_start = shift @_;
    my $datetime_end   = shift @_;

    # 日付情報を分解
    my $datetime_start_ymd  = substr( $datetime_start, 0,  10 );
    my $datetime_start_hour = substr( $datetime_start, 11, 2 );

    my $datetime_start_min = substr( $datetime_start, 14, 2 );
    my $datetime_start_sec = substr( $datetime_start, 17, 2 );

    my $datetime_end_ymd  = substr( $datetime_end, 0,  10 );
    my $datetime_end_hour = substr( $datetime_end, 11, 2 );
    my $datetime_end_min  = substr( $datetime_end, 14, 2 );
    my $datetime_end_sec  = substr( $datetime_end, 17, 2 );

    #時刻0-5時の場合は24-29に変換、(startのみ)
    $datetime_start_hour += 0;

    if ( $datetime_start_hour =~ /^[0-5]$/ ) {
        $datetime_start_hour += 24;

        #日付を1日もどる
        $datetime_start_ymd
            = localtime->strptime( $datetime_start_ymd, '%Y-%m-%d' );
        $datetime_start_ymd = $datetime_start_ymd - ONE_DAY * 1;
        $datetime_start_ymd = $datetime_start_ymd->date;
    }
    $datetime_start_hour = sprintf( "%02d", $datetime_start_hour );

    #時刻0-6時の場合は24-30に変換、(endのみ)
    $datetime_end_hour += 0;

    #念のために時刻を数字の型にして、最初の0があれば表示しない
    #時刻0-6時の場合は24-30に変換、
    if ( $datetime_end_hour =~ /^[0-6]$/ ) {
        $datetime_end_hour += 24;

        #日付を1日もどる
        $datetime_end_ymd
            = localtime->strptime( $datetime_end_ymd, '%Y-%m-%d' );
        $datetime_end_ymd = $datetime_end_ymd - ONE_DAY * 1;
        $datetime_end_ymd = $datetime_end_ymd->date;
    }
    $datetime_end_hour = sprintf( "%02d", $datetime_end_hour );

    # 修正した日付の文字列をまとめる
    my $datetime_start_chang
        = $datetime_start_ymd . q{ }
        . $datetime_start_hour . q{:}
        . $datetime_start_min . q{:}
        . $datetime_start_sec;

    my $datetime_end_chang
        = $datetime_end_ymd . q{ }
        . $datetime_end_hour . q{:}
        . $datetime_end_min . q{:}
        . $datetime_end_sec;

    my $chang_datetime_ref = {
        datetime_start      => $datetime_start_chang,
        datetime_start_ymd  => $datetime_start_ymd,
        datetime_start_hour => $datetime_start_hour,
        datetime_start_min  => $datetime_start_min,
        datetime_start_sec  => $datetime_start_sec,
        datetime_end        => $datetime_end_chang,
        datetime_end_ymd    => $datetime_end_ymd,
        datetime_end_hour   => $datetime_end_hour,
        datetime_end_min    => $datetime_end_min,
        datetime_end_sec    => $datetime_end_sec,
    };

    return $chang_datetime_ref;
}

=head2 calendar_move

    use Yoyakku::Util qw{calendar_move};

    my $calender_move_ref = calendar_move( $date_ref, 'this' );

    カレンダー移動のサブルーチン

=cut

sub calendar_move {

    # 日付の最新情報を取得する(ハッシュリファレンス)
    my $date_ref = shift @_;

    # 表示したいカレンダー
    my $select_cal_date = shift @_;

    # 日付が押されたとき
    my $selected_date = shift @_;

    # 受け取った日付文字を日付データに変換
    my $select_date = localtime->strptime( $selected_date, '%Y-%m-%d' );

    my $now_date    = $date_ref->{now};
    my $next1m_date = $date_ref->{next1};
    my $next2m_date = $date_ref->{next2};
    my $next3m_date = $date_ref->{next3};

    # 表示したいカレンダー識別
    my $cal_date
        = ( $select_cal_date eq 'this' ) ? $now_date
        : ( $select_cal_date eq 'next_1' ) ? $next1m_date
        : ( $select_cal_date eq 'next_2' ) ? $next2m_date
        : ( $select_cal_date eq 'next_3' ) ? $next3m_date
        : $now_date;

    my $look_date
        = ( $select_cal_date eq 'this' ) ? $now_date
        : ( $select_cal_date eq 'next_1' ) ? $next1m_date
        : ( $select_cal_date eq 'next_2' ) ? $next2m_date
        : ( $select_cal_date eq 'next_3' ) ? $next3m_date
        : $now_date;

    my $next_date
        = ( $select_cal_date eq 'this' ) ? $next1m_date
        : ( $select_cal_date eq 'next_1' ) ? $next2m_date
        : ( $select_cal_date eq 'next_2' ) ? $next3m_date
        : ( $select_cal_date eq 'next_3' ) ? $next3m_date
        : $next1m_date;

    my $back_date
        = ( $select_cal_date eq 'this' ) ? $now_date
        : ( $select_cal_date eq 'next_1' ) ? $now_date
        : ( $select_cal_date eq 'next_2' ) ? $next1m_date
        : ( $select_cal_date eq 'next_3' ) ? $next2m_date
        : $now_date;

    #カレンダー情報をつくる
    my @caps = ( "日", "月", "火", "水", "木", "金", "土" );
    my @cal_now = calendar( $cal_date->mon, $cal_date->year );

    my $calender_move_ref = {
        look_date_ymd => $look_date->date,
        look_date_ym  => $look_date->strftime('%Y-%m'),
        look_date_wday =>
            $look_date->wdayname(qw( 日 月 火 水 木 金 土 )),
        select_date_d => $look_date->mday,
        past_date_d   => $look_date->mday,
        next_date_ym  => $next_date->strftime('%Y-%m'),
        back_date_ym  => $back_date->strftime('%Y-%m'),
        cal_now       => \@cal_now,
        caps          => \@caps,
        tomorrow      => $look_date + ONE_DAY * 1,
    };

    # 日付が選択されたときの
    if ($selected_date) {
        my $past_date_d;
        my $next_date_ym;
        my $back_date_ym;

        if ( $select_date->mon eq $now_date->mon ) {
            $past_date_d  = $now_date->mday;
            $next_date_ym = $next1m_date->strftime('%Y-%m');
            $back_date_ym = $now_date->strftime('%Y-%m');
        }

        if ( $select_date->mon eq $next1m_date->mon ) {
            $past_date_d  = 0;
            $next_date_ym = $next2m_date->strftime('%Y-%m');
            $back_date_ym = $now_date->strftime('%Y-%m');
        }

        if ( $select_date->mon eq $next2m_date->mon ) {
            $past_date_d  = 0;
            $next_date_ym = $next3m_date->strftime('%Y-%m');
            $back_date_ym = $next1m_date->strftime('%Y-%m');
        }

        if ( $select_date->mon eq $next3m_date->mon ) {
            $past_date_d  = 0;
            $next_date_ym = $next3m_date->strftime('%Y-%m');
            $back_date_ym = $next2m_date->strftime('%Y-%m');
        }

        @cal_now = calendar( $select_date->mon, $select_date->year );

        $calender_move_ref = {
            look_date_ymd => $select_date->date,
            look_date_ym  => $select_date->strftime('%Y-%m'),
            look_date_wday =>
                $select_date->wdayname(qw( 日 月 火 水 木 金 土 )),
            select_date_d => $select_date->mday,
            past_date_d   => $past_date_d,
            next_date_ym  => $next_date_ym,
            back_date_ym  => $back_date_ym,
            cal_now       => \@cal_now,
            caps          => \@caps,
            tomorrow      => $select_date + ONE_DAY * 1,
        };
    }

    return $calender_move_ref;
}

=head2 chang_date_6

    use Yoyakku::Util qw{chang_date_6};

    # 日付変更線を６時に変更 (日付のオブジェクトで変換される)
    my $chang_date = chang_date_6();

    日付の始まりを午前６時にした日付のオブジェクトを提供

=cut

sub chang_date_6 {

    my $now = localtime;

    # 今が午前0時から午前6時の間ならば、日付を1日戻す
    if ( $now->hour >= $HOUR_00 && $now->hour < $HOUR_06 ) {
        $now = $now - ONE_DAY;
    }

    my $now_last = $now->strftime('%Y-%m-') . $now->month_last_day;

    $now_last = localtime->strptime( $now_last, '%Y-%m-%d' );

    my $next1 = $now_last + ONE_DAY;    # １ヶ月後の月頭

    my $next1_last = $next1->strftime('%Y-%m-') . $next1->month_last_day;

    $next1_last = localtime->strptime( $next1_last, '%Y-%m-%d' );

    my $next2 = $next1_last + ONE_DAY;    # ２ヶ月後の月頭

    my $next2_last = $next2->strftime('%Y-%m-') . $next2->month_last_day;

    $next2_last = localtime->strptime( $next2_last, '%Y-%m-%d' );

    my $next3 = $next2_last + ONE_DAY;    # ３ヶ月後の月頭

    return +{
        now_date    => $now,
        next1m_date => $next1,
        next2m_date => $next2,
        next3m_date => $next3,
    };
}

=head2 get_month_last_date

    月末の date 形式の日付の取得

=cut

sub get_month_last_date {
    my $tp_obj = shift;
    my $year   = $tp_obj->year;
    my $mon    = $tp_obj->mon;
    my $day    = $tp_obj->month_last_day;
    my $date   = $year . '-' . $mon . '-' . $day;
    return $date;
}

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

=cut

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

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<Time::Piece>

=item * L<Time::Seconds>

=item * L<HTML::FillInForm>

=item * L<Calendar::Simple>

=item * L<Yoyakku::Master>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
