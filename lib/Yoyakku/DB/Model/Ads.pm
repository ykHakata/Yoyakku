package Yoyakku::DB::Model::Ads;
use Mojo::Base 'Yoyakku::DB::Model::Base';

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

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::DB::Model::Base>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
