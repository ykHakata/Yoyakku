package Yoyakku::DB::Model::Ads;
use Mojo::Base 'Yoyakku::DB::Model::Base';
use Yoyakku::Util qw{now_datetime};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::DB::Model::Ads - データベース Model

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::DB::Model::Ads version 0.0.1

=head1 SYNOPSIS (概要)

    Ads テーブルの API を提供

=cut

has table => 'ads';

=head2 ads_navi_rows

    ナビ広告データ取得

=cut

sub ads_navi_rows {
    my $self = shift;
    my $teng = $self->teng();
    my @rows = $teng->search(
        $self->table,
        +{ kind     => 3, },
        +{ order_by => 'displaystart_on' },
    );
    return \@rows;
}

=head2 cal_info_ads_rows

    今月のイベント広告データ取得

=cut

sub cal_info_ads_rows {
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
    my @rows = $teng->search_named( $sql, $bind_values );
    return \@rows;
}

=head2 ads_one_rows

    一行広告データ取得

=cut

sub ads_one_rows {
    my $self = shift;
    my $teng = $self->teng();

    my @rows = $teng->search(
        'ads',
        +{ kind     => 2, },
        +{ order_by => 'displaystart_on' },
    );
    return \@rows;
}

=head2 writing

    テーブル書込み、新規、修正、両方に対応

=cut

sub writing {
    my $self   = shift;
    my $params = shift;
    my $type   = shift;

    my $create_data = +{
        kind            => $params->{kind},
        storeinfo_id    => $params->{storeinfo_id},
        region_id       => $params->{region_id},
        url             => $params->{url},
        displaystart_on => $params->{displaystart_on},
        displayend_on   => $params->{displayend_on},
        name            => $params->{name},
        event_date      => $params->{event_date},
        content         => $params->{content},
        create_on       => now_datetime(),
        modify_on       => now_datetime(),
    };

    my $args = +{
        table       => $self->table,
        create_data => $create_data,
        update_id   => $params->{id},
        type        => $type,
    };

    return $self->writing_db($args);
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::DB::Model::Base>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
