package Yoyakku::Controller::Setting::Storeinfo;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Setting::Storeinfo;

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Setting::Storeinfo - 店舗管理のコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Setting::Storeinfo version 0.0.1

=head1 SYNOPSIS (概要)

    店舗管理、関連機能のリクエストをコントロール

=cut

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Setting::Storeinfo->new();
    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session );
    $model->check_auth_db_yoyakku();
    my $header_stash = $model->get_header_stash_admin();
    return $header_stash if $header_stash eq 'index';
    return $header_stash if $header_stash eq 'profile';
    $self->stash($header_stash);
    return $model;
}

=head2 admin_store_edit

    選択店舗情報確認コントロール

=cut

sub admin_store_edit {
    my $self = shift;

    my $model = $self->_init();
    return $self->redirect_to($model) if $model eq 'index';
    return $self->redirect_to($model) if $model eq 'profile';
    return $self->redirect_to('index')
        if ( $model->method() ne 'GET' ) && ( $model->method() ne 'POST' );

    my $init_valid_params_admin_store_edit
        = $model->get_init_valid_params_admin_store_edit();

    my $switch_com = $model->get_switch_com('admin_store_edit');
    $self->stash(
        class      => 'admin_store_edit',
        switch_com => $switch_com,
        %{$init_valid_params_admin_store_edit},
    );

    $model->template('setting/admin_store_edit');

    if ( 'GET' eq $model->method() ) {
        $model->get_login_storeinfo_params();
        return $self->_render_fill_in_form($model);
    }
    my $params = $model->params();
    return $self->_cancel($model)      if $params->{cancel};
    return $self->_post_search($model) if $params->{post_search};
    return $self->_update($model);
}

sub _cancel {
    my $self  = shift;
    my $model = shift;
    $model->get_login_storeinfo_id();
    return $self->_render_fill_in_form($model);
}

sub _post_search {
    my $self  = shift;
    my $model = shift;
    $model->get_post_search();
    return $self->_render_fill_in_form($model);
}

sub _update {
    my $self  = shift;
    my $model = shift;
    $model->type('update');
    return $self->_common($model);
}

sub _common {
    my $self  = shift;
    my $model = shift;

    my $valid_msg = $model->check_admin_store_validator();

    return $self->stash($valid_msg), $self->_render_fill_in_form($model)
        if $valid_msg;

    $model->writing_admin_store();

    return $self->redirect_to('admin_store_comp');
}

sub _render_fill_in_form {
    my $self  = shift;
    my $model = shift;

    my $html = $self->render_to_string(
        template => $model->template(),
        format   => 'html',
    )->to_string;

    $model->html( \$html );
    my $output = $model->set_fill_in_params();
    return $self->render( text => $output );
}

sub admin_store_comp {
    my $self = shift;

    my $model = $self->_init();
    return $self->redirect_to($model) if $model eq 'index';
    return $self->redirect_to($model) if $model eq 'profile';
    return $self->redirect_to('index')
        if ( $model->method() ne 'GET' ) && ( $model->method() ne 'POST' );

    my $switch_com = $model->get_switch_com('admin_store_comp');
    $self->stash(
        class         => 'admin_store_comp',
        switch_com    => $switch_com,
        storeinfo_row => $model->login_storeinfo_row,
    );
    $self->render( template => 'setting/admin_store_comp', format => 'html' );
    return;
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Setting::Storeinfo>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
