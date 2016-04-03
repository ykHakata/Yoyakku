package Yoyakku::DB::Model::Reserve;
use Mojo::Base 'Yoyakku::DB::Model::Base';
use Yoyakku::Util qw{now_datetime};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::DB::Model::Reserve - データベース Model

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::DB::Model::Reserve version 0.0.1

=head1 SYNOPSIS (概要)

    Reserve テーブルの API を提供

=cut

has table => 'reserve';

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

=head2 writing

    テーブル書込み、新規、修正、両方に対応

=cut

sub writing {
    my $self   = shift;
    my $params = shift;
    my $type   = shift;

    my $create_data = +{
        roominfo_id   => $params->{roominfo_id},
        getstarted_on => $params->{getstarted_on},
        enduse_on     => $params->{enduse_on},
        useform       => $params->{useform},
        message       => $params->{message},
        general_id    => $params->{general_id},
        admin_id      => $params->{admin_id},
        tel           => $params->{tel},
        status        => $params->{status},
        create_on     => now_datetime(),
        modify_on     => now_datetime(),
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
