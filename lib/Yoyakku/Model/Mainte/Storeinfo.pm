package Yoyakku::Model::Mainte::Storeinfo;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model::Mainte';
use Yoyakku::Util qw{get_fill_in_params};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Mainte::Storeinfo - storeinfo テーブル管理用 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Mainte::Storeinfo version 0.0.1

=head1 SYNOPSIS (概要)

    Storeinfo コントローラーのロジック API

=cut

=head2 search_storeinfo_id_rows

    storeinfo テーブル一覧作成時に利用

=cut

sub search_storeinfo_id_rows {
    my $self = shift;
    return $self->search_id_single_or_all_rows( 'storeinfo',
        $self->params()->{storeinfo_id} );
}

sub get_init_valid_params_storeinfo {
    my $self = shift;
    return $self->get_init_valid_params(
        [   qw{name post state cities addressbelow tel mail remarks url
                locationinfor status }
        ]
    );
}

sub get_update_form_params_storeinfo {
    my $self = shift;
    $self->get_update_form_params('storeinfo');
    return $self;
}

=head2 search_zipcode_for_address

    郵便番号から住所を検索、値を返却

=cut

sub search_zipcode_for_address {
    my $self   = shift;
    my $params = $self->params();
    my $teng   = $self->teng();

    my $post_row = $teng->single( 'post', +{ post_id => $params->{post} }, );

    if ($post_row) {
        $params->{region_id} = $post_row->region_id;
        $params->{post}      = $post_row->post;
        $params->{state}     = $post_row->state;
        $params->{cities}    = $post_row->cities;
    }
    $self->params($params);
    return $self;
}

=head2 writing_storeinfo

    storeinfo テーブル書込み、修正に対応

=cut

sub writing_storeinfo {
    my $self = shift;

    my $create_data = $self->get_create_data('storeinfo');

    # update 以外は禁止
    die 'update only'
        if !$self->type() || ( $self->type() && $self->type() ne 'update' );

    return $self->writing_db( 'storeinfo', $create_data,
        $self->params()->{id} );
}

sub get_fill_in_storeinfo {
    my $self   = shift;
    my $html   = $self->html();
    my $params = $self->params();
    my $output = get_fill_in_params( $html, $params );
    return $output;
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<parent>

=item * L<Yoyakku::Model::Mainte>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
