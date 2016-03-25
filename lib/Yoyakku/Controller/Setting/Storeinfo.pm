package Yoyakku::Controller::Setting::Storeinfo;
use Mojo::Base 'Mojolicious::Controller';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Setting::Storeinfo - 店舗管理のコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Setting::Storeinfo version 0.0.1

=head1 SYNOPSIS (概要)

    店舗管理、関連機能のリクエストをコントロール

=cut

sub index {
    my $self  = shift;
    my $model = $self->model->setting->storeinfo;

    return $self->redirect_to('index')
        if ( uc $self->req->method ne 'GET' )
        && ( uc $self->req->method ne 'POST' );

    $self->stash->{login_row}
        = $self->model->auth->get_logged_in_row( $self->session );
    return $self->redirect_to('index') if !$self->stash->{login_row};

    my $redirect_mode
        = $model->get_redirect_mode( $self->stash->{login_row} );

    return $self->redirect_to('index')
        if $redirect_mode && $redirect_mode eq 'index';

    return $self->redirect_to('profile')
        if $redirect_mode && $redirect_mode eq 'profile';

    my $header_stash
        = $model->get_setting_header_stash( $self->stash->{login_row} );

    $self->stash($header_stash);
    $self->stash->{params} = $self->req->params->to_hash;

    my $path = $self->req->url->path->to_abs_string;

    return $self->admin_store_edit() if $path eq '/admin_store_edit';
    return $self->admin_store_comp() if $path eq '/admin_store_comp';
    return $self->redirect_to('index');
}

=head2 admin_store_edit

    選択店舗情報確認コントロール

=cut

sub admin_store_edit {
    my $self  = shift;
    my $model = $self->model->setting->storeinfo;

    my $valid_params = $model->get_valid_params('admin_store_edit');
    my $switch_com   = $model->get_switch_com('admin_store_edit');

    $self->stash(
        class      => 'admin_store_edit',
        switch_com => $switch_com,
        template   => 'setting/admin_store_edit',
        format     => 'html',
        %{$valid_params},
    );

    if ( 'GET' eq uc $self->req->method ) {
        $self->stash->{params}
            = $self->stash->{login_row}->fetch_storeinfo->get_columns;
        return $self->_render_fill_in_form();
    }

    return $self->_cancel()      if $self->stash->{params}->{cancel};
    return $self->_post_search() if $self->stash->{params}->{post_search};
    return $self->_update();
}

sub _cancel {
    my $self = shift;
    $self->stash->{params} = undef;
    $self->stash->{params}->{id}
        = $self->stash->{login_row}->fetch_storeinfo->id;
    return $self->_render_fill_in_form();
}

sub _post_search {
    my $self  = shift;
    my $model = $self->model->setting->storeinfo;

    $self->stash->{params}
        = $model->get_post_search( $self->stash->{params} );

    return $self->_render_fill_in_form();
}

sub _update {
    my $self  = shift;
    $self->stash->{type} = 'update';
    return $self->_common();
}

sub _common {
    my $self  = shift;
    my $model = $self->model->setting->storeinfo;
    my $valid_msg
        = $self->model->validator->check( 'storeinfo', $self->stash->{params} );
    return $self->stash($valid_msg), $self->_render_fill_in_form()
        if $valid_msg;
    $model->writing_admin_store(
        $self->stash->{params},
        $self->stash->{type},
    );
    return $self->redirect_to('admin_store_comp');
}

sub _render_fill_in_form {
    my $self = shift;
    my $html = $self->render_to_string->to_string;
    my $args = +{
        html   => \$html,
        params => $self->stash->{params},
    };
    my $output = $self->model->setting->storeinfo->set_fill_in_params($args);
    return $self->render( text => $output );
}

=head2 admin_store_comp

    店舗情報確認画面

=cut

sub admin_store_comp {
    my $self = shift;

    my $switch_com
        = $self->model->setting->storeinfo->get_switch_com('admin_store_comp');

    $self->stash(
        class         => 'admin_store_comp',
        switch_com    => $switch_com,
        storeinfo_row => $self->stash->{login_row}->fetch_storeinfo,
        template      => 'setting/admin_store_comp',
        format        => 'html',
    );
    $self->render();
    return;
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
