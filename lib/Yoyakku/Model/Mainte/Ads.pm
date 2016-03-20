package Yoyakku::Model::Mainte::Ads;
use Mojo::Base 'Yoyakku::Model::Mainte';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Mainte::Ads - ads テーブル管理用 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Mainte::Ads version 0.0.1

=head1 SYNOPSIS (概要)

    Ads コントローラーのロジック API

=cut

=head2 get_storeinfo_rows_all

    店舗情報の全てを row オブジェクトで取得

=cut

sub get_storeinfo_rows_all {
    my $self           = shift;
    my $teng           = $self->teng();
    my @storeinfo_rows = $teng->search( 'storeinfo', +{}, );
    return \@storeinfo_rows;
}

=head2 get_region_rows_pref

    地域ID情報、全国都道府県のみ row オブジェクトで取得

=cut

sub get_region_rows_pref {
    my $self = shift;
    my $teng = $self->teng();

    my $sql = q{
        SELECT id, name
        FROM region
        WHERE id REGEXP '(^[0-4][0-9])0{3}$'
        ORDER BY id ASC;
    };

    my @region_rows = $teng->search_named($sql);
    return \@region_rows;
}

=head2 writing_ads

    テーブル書込み、新規、修正、両方に対応

=cut

sub writing_ads {
    my $self   = shift;
    my $params = shift;
    my $type   = shift;

    my $create_data = $self->get_create_data( 'ads', $params );

    my $args = +{
        table       => 'ads',
        create_data => $create_data,
        update_id   => $params->{id},
        type        => $type,
    };

    return $self->writing_from_db($args);
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::Model::Mainte>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
