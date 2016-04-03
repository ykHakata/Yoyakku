package Yoyakku::Model::Mainte::Ads;
use Mojo::Base 'Yoyakku::Model::Mainte::Base';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Mainte::Ads - ads テーブル管理用 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Mainte::Ads version 0.0.1

=head1 SYNOPSIS (概要)

    Ads コントローラーのロジック API

=cut

=head2 get_region_rows_pref

    地域ID情報、全国都道府県のみ row オブジェクトで取得

=cut

sub get_region_rows_pref {
    my $self = shift;
    my $rows = $self->app->model->db->region->region_rows_pref();
    return $rows;
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
