package Yoyakku::DB::Model::Region;
use Mojo::Base 'Yoyakku::DB::Model::Base';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::DB::Model::Region - データベース Model

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::DB::Model::Region version 0.0.1

=head1 SYNOPSIS (概要)

    Region テーブルの API を提供

=cut

has table => 'region';

=head2 rows_all

    地域ID情報の全てを row オブジェクトで取得

=cut

sub rows_all {
    my $self = shift;
    my $teng = $self->teng();
    my @rows = $teng->search( $self->table, +{}, );
    return \@rows;
}

=head2 region_rows_pref

    地域ID情報、全国都道府県のみ row オブジェクトで取得

=cut

sub region_rows_pref {
    my $self = shift;
    my $teng = $self->teng();

    my $sql = q{
        SELECT id, name
        FROM region
        WHERE id REGEXP '(^[0-4][0-9])0{3}$'
        ORDER BY id ASC;
    };

    my @rows = $teng->search_named($sql);
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
