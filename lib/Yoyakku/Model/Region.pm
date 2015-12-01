package Yoyakku::Model::Region;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model';
use Yoyakku::Util qw{chang_date_6 get_month_last_date};
use Calendar::Simple;
use Time::Piece;
use Time::Seconds;

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model::Region - 予約用 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Region version 0.0.1

=head1 SYNOPSIS (概要)

Region コントローラーのロジック API

=cut

=head2 get_header_stash_region

    ヘッダー初期値取得

=cut

sub get_header_stash_region {
    my $self = shift;

    my $table      = $self->login_table();
    my $login_row  = $self->login_row();
    my $login_name = $self->login_name();

    return if $login_row && !$login_row->status;

    my $switch_header = 5;

    return $self->get_header_stash_params( $switch_header, $login_name )
        if !$table;

    if ( $table eq 'admin' ) {
        $switch_header = $self->storeinfo_row()->status() eq 0 ? 10 : 7;
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
    my $teng = $self->teng();

    my @ads_one_rows = $teng->search(
        'ads',
        +{ kind     => 2, },
        +{ order_by => 'displaystart_on' },
    );
    return \@ads_one_rows;
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
    my $teng = $self->teng();
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
    my $teng         = $self->teng();
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

# 0 2000-01 1
# 0 2000-02 2
# 1 2000-03 3
# 2 2000-04 3

=head2 get_cal_params

    選択したカレンダー情報一式を取得

=cut
use Data::Dumper;
sub get_cal_params {
    my $self = shift;

    my $params = +{};

    my $back_mon     = $self->params->{back_mon};
    my $back_mon_val = $self->params->{back_mon_val};
    my $next_mon     = $self->params->{next_mon};
    my $next_mon_val = $self->params->{next_mon_val};
    my $select_date  = $self->params->{select_date};

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
    if ( $select_date ) {
        $select_date
            = localtime->strptime( $select_date, '%Y-%m-%d' );

        $select_cal
            = ( $select_date->strftime('%Y-%m') eq
                $now_date->strftime('%Y-%m') ) ? 0
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
        $select_date
            = localtime->strptime( $now_date->date, '%Y-%m-%d' );
        if ( $select_cal == 0 ) {
            $params->{select_date_day} = ( $now_date->mday ) + 0;
        }
        else {
            $params->{select_date_day} = 1;
        }
    }

    if ( $select_cal == 0 ) {
        $params->{cal} = calendar( $now_date->mon, $now_date->year );
        $params->{select_date_ym}  = $now_date->strftime('%Y-%m');
        $params->{border_date_day} = ( $now_date->mday ) + 0;
        $params->{back_mon_val}    = 0;
        $params->{next_mon_val}    = 1;
    }
    elsif ( $select_cal == 1 ) {
        $params->{cal} = calendar( $next1m_date->mon, $next1m_date->year );
        $params->{select_date_ym}  = $next1m_date->strftime('%Y-%m');
        $params->{border_date_day} = 1;
        $params->{back_mon_val}    = 0;
        $params->{next_mon_val}    = 2;
    }
    elsif ( $select_cal == 2 ) {
        $params->{cal} = calendar( $next2m_date->mon, $next2m_date->year );
        $params->{select_date_ym}  = $next2m_date->strftime('%Y-%m');
        $params->{border_date_day} = 1;
        $params->{back_mon_val}    = 1;
        $params->{next_mon_val}    = 3;
    }
    else {
        $params->{cal} = calendar( $next3m_date->mon, $next3m_date->year );
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

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<parent>

=item * L<Yoyakku::Model>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
