package Yoyakku::DB::Model::Acting;
use Mojo::Base 'Yoyakku::DB::Model::Base';
use Yoyakku::Util qw{now_datetime};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::DB::Model::Acting - データベース Model

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::DB::Model::Acting version 0.0.1

=head1 SYNOPSIS (概要)

    acting テーブルの API を提供

=cut

has table => 'acting';

=head2 overlap_id

    general_id, storeinfo_id, 組み合わせの重複確認

=cut

sub overlap_id {
    my $self = shift;
    my $args = shift;
    my $teng = $self->teng();

    my $check_acting_row = $teng->single(
        $self->table,
        +{  general_id   => $args->{general_id},
            storeinfo_id => $args->{storeinfo_id},
            status       => $args->{status},
        },
    );
    return $check_acting_row;
}

=head2 writing

    テーブル書込み、新規、修正、両方に対応

=cut

sub writing {
    my $self   = shift;
    my $params = shift;
    my $type   = shift;

    my $create_data = +{
        general_id   => $params->{general_id}   || undef,
        storeinfo_id => $params->{storeinfo_id} || undef,
        status       => $params->{status},
        create_on    => now_datetime(),
        modify_on    => now_datetime(),
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
