package Yoyakku::DB::Model::Admin;
use Mojo::Base 'Yoyakku::DB::Model::Base';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::DB::Model::Admin - データベース Model

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::DB::Model::Admin version 0.0.1

=head1 SYNOPSIS (概要)

    Admin テーブルの API を提供

=cut

has table => 'admin';

=head2 rows_all

    店舗ユーザー情報の全てを row オブジェクトで取得

=cut

sub rows_all {
    my $self = shift;
    my $teng = $self->teng();
    my @rows = $teng->search( $self->table, +{}, );
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
