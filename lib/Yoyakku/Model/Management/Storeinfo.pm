package Yoyakku::Model::Management::Storeinfo;
use Mojo::Base 'Yoyakku::Model::Management::Base';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Management::Storeinfo - 店舗管理 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Management::Storeinfo version 0.0.1

=head1 SYNOPSIS (概要)

    Management::Storeinfo コントローラーのロジック API

=cut

=head2 get_post_search

    郵便番号から住所検索

=cut

sub get_post_search {
    my $self   = shift;
    my $params = shift;
    my $row = $self->app->model->db->post->single_row_search_post_id( $params->{post} );
    if ($row) {
        $params->{post}      = $row->post_id;
        $params->{region_id} = $row->region_id;
        $params->{state}     = $row->state;
        $params->{cities}    = $row->cities;
    }
    else {
        $params->{region_id} = 0;
        $params->{state}     = '登録なし';
        $params->{cities}    = '登録なし';
    }
    return $params;
}

=head2 writing_admin_store

    storeinfo テーブル書込み、修正に対応

=cut

sub writing_admin_store {
    my $self   = shift;
    my $params = shift;
    my $type   = shift;

    my $create_data
        = $self->app->model->db->storeinfo->get_create_data($params);

    # 不要なカラムを削除
    delete $create_data->{admin_id};
    delete $create_data->{locationinfor};
    delete $create_data->{status};

    # update 以外は禁止
    die 'update only' if !$type || ( $type && $type ne 'update' );

    my $args = +{
        table       => 'storeinfo',
        create_data => $create_data,
        update_id   => $params->{id},
        type        => $type,
    };

    return $self->app->model->db->base->writing_db($args);
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::Model::Management>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
