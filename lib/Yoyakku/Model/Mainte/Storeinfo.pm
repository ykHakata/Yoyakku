package Yoyakku::Model::Mainte::Storeinfo;
use Mojo::Base 'Yoyakku::Model::Mainte';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Mainte::Storeinfo - storeinfo テーブル管理用 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Mainte::Storeinfo version 0.0.1

=head1 SYNOPSIS (概要)

    Storeinfo コントローラーのロジック API

=cut

=head2 search_zipcode_for_address

    郵便番号から住所を検索、値を返却

=cut

sub search_zipcode_for_address {
    my $self   = shift;
    my $params = shift;
    my $teng   = $self->teng();

    my $post_row = $teng->single( 'post', +{ post_id => $params->{post} }, );

    if ($post_row) {
        $params->{region_id} = $post_row->region_id;
        $params->{post}      = $post_row->post_id;
        $params->{state}     = $post_row->state;
        $params->{cities}    = $post_row->cities;
    }
    return $params;
}

=head2 writing_storeinfo

    storeinfo テーブル書込み、修正に対応

=cut

sub writing_storeinfo {
    my $self   = shift;
    my $params = shift;
    my $type   = shift;

    my $create_data = $self->get_create_data( 'storeinfo', $params );

    # update 以外は禁止
    die 'update only' if !$type || ( $type && $type ne 'update' );

    my $args = +{
        table       => 'storeinfo',
        create_data => $create_data,
        update_id   => $params->{id},
        type        => $type,
    };

    return $self->writing_from_db($args);
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::Model::Mainte>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
