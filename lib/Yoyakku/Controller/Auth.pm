package Yoyakku::Controller::Auth;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Auth;

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Auth->new();
    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session );
    return $model;
}

sub up_login {
    my $self  = shift;
    my $model = $self->_init();
    return $self->redirect_to('/index') if $model->check_login();
    $self->stash( class => 'up_login' );
    return $self->render( template => 'auth/up_login', format => 'html' );
}

sub up_logout {
    my $self = shift;
    my $model = $self->_init();
    return $self->redirect_to('/index') if $model->check_logout();
    $self->stash( class => 'up_logout' );
    $self->session( expires => 1 );
    return $self->render( template => 'auth/up_logout', format => 'html' );
}

sub up_login_general {
    my $self  = shift;
    my $model = $self->_init();

    $model->template('auth/up_login_general');

    return $self->redirect_to('/index') if $model->check_login();

    return $self->redirect_to('/up_login')
        if ( $model->method() ne 'GET' ) && ( $model->method() ne 'POST' );

    my $init_valid_params_auth = $model->get_init_valid_params_auth();

    $self->stash(
        class => 'up_login_general',
        %{$init_valid_params_auth},
    );

    return $self->render( template => $model->template(), format => 'html' )
        if 'GET' eq $model->method();

    return $self->_render_input_form( $model, 'general', );
};

sub up_login_admin {
    my $self  = shift;
    my $model = $self->_init();

    $model->template('auth/up_login_admin');

    return $self->redirect_to('/index') if $model->check_login();

    return $self->redirect_to('/up_login')
        if ( $model->method() ne 'GET' ) && ( $model->method() ne 'POST' );

    my $init_valid_params_auth = $model->get_init_valid_params_auth();

    $self->stash(
        class => 'up_login_admin',
        %{$init_valid_params_auth},
    );

    return $self->render( template => $model->template(), format => 'html' )
        if 'GET' eq $model->method();

    return $self->_render_input_form( $model, 'admin', );
};

sub root_login {
    my $self  = shift;
    my $model = $self->_init();

    $model->template('auth/root_login');

    return $self->redirect_to('/up_login')
        if ( $model->method() ne 'GET' ) && ( $model->method() ne 'POST' );

    my $init_valid_params_auth = $model->get_init_valid_params_auth();

    $self->stash(
        class => 'root_login',
        %{$init_valid_params_auth},
    );

    return $self->render( template => $model->template(), format => 'html' )
        if 'GET' eq $model->method();

    return $self->_render_input_form( $model, 'root', );
}

sub _render_input_form {
    my $self  = shift;
    my $model = shift;
    my $table = shift;

    # root ログインの場合は別処理(暫定)
    if ($table eq 'root') {

        my $valid_root_msg = $model->check_root_validator();

        return $self->stash($valid_root_msg), $self->_render_auth($model)
            if $valid_root_msg;

        # 合格の場合指定の画面へ遷移 (mainte_list) セッション書き込み
        return $self->session( root_id => $self->param('login') ),
            $self->redirect_to('mainte_list');
    }

    my $valid_msg = $model->check_auth_validator();

    return $self->stash($valid_msg), $self->_render_auth($model)
        if $valid_msg;

    my $valid_msg_db = $model->check_auth_validator_db($table);

    return $self->stash($valid_msg_db), $self->_render_auth($model)
        if $valid_msg_db;

    my $session_id_with_routing = $model->get_session_id_with_routing($table);

    my $session_name = 'session_' . $table . '_id';

    $self->session(
        $session_name => $session_id_with_routing->{session_id} );

    return $self->redirect_to( $session_id_with_routing->{redirect_to} );
}

sub _render_auth {
    my $self  = shift;
    my $model = shift;

    my $html = $self->render_to_string(
        template => $model->template(),
        format   => 'html',
    )->to_string;

    $model->html( \$html );
    my $output = $model->get_fill_in_auth();
    return $self->render( text => $output );
}

1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Controller::Auth - ログイン機能のコントローラー

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Controller::Auth version 0.0.1

=head1 SYNOPSIS (概要)

ログイン関連機能のリクエストをコントロール

=head2 up_login

    リクエスト
    URL: http:// ... /up_login
    METHOD: GET

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/auth/up_login

ログインフォーム入口画面の描写

=head2 up_login_general

    リクエスト
    URL: http:// ... /up_login_general
    METHOD: GET

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/auth/up_login_general

    リクエスト
    URL: http:// ... /up_login_general
    METHOD: POST
    PARAMETERS:
        login: (指定の ASCII 文字)
        password: (指定の ASCII 文字)

    レスポンス (ログイン成功、profile 設定が終了している)
    URL: http:// ... /index

    レスポンス (ログイン成功、profile 設定が終了していない)
    URL: http:// ... /profile

    レスポンス (ログイン失敗)
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/auth/up_login_general

一般ログイン

=head2 up_login_admin

    リクエスト
    URL: http:// ... /up_login_admin
    METHOD: GET

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/auth/up_login_admin

    リクエスト
    URL: http:// ... /up_login_admin
    METHOD: POST
    PARAMETERS:
        login: (指定の ASCII 文字)
        password: (指定の ASCII 文字)

    レスポンス (ログイン成功、profile 設定が終了している)
    URL: http:// ... /index

    レスポンス (ログイン成功、profile 設定が終了していない)
    URL: http:// ... /profile

    レスポンス (ログイン失敗)
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/auth/up_login_admin

店舗管理者用ログイン

=head2 root_login

    リクエスト
    URL: http:// ... /root_login
    METHOD: GET

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/auth/root_login

    リクエスト
    URL: http:// ... /root_login
    METHOD: POST
    PARAMETERS:
        login: (指定の ASCII 文字)
        password: (指定の ASCII 文字)

    レスポンス (ログイン成功)
    URL: http:// ... /mainte_list

    レスポンス (ログイン失敗)
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/auth/root_login

スーパーユーザー用ログイン

=head2 up_logout

    リクエスト
    URL: http:// ... /up_logout
    METHOD: GET

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/auth/up_logout

    レスポンス時に session データを消去

ログアウト機能

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<FormValidator::Lite>

=item * L<HTML::FillInForm>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
