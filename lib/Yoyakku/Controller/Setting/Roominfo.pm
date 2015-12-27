package Yoyakku::Controller::Setting::Roominfo;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Setting::Roominfo;

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Setting::Roominfo - 店舗管理のコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Setting::Roominfo version 0.0.1

=head1 SYNOPSIS (概要)

    店舗管理、関連機能のリクエストをコントロール

=cut

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Setting::Roominfo->new();
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

=head2 admin_reserv_edit

    予約部屋情報設定コントロール

=cut

sub admin_reserv_edit {
    my $self = shift;

    my $model = $self->_init();
    return $self->redirect_to($model) if $model eq 'index';
    return $self->redirect_to($model) if $model eq 'profile';
    return $self->redirect_to('index')
        if ( $model->method() ne 'GET' ) && ( $model->method() ne 'POST' );

    my $init_valid_params_admin_reserv_edit
        = $model->get_init_valid_params_admin_reserv_edit();

    my $switch_com = $model->get_switch_com('admin_reserv_edit');
    $self->stash(
        class      => 'admin_reserv_edit',
        switch_com => $switch_com,
        %{$init_valid_params_admin_reserv_edit},
    );

    $model->template('setting/admin_reserv_edit');

    if ( 'GET' eq $model->method() ) {
        $model->set_roominfo_params();
        return $self->_render_fill_in_form($model);
    }
    my $params = $model->params();
    return $self->_cancel($model) if $params->{cancel};
    return $self->_update($model);
}

sub _cancel {
    my $self  = shift;
    my $model = shift;
    $model->get_login_roominfo_ids();
    return $self->_render_fill_in_form($model);
}

sub _update {
    my $self  = shift;
    my $model = shift;

    $model->type('update');

    my $check_params = $model->get_check_params_list();

    for my $check_param ( @{$check_params} ) {
        my $valid_msg = $model->check_validator( 'roominfo', $check_param );
        return $self->stash($valid_msg), $self->_render_fill_in_form($model)
            if $valid_msg;
    }

    for my $check_param ( @{$check_params} ) {
        $model->writing_admin_reserv($check_param);
    }

    return $self->redirect_to('up_admin_r_d_edit');
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

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Setting::Roominfo>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
