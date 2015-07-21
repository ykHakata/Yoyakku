package Yoyakku::Model::Mainte::Region;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model::Mainte';
use Yoyakku::Util qw{now_datetime get_fill_in_params};


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
