package Yoyakku::DB::Model::Roominfo;
use Mojo::Base 'Yoyakku::DB::Model::Base';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::DB::Model::Roominfo - データベース Model

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::DB::Model::Roominfo version 0.0.1

=head1 SYNOPSIS (概要)

    Roominfo テーブルの API を提供

=cut

has table => 'roominfo';

=head2 single_row_search_id

    id に該当するレコードを row オブジェクトで取得

=cut

sub single_row_search_id {
    my $self = shift;
    my $id   = shift;
    my $teng = $self->teng();
    my $row  = $teng->single( $self->table, +{ id => $id, }, );
    return $row;
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
