package Yoyakku::DB::Model::Storeinfo;
use Mojo::Base 'Yoyakku::DB::Model::Base';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::DB::Model::Storeinfo - データベース Model

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::DB::Model::Storeinfo version 0.0.1

=head1 SYNOPSIS (概要)

    Storeinfo テーブルの API を提供

=cut

has table => 'storeinfo';

=head2 rows_all

    店舗情報の全てを row オブジェクトで取得

=cut

sub rows_all {
    my $self = shift;
    my $teng = $self->teng();
    my @rows = $teng->search( $self->table, +{}, );
    return \@rows;
}

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

=head2 storeinfo_rows_region_navi

    地域ナビため、店舗登録をすべて抽出(web公開許可分だけ)

=cut

sub storeinfo_rows_region_navi {
    my $self = shift;
    my $teng = $self->teng();
    my @rows = $teng->search(
        $self->table,
        +{ status   => 0, },
        +{ order_by => 'region_id', },
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
