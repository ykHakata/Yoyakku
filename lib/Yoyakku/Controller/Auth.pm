package Yoyakku::Controller::Auth;
use Mojo::Base 'Mojolicious::Controller';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Auth - ログイン機能のコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Auth version 0.0.1

=head1 SYNOPSIS (概要)

    ログイン関連機能のリクエストをコントロール

=cut

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

sub index {
    my $self  = shift;
    my $model = $self->model->auth;

    return $self->redirect_to('index')
        if ( uc $self->req->method ne 'GET' )
        && ( uc $self->req->method ne 'POST' );

    $self->stash->{params} = $self->req->params->to_hash;

    my $path = $self->req->url->path->to_abs_string;

    return $self->up_login()         if $path eq '/up_login';
    return $self->up_login_general() if $path eq '/up_login_general';
    return $self->up_login_admin()   if $path eq '/up_login_admin';
    return $self->root_login()       if $path eq '/root_login';
    return $self->up_logout()        if $path eq '/up_logout';
    return $self->redirect_to('index');
}

=head2 up_login

    ログインフォーム入口画面の描写

=cut

sub up_login {
    my $self = shift;

    my $exists_session = $self->model->auth->logged_in( $self->session );
    return $self->redirect_to('index')
        if $exists_session && $exists_session eq 1;

    $self->stash(
        class    => 'up_login',
        template => 'auth/up_login',
        format   => 'html',
    );
    return $self->render();
}

=head2 up_logout

    ログアウト機能 (レスポンス時に session データを消去)

=cut

sub up_logout {
    my $self = shift;

    return $self->redirect_to('index')
        if !$self->model->auth->logged_in( $self->session );

    $self->stash(
        class    => 'up_logout',
        template => 'auth/up_logout',
        format   => 'html',
    );
    $self->session( expires => 1 );
    return $self->render();
}


=head2 up_login_admin

    店舗管理者用ログイン

    レスポンス (ログイン成功、profile 設定が終了している)
    URL: http:// ... /index

    レスポンス (ログイン成功、profile 設定が終了していない)
    URL: http:// ... /profile

    レスポンス (ログイン失敗)
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/auth/up_login_admin

=cut

sub up_login_admin {
    my $self  = shift;

    my $exists_session = $self->model->auth->logged_in( $self->session );
    return $self->redirect_to('index')
        if $exists_session && $exists_session eq 1;

    my $valid_params = $self->model->auth->get_valid_params('auth');

    $self->stash(
        class    => 'up_login_admin',
        template => 'auth/up_login_admin',
        format   => 'html',
        %{$valid_params},
    );
    return $self->render() if 'GET' eq uc $self->req->method;
    return $self->_render_input_form('admin');
};

=head2 up_login_general

    一般ユーザー用ログイン

    レスポンス (ログイン成功、profile 設定が終了している)
    URL: http:// ... /index

    レスポンス (ログイン成功、profile 設定が終了していない)
    URL: http:// ... /profile

    レスポンス (ログイン失敗)
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/auth/up_login_general

=cut

sub up_login_general {
    my $self  = shift;

    my $exists_session = $self->model->auth->logged_in( $self->session );
    return $self->redirect_to('index')
        if $exists_session && $exists_session eq 1;

    my $valid_params = $self->model->auth->get_valid_params('auth');

    $self->stash(
        class    => 'up_login_general',
        template => 'auth/up_login_general',
        format   => 'html',
        %{$valid_params},
    );
    return $self->render() if 'GET' eq uc $self->req->method;
    return $self->_render_input_form('general');
};


=head2 root_login

    スーパーユーザー用ログイン

=cut

sub root_login {
    my $self  = shift;

    my $session = $self->model->auth->logged_in( $self->session );
    return $self->redirect_to('index') if $session && $session eq 2;

    my $valid_params = $self->model->auth->get_valid_params('auth');

    $self->stash(
        class    => 'root_login',
        template => 'auth/root_login',
        format   => 'html',
        %{$valid_params},
    );
    return $self->render() if 'GET' eq uc $self->req->method;
    return $self->_render_input_form('root');
}

sub _render_input_form {
    my $self  = shift;
    my $table = shift;
    my $model = $self->model->auth();

    # root ログインの場合は別処理(暫定)
    if ($table eq 'root') {
        my $valid_msg
            = $model->check_validator( $table, $self->stash->{params} );

        return $self->stash($valid_msg), $self->_render_auth()
            if $valid_msg;

        # 合格の場合指定の画面へ遷移 (mainte_list) セッション書き込み
        $self->session( root_id => $self->param('login') );
        $self->redirect_to('mainte_list');
        return;
    }

    my $valid_msg = $model->check_validator( $table, $self->stash->{params} );

    return $self->stash($valid_msg), $self->_render_auth()
        if $valid_msg;

    my $valid_msg_db
        = $model->check_auth_validator_db( $table, $self->stash->{params} );

    return $self->stash($valid_msg_db), $self->_render_auth()
        if $valid_msg_db;

    my $session_id_with_routing = $model->get_session_id_with_routing( $table,
        $self->stash->{params} );

    my $session_name = 'session_' . $table . '_id';

    $self->session(
        $session_name => $session_id_with_routing->{session_id} );

    return $self->redirect_to( $session_id_with_routing->{redirect_to} );
}

sub _render_auth {
    my $self = shift;
    my $html = $self->render_to_string->to_string;
    my $args = +{
        html   => \$html,
        params => $self->stash->{params},
    };
    my $output = $self->model->auth->set_fill_in_params($args);
    return $self->render( text => $output );
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
