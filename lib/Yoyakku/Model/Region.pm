package Yoyakku::Model::Region;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model';
use Yoyakku::Util qw{chang_date_6};

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

=head2 get_select_date

    選択された日付を取得

=cut

sub get_select_date {
    my $self = shift;
    my $date = $self->params()->{select_date};
    return $date if $date;
    return chang_date_6()->{now_date}->date();
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
