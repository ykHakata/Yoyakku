package Yoyakku::Controller::Setting::Roominfo;
use Mojo::Base 'Mojolicious::Controller';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Setting::Roominfo - 店舗管理のコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Setting::Roominfo version 0.0.1

=head1 SYNOPSIS (概要)

    店舗管理、関連機能のリクエストをコントロール

=cut

sub index {
    my $self  = shift;
    my $model = $self->model->setting->roominfo;

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

    return $self->admin_reserv_edit() if $path eq '/admin_reserv_edit';
    return $self->up_admin_r_d_edit() if $path eq '/up_admin_r_d_edit';
    return $self->admin_reserv_comp() if $path eq '/admin_reserv_comp';
    return $self->admin_pub_edit()    if $path eq '/admin_pub_edit';
    return $self->admin_pub_comp()    if $path eq '/admin_pub_comp';
    return $self->redirect_to('index');
}

=head2 admin_reserv_edit

    予約部屋情報設定コントロール

=cut

sub admin_reserv_edit {
    my $self  = shift;
    my $model = $self->model->setting->roominfo;

    my $valid_params = $model->get_valid_params('admin_reserv_edit');
    my $switch_com   = $model->get_switch_com('admin_reserv_edit');

    $self->stash(
        class      => 'admin_reserv_edit',
        switch_com => $switch_com,
        template   => 'setting/admin_reserv_edit',
        format     => 'html',
        %{$valid_params},
    );

    if ( 'GET' eq uc $self->req->method ) {
        $self->stash->{params}
            = $model->set_roominfo_params( $self->stash->{login_row} );
        return $self->_render_fill_in_form();
    }

    return $self->_cancel() if $self->stash->{params}->{cancel};
    return $self->_update();
}

=head2 up_admin_r_d_edit

    予約部屋詳細設定コントロール

=cut

sub up_admin_r_d_edit {
    my $self  = shift;
    my $model = $self->model->setting->roominfo;

    my $valid_params = $model->get_valid_params('up_admin_r_d_edit');
    my $switch_com   = $model->get_switch_com('up_admin_r_d_edit');

    $self->stash(
        class      => 'admin_reserv_edit',
        switch_com => $switch_com,
        template   => 'setting/up_admin_r_d_edit',
        format     => 'html',
        %{$valid_params},
    );

    if ( 'GET' eq uc $self->req->method ) {
        $self->stash->{params}
            = $model->set_roominfo_params( $self->stash->{login_row} );
        return $self->_render_fill_in_form();
    }

    $self->stash( +{ action => 'up_admin_r_d_edit' } );

    # この cancel は戻るボタンとして機能
    return $self->_cancel() if $self->stash->{params}->{cancel};
    return $self->_update();
}

=head2 admin_reserv_comp

    予約部屋詳細設定コントロール

=cut

sub admin_reserv_comp {
    my $self  = shift;
    my $model = $self->model->setting->roominfo;

    my $switch_com = $model->get_switch_com('admin_reserv_comp');

    $self->stash(
        class      => 'admin_reserv_comp',
        switch_com => $switch_com,
        template   => 'setting/admin_reserv_comp',
        format     => 'html',
    );

    if ( 'GET' eq uc $self->req->method ) {
        $self->stash->{params}
            = $model->set_admin_reserv_comp_params(
            $self->stash->{login_row} );
        return $self->_render_fill_in_form();
    }

    return;
}

=head2 admin_pub_edit

    予約部屋、web公開設定コントロール

=cut

sub admin_pub_edit {
    my $self  = shift;
    my $model = $self->model->setting->roominfo;

    my $switch_com = $model->get_switch_com('admin_pub_edit');

    $self->stash(
        class      => 'admin_pub_edit',
        switch_com => $switch_com,
        template   => 'setting/admin_pub_edit',
        format     => 'html',
    );

    if ( 'GET' eq uc $self->req->method ) {
        $self->stash->{params}
            = $model->set_roominfo_params( $self->stash->{login_row} );
        return $self->_render_fill_in_form();
    }

    $self->stash( +{ action => 'admin_pub_edit' } );

    # この cancel は戻るボタンとして機能
    return $self->_cancel() if $self->stash->{params}->{cancel};
    return $self->_update();
}

=head2 admin_pub_comp

    予約部屋、公開設定確認コントロール

=cut

sub admin_pub_comp {
    my $self  = shift;
    my $model = $self->model->setting->roominfo;

    my $switch_com = $model->get_switch_com('admin_pub_comp');

    $self->stash(
        class      => 'admin_pub_comp',
        switch_com => $switch_com,
        template   => 'setting/admin_pub_comp',
        format     => 'html',
    );

    if ( 'GET' eq uc $self->req->method ) {
        $self->stash->{params}
            = $model->set_admin_pub_comp_params( $self->stash->{login_row} );
        return $self->_render_fill_in_form();
    }

    return;
}

sub _cancel {
    my $self = shift;

    #リダイレクトで予約情報設定完了の画面に戻す
    if ( $self->stash('action') eq 'admin_pub_edit' ) {
        return $self->redirect_to('admin_reserv_comp');
    }

    #リダイレクトで設定の最初の画面に戻す
    if ( $self->stash('action') eq 'up_admin_r_d_edit' ) {
        return $self->redirect_to('admin_reserv_edit');
    }

    $self->stash->{params} = undef;
    $self->stash->{params}->{id}
        = $self->stash->{login_row}->fetch_storeinfo->get_roominfo_ids;
    return $self->_render_fill_in_form();
}

sub _update {
    my $self  = shift;
    my $model = $self->model->setting->roominfo;

    $self->stash->{type} = 'update';

    my $check_params
        = $model->get_check_params_list( $self->stash->{params} );

    my $validator_check = 'roominfo';

    if ( $self->stash('action') eq 'up_admin_r_d_edit' ) {
        $validator_check = 'up_admin_r_d_edit';
    }

    # バリデートしない
    if ( $self->stash('action') eq 'admin_pub_edit' ) {
        for my $check_param ( @{$check_params} ) {
            $model->writing_admin_pub_edit( $check_param,
                $self->stash->{type},
            );
        }
        return $self->redirect_to('admin_pub_comp');
    }

    for my $check_param ( @{$check_params} ) {
        my $valid_msg = $self->model->validator->check( $validator_check,
            $check_param );
        return $self->stash($valid_msg), $self->_render_fill_in_form()
            if $valid_msg;
    }

    if ( $self->stash('action') eq 'up_admin_r_d_edit' ) {
        for my $check_param ( @{$check_params} ) {
            $model->writing_up_admin_r_d_edit( $check_param,
                $self->stash->{type},
            );
        }
        return $self->redirect_to('admin_reserv_comp');
    }

    for my $check_param ( @{$check_params} ) {
        $model->writing_admin_reserv( $check_param, $self->stash->{type}, );
    }

    return $self->redirect_to('up_admin_r_d_edit');
}

sub _render_fill_in_form {
    my $self = shift;
    my $html = $self->render_to_string->to_string;
    my $args = +{
        html   => \$html,
        params => $self->stash->{params},
    };
    my $output = $self->model->setting->roominfo->set_fill_in_params($args);
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

# スタートガイドは管理者idでログインし、店舗web公開しない->1の時に限り表示し、
# 店舗web公開する->0の時は管理者ナビゲートを表示
# 店舗情報を後から変更したいときは、パンくずリストをクリックすると移動できるようにする。
