package Yoyakku::Model::Setting::Storeinfo;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model::Setting';
use Yoyakku::Util qw{get_fill_in_params};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Setting::Storeinfo - 店舗管理 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Setting::Storeinfo version 0.0.1

=head1 SYNOPSIS (概要)

    Setting::Storeinfo コントローラーのロジック API

=cut

=head2 get_post_search

    郵便番号から住所検索

=cut

sub get_post_search {
    my $self   = shift;
    my $params = shift;
    my $teng   = $self->teng();
    my $row    = $teng->single( 'post', +{ post_id => $params->{post}, }, );
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

=head2 get_init_valid_params_admin_store_edit

    バリデート用パラメータ初期値(admin_store_edit)

=cut

sub get_init_valid_params_admin_store_edit {
    my $self = shift;
    return $self->get_init_valid_params(
        [qw{name post state cities addressbelow tel mail remarks url }] );
}

=head2 writing_admin_store

    storeinfo テーブル書込み、修正に対応

=cut

sub writing_admin_store {
    my $self   = shift;
    my $params = shift;

    my $create_data = $self->get_create_data( 'storeinfo', $params );

    # 不要なカラムを削除
    delete $create_data->{admin_id};
    delete $create_data->{locationinfor};
    delete $create_data->{status};

    # update 以外は禁止
    die 'update only'
        if !$self->type() || ( $self->type() && $self->type() ne 'update' );

    return $self->writing_db( 'storeinfo', $create_data, $params->{id} );
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<parent>

=item * L<Yoyakku::Model::Setting>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
