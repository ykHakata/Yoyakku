package Yoyakku::Model::Admin;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model';
use Yoyakku::Util qw{get_fill_in_params};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Admin - 店舗管理 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Admin version 0.0.1

=head1 SYNOPSIS (概要)

    Admin コントローラーのロジック API

=cut

=head2 get_header_stash_admin

    ヘッダー初期値取得

=cut

sub get_header_stash_admin {
    my $self       = shift;
    my $table      = $self->login_table();
    my $login_row  = $self->login_row();
    my $login_name = $self->login_name();
    return 'index'   if !$login_row;
    return 'index'   if !$table;
    return 'index'   if $table ne 'admin';
    return 'profile' if !$login_row->status;
    my $switch_header = $self->storeinfo_row()->status() eq 0 ? 10 : 7;
    return $self->get_header_stash_params( $switch_header, $login_name );
}

=head2 get_switch_com

    左naviのコメント切替の為の変数

=cut

sub get_switch_com {
    my $self       = shift;
    my $switch_com = 1;
    return $switch_com;
}

=head2 get_fill_in_admin

    html パラメーターフィルイン

=cut

sub get_fill_in_admin {
    my $self   = shift;
    my $html   = $self->html();
    my $params = $self->params();
    my $output = get_fill_in_params( $html, $params );
    return $output;
}

=head2 get_login_storeinfo_params

    ログイン id から storeinfo のテーブルより該当レコード抽出

=cut

sub get_login_storeinfo_params {
    my $self   = shift;
    my $params = $self->login_storeinfo_row()->get_columns();
    $self->params($params);
    return $params;
}

=head2 get_login_storeinfo_id

    ログイン id から storeinfo の id 取得

=cut

sub get_login_storeinfo_id {
    my $self = shift;
    my $id   = $self->login_storeinfo_row()->id;
    $self->params( +{ id => $id } );
    return $id;
}

=head2 get_post_search

    郵便番号から住所検索

=cut

sub get_post_search {
    my $self   = shift;
    my $teng   = $self->teng();
    my $params = $self->params();
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
    $self->params($params);
    return;
}

=head2 get_init_valid_params_admin_store_edit

    バリデート用パラメータ初期値(admin_store_edit)

=cut

sub get_init_valid_params_admin_store_edit {
    my $self = shift;
    return $self->get_init_valid_params(
        [qw{name post state cities addressbelow tel mail remarks url }] );
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<parent>

=item * L<Yoyakku::Model>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
