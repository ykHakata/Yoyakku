package Yoyakku::Model::Mainte::Region;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model::Mainte';
use Yoyakku::Util qw{now_datetime get_fill_in_params};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Mainte::Region - region テーブル管理用 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Mainte::Region version 0.0.1

=head1 SYNOPSIS (概要)

    Region コントローラーのロジック API

=cut

=head2 search_region_id_rows

    use Yoyakku::Model::Mainte::Acting;

    my $model = $self->_init();

    my $acting_rows = $model->search_region_id_rows();

    テーブル一覧作成時に利用

=cut

sub search_region_id_rows {
    my $self = shift;
    return $self->search_id_single_or_all_rows( 'region',
        $self->params()->{id} );
}


1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<parent>

=item * L<Yoyakku::Model::Mainte>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
