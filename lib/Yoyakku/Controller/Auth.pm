package Yoyakku::Controller::Auth;
use Mojo::Base 'Mojolicious::Controller';
use FormValidator::Lite;
use HTML::FillInForm;
use Yoyakku::Model::Auth qw{check_valid_login};

sub up_login {
    my $self = shift;

    return $self->redirect_to('/index') if $self->_check_login();

    # テンプレート用bodyのクラス名
    my $class = 'up_login';

    $self->stash( class => $class );

    return $self->render( template => 'auth/up_login', format => 'html' );
}

sub up_login_general {
    my $self = shift;

    return $self->redirect_to('/index') if $self->_check_login();

    # テンプレート用bodyのクラス名
    my $class = 'up_login_general';

    $self->stash( class => $class );

    $self->stash(
        login    => '',
        password => '',
    );

    my $req    = $self->req;
    my $params = $req->params->to_hash;
    my $method = uc $req->method;

    # post の場合はバリデート
    return $self->render( template => 'auth/up_login_general', format => 'html' )
        if 'POST' ne $method;

    # バリデード実行
    my $validator = FormValidator::Lite->new($req);

    # 本来はデーターベースにアクセスするが暫定値でチェック
    $validator->check(
        login    => [ 'NOT_NULL', ],
        password => [ 'NOT_NULL', ],
    );

    $validator->set_message(
        'login.not_null'    => '必須入力',
        'password.not_null' => '必須入力',
    );

    my @login_errors = $validator->get_error_messages_from_param('login');
    my @pass_errors  = $validator->get_error_messages_from_param('password');

    $self->stash->{login}    = shift @login_errors;
    $self->stash->{password} = shift @pass_errors;

    # 入力された情報をもとにデータベースにアクセス、検証(general テーブル)
    # 入力値が存在する場合だけ問い合わせ
    my $check_routing;
    if ( !$validator->has_error() ) {
        $check_routing = $self->_make_msg_with_routing( 'general', $params );
    }

    # profile 設定による切り替え
    return $self->redirect_to('index')
        if $check_routing && $check_routing->{redirect_to} eq 'index';

    return $self->redirect_to('profile')
        if $check_routing && $check_routing->{redirect_to} eq 'profile';

    # エラー時の出力
    my $html = $self->render_to_string(
        template => 'auth/up_login_general',
        format   => 'html',
    )->to_string;

    my $output = HTML::FillInForm->fill( \$html, $params );

    # 不合格の場合 (入力値検証)
    return $self->render( text => $output ) if $validator->has_error();

    # 不合格の場合 (DB 検証)
    return $self->render( text => $output );
};

sub up_login_admin {
    my $self = shift;

    return $self->redirect_to('/index') if $self->_check_login();

    # テンプレート用bodyのクラス名
    my $class = "up_login_admin";

    $self->stash( class => $class );

    $self->stash(
        login    => '',
        password => '',
    );

    my $req    = $self->req;
    my $params = $req->params->to_hash;
    my $method = uc $req->method;

    # post の場合はバリデート
    return $self->render( template => 'auth/up_login_admin', format => 'html' )
        if 'POST' ne $method;

    # バリデード実行
    my $validator = FormValidator::Lite->new($req);

    # 本来はデーターベースにアクセスするが暫定値でチェック
    $validator->check(
        login    => [ 'NOT_NULL', ],
        password => [ 'NOT_NULL', ],
    );

    $validator->set_message(
        'login.not_null'    => '必須入力',
        'password.not_null' => '必須入力',
    );

    my @login_errors = $validator->get_error_messages_from_param('login');
    my @pass_errors  = $validator->get_error_messages_from_param('password');

    $self->stash->{login}    = shift @login_errors;
    $self->stash->{password} = shift @pass_errors;

    # 入力された情報をもとにデータベースにアクセス、検証(admin テーブル)
    # 入力値が存在する場合だけ問い合わせ
    my $check_routing;
    if ( !$validator->has_error() ) {
        $check_routing = $self->_make_msg_with_routing( 'admin', $params );
    }

    # profile 設定による切り替え
    return $self->redirect_to('index')
        if $check_routing && $check_routing->{redirect_to} eq 'index';

    return $self->redirect_to('profile')
        if $check_routing && $check_routing->{redirect_to} eq 'profile';

    # エラー時の出力
    my $html = $self->render_to_string(
        template => 'auth/up_login_admin',
        format   => 'html',
    )->to_string;

    my $output = HTML::FillInForm->fill( \$html, $params );

    # 不合格の場合 (入力値検証)
    return $self->render( text => $output ) if $validator->has_error();

    # 不合格の場合 (DB 検証)
    return $self->render( text => $output );
};

sub root_login {
    my $self = shift;

    # テンプレート用bodyのクラス名
    my $class = "root_login";

    $self->stash( class => $class );

    $self->stash(
        login    => '',
        password => '',
    );

    my $req    = $self->req;
    my $params = $req->params->to_hash;
    my $method = uc $req->method;

    # post の場合はバリデート
    return $self->render( template => 'auth/root_login', format => 'html' )
        if 'POST' ne $method;

    # バリデート実行
    my $validator = FormValidator::Lite->new($req);

    $validator->check(
        login    => [ 'NOT_NULL', [ EQUAL => 'yoyakku' ] ],
        password => [ 'NOT_NULL', [ EQUAL => '0520' ] ],
    );

    # 合格の場合指定の画面へ遷移 (mainte_list) セッション書き込み
    return
        $self->session( root_id => $self->param('login') ),
        $self->redirect_to('mainte_list')
        if !$validator->has_error();

    # バリデートエラー処理
    $validator->set_message(
        'login.not_null'    => '必須入力',
        'password.not_null' => '必須入力',
        'login.equal'       => 'ID違い',
        'password.equal'    => 'password違い',
    );

    my @login_errors = $validator->get_error_messages_from_param('login');
    my @pass_errors  = $validator->get_error_messages_from_param('password');

    $self->stash->{login}    = shift @login_errors;
    $self->stash->{password} = shift @pass_errors;

    my $html = $self->render_to_string(
        template => 'auth/root_login',
        format   => 'html',
    )->to_string;

    my $output = HTML::FillInForm->fill( \$html, $params );

    return $self->render( text => $output );
}

sub up_logout {
    my $self = shift;

    return $self->redirect_to('/index') if $self->_check_logout();

    # テンプレート用bodyのクラス名
    my $class = 'up_logout';

    $self->stash( class => $class );

    $self->session( expires => 1 );

    return $self->render( template => 'auth/up_logout', format => 'html' )
};

sub _make_msg_with_routing {
    my $self   = shift;
    my $table  = shift;
    my $params = shift;

    die '_make_msg_with_routing' if !$self || !$table || !$params;

    my $check_valid_login_routing = +{
        redirect_to => '',
    };

    my $check_valid = $self->check_valid_login($table, $params);

    # エラーメッセージ作成
    $self->stash->{login}    = $check_valid->{msg}->{login};
    $self->stash->{password} = $check_valid->{msg}->{password};

    # エラー時はセッション書き込みせず終了
    return $check_valid_login_routing if $check_valid->{error};

    # セッション書き込み
    my $session_name
        = $table eq 'general' ? 'session_general_id'
        : $table eq 'admin'   ? 'session_admin_id'
        :                       'session_id';

    $self->session( $session_name => $check_valid->{session_id} );

    $check_valid_login_routing->{redirect_to} = $check_valid->{check_profile};

    return $check_valid_login_routing;
}

sub _check_login {
    my $self = shift;

    return 1
        if $self->session->{session_general_id}
        || $self->session->{session_admin_id};

    return;
}

sub _check_logout {
    my $self = shift;

    return 1
        if !$self->session->{session_general_id}
        && !$self->session->{session_admin_id};

    return;
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
