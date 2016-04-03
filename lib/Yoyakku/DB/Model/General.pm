package Yoyakku::DB::Model::General;
use Mojo::Base 'Yoyakku::DB::Model::Base';
use Yoyakku::Util qw{now_datetime};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::DB::Model::General - データベース Model

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::DB::Model::General version 0.0.1

=head1 SYNOPSIS (概要)

    general テーブルの API を提供

=cut

has table => 'general';

=head2 rows_all

    一般ユーザー情報の全てを row オブジェクトで取得

=cut

sub rows_all {
    my $self = shift;
    my $teng = $self->teng();
    my @rows = $teng->search( $self->table, +{}, );
    return \@rows;
}

=head2 writing

    テーブル書込み、新規、修正、両方に対応

=cut

sub writing {
    my $self   = shift;
    my $params = shift;
    my $type   = shift;

    my $create_data = +{
            login     => $params->{login},
            password  => $params->{password},
            status    => $params->{status},
            create_on => now_datetime(),
            modify_on => now_datetime(),
    };

    my $args = +{
        table       => $self->table,
        create_data => $create_data,
        update_id   => $params->{id},
        type        => $type,
    };

    return $self->writing_db($args);
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::DB::Model::Base>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
