package Yoyakku::Model::Region;
use Mojo::Base 'Yoyakku::Model::Base';
use Yoyakku::Util
    qw{chang_date_6 get_month_last_date get_calendar get_tp_obj_strptime};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Region - 予約用 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Region version 0.0.1

=head1 SYNOPSIS (概要)

    Region コントローラーのロジック API

=cut

=head2 get_redirect_mode_region

    ログイン情報からリダイレクト先を取得 (予約)

=cut

sub get_redirect_mode_region {
    my $self      = shift;
    my $login_row = shift;
    return 'profile' if $login_row && !$login_row->status;
    return;
}

=head2 get_header_stash_region

    ヘッダー初期値取得

=cut

sub get_header_stash_region {
    my $self      = shift;
    my $login_row = shift;

    my $table;
    my $login_name;

    if ($login_row) {
        $table = $login_row->get_table_name;
        $login_name
            = $login_row->fetch_profile
            ? $login_row->fetch_profile->nick_name
            : undef;
    }

    my $switch_header = 5;

    return $self->get_header_stash_params( $switch_header, $login_name )
        if !$table;

    if ( $table eq 'admin' ) {
        $switch_header = $login_row->fetch_storeinfo->status eq 0 ? 10 : 7;
        $login_name = q{(admin)} . $login_name;
    }
    elsif ( $table eq 'general' ) {
        $switch_header = 6;
    }

    return $self->get_header_stash_params( $switch_header, $login_name );
}

=head2 get_ads_one_rows

    一行広告データ取得

=cut

sub get_ads_one_rows {
    my $self = shift;
    my $rows = $self->db->ads->ads_one_rows();
    return $rows;
}

=head2 get_ads_reco_rows

    おすすめスタジオ広告データ取得

    # my @adsReco_rows = $teng->search_named(q{
    #     select ads.id , ads.kind , ads.region_id,
    #     ads.name, ads.url,ads.content,region.name
    #     as region_name from ads left join region on
    #     ads.region_id = region.id where kind=4;
    # });

=cut

sub get_ads_reco_rows {
    my $self = shift;
    my $teng = $self->db->base->teng();
    my $sql  = q{
        SELECT
            ads.id,
            ads.kind,
            ads.region_id,
            ads.name,
            ads.url,
            ads.content,
            region.name AS region_name
        FROM ads LEFT JOIN region
        ON ads.region_id = region.id
        WHERE ads.kind = :kind;
    };
    my $bind_values = +{ kind => 4, };
    my @rows = $teng->search_named( $sql, $bind_values );
    return \@rows;
}

=head2 get_ads_rows

    イベントスケジュール取得

    my @ads_rows = $teng->search_named(q{
        select * from ads where
        kind=1 and displaystart_on >= :now_data_ymd and
        displaystart_on <= :next3m_last_ymd
        order by displaystart_on asc;
    }, { now_data_ymd => $now_data_ymd , next3m_last_ymd => $next3m_last_ymd });

=cut

sub get_ads_rows {
    my $self         = shift;
    my $teng         = $self->db->base->teng();
    my $now_data_ymd = chang_date_6()->{now_date}->date();
    my $next3m_last_ymd
        = get_month_last_date( chang_date_6()->{next3m_date} );
    my $sql = q{
        SELECT * FROM ads
        WHERE kind = :kind
        AND displaystart_on >= :now_data_ymd
        AND displaystart_on <= :next3m_last_ymd
        ORDER BY displaystart_on ASC;
    };
    my $bind_values = +{
        kind            => 1,
        now_data_ymd    => $now_data_ymd,
        next3m_last_ymd => $next3m_last_ymd,
    };
    my @rows = $teng->search_named( $sql, $bind_values );
    return \@rows;
}

=head2 get_switch_calnavi

    カレンダーナビに store_id を埋め込む為の切替

=cut

sub get_switch_calnavi {
    my $self = shift;
    return 0;
}

=head2 get_storeinfo_rows_region_navi

    地域ナビため、店舗登録をすべて抽出(web公開許可分だけ)

=cut

sub get_storeinfo_rows_region_navi {
    my $self = shift;
    my $rows = $self->db->storeinfo->storeinfo_rows_region_navi();
    return $rows;
}

=head2 get_region_rows_region_navi

    地域ナビため、地域IDをすべて抽出

=cut

sub get_region_rows_region_navi {
    my $self = shift;
    my $rows = $self->db->region->rows_all();
    return $rows;
}

=head2 get_cal_params

    選択したカレンダー情報一式を取得

=cut

sub get_cal_params {
    my $self       = shift;
    my $req_params = shift;

    my $params = +{};

    my $back_mon     = $req_params->{back_mon};
    my $back_mon_val = $req_params->{back_mon_val};
    my $next_mon     = $req_params->{next_mon};
    my $next_mon_val = $req_params->{next_mon_val};
    my $select_date  = $req_params->{select_date};

    my $now_date    = chang_date_6()->{now_date};
    my $next1m_date = chang_date_6()->{next1m_date};
    my $next2m_date = chang_date_6()->{next2m_date};
    my $next3m_date = chang_date_6()->{next3m_date};

    my $select_cal = 0;

    if ($back_mon) {
        $select_cal
            = ( $back_mon_val == 0 ) ? 0
            : ( $back_mon_val == 1 ) ? 1
            : ( $back_mon_val == 2 ) ? 2
            :                          0;
        if ( $select_cal == 0 ) {
            $params->{select_date_day} = ( $now_date->mday ) + 0;
        }
        else {
            $params->{select_date_day} = 1;
        }

        # select_dateの値を作る（文字列で）
        $select_date
            = ( $back_mon_val == 0 ) ? $now_date->date
            : ( $back_mon_val == 1 ) ? $next1m_date->date
            : ( $back_mon_val == 2 ) ? $next2m_date->date
            :                          $now_date->date;
    }

    if ($next_mon) {
        $select_cal
            = ( $next_mon_val == 0 ) ? 0
            : ( $next_mon_val == 1 ) ? 1
            : ( $next_mon_val == 2 ) ? 2
            : ( $next_mon_val == 3 ) ? 3
            :                          0;
        if ( $select_cal == 0 ) {
            $params->{select_date_day} = ( $now_date->mday ) + 0;
        }
        else {
            $params->{select_date_day} = 1;
        }

        # select_dateの値を作る（文字列で）
        $select_date
            = ( $next_mon_val == 0 ) ? $now_date->date
            : ( $next_mon_val == 1 ) ? $next1m_date->date
            : ( $next_mon_val == 2 ) ? $next2m_date->date
            : ( $next_mon_val == 3 ) ? $next3m_date->date
            :                          $now_date->date;
    }

    # 受け取った日付文字列から、出力するカレンダーを選択
    if ($select_date) {
        $select_date = get_tp_obj_strptime( $select_date, '%Y-%m-%d' );

        $select_cal
            = (
            $select_date->strftime('%Y-%m') eq $now_date->strftime('%Y-%m') )
            ? 0
            : ( $select_date->strftime('%Y-%m') eq
                $next1m_date->strftime('%Y-%m') ) ? 1
            : ( $select_date->strftime('%Y-%m') eq
                $next2m_date->strftime('%Y-%m') ) ? 2
            : ( $select_date->strftime('%Y-%m') eq
                $next3m_date->strftime('%Y-%m') ) ? 3
            : 0;

        $params->{select_date_day} = ( $select_date->mday ) + 0;
    }
    else {
        $select_date = get_tp_obj_strptime( $now_date->date, '%Y-%m-%d' );
        if ( $select_cal == 0 ) {
            $params->{select_date_day} = ( $now_date->mday ) + 0;
        }
        else {
            $params->{select_date_day} = 1;
        }
    }

    if ( $select_cal == 0 ) {
        $params->{cal} = get_calendar( $now_date->mon, $now_date->year );
        $params->{select_date_ym}  = $now_date->strftime('%Y-%m');
        $params->{border_date_day} = ( $now_date->mday ) + 0;
        $params->{back_mon_val}    = 0;
        $params->{next_mon_val}    = 1;
    }
    elsif ( $select_cal == 1 ) {
        $params->{cal} = get_calendar( $next1m_date->mon, $next1m_date->year );
        $params->{select_date_ym}  = $next1m_date->strftime('%Y-%m');
        $params->{border_date_day} = 1;
        $params->{back_mon_val}    = 0;
        $params->{next_mon_val}    = 2;
    }
    elsif ( $select_cal == 2 ) {
        $params->{cal} = get_calendar( $next2m_date->mon, $next2m_date->year );
        $params->{select_date_ym}  = $next2m_date->strftime('%Y-%m');
        $params->{border_date_day} = 1;
        $params->{back_mon_val}    = 1;
        $params->{next_mon_val}    = 3;
    }
    else {
        $params->{cal} = get_calendar( $next3m_date->mon, $next3m_date->year );
        $params->{select_date_ym}  = $next3m_date->strftime('%Y-%m');
        $params->{border_date_day} = 1;
        $params->{back_mon_val}    = 2;
        $params->{next_mon_val}    = 3;
    }
    $params->{select_date} = $select_date->date;
    return $params;
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::Model>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
