package Yoyakku::Model::Mainte::Region;
use Mojo::Base 'Yoyakku::Model::Mainte::Base';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Mainte::Region - region テーブル管理用 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Mainte::Region version 0.0.1

=head1 SYNOPSIS (概要)

    Region コントローラーのロジック API

=cut

=head2 search_region_id_rows

    テーブル一覧作成時に利用

=cut

sub search_region_id_rows {
    my $self   = shift;
    my $params = shift;
    return $self->search_id_single_or_all_rows( 'region', $params->{id} );
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
