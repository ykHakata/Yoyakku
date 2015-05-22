package Yoyakku::Controller::Auth;
use Mojo::Base 'Mojolicious::Controller';
use FormValidator::Lite;
use HTML::FillInForm;

sub up_login {
    my $self = shift;

    # テンプレート用bodyのクラス名
    my $class = 'up_login';

    $self->stash( class => $class );

    return $self->render( template => 'auth/up_login', format => 'html' );
}

sub up_login_general {
    my $self = shift;

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
    my $db_error;

    if ( !$validator->has_error() ) {
        # my $general_row
        #     = $teng->single( 'general', +{ login => $params->{login} } );

        # 不合格の場合 (DB検証 メルアド違い)
        # if ( !$general_row ) {
        #     $self->stash->{login} = 'メールアドレス違い';
        #     $db_error = 1;
        # }

        # 不合格の場合 (DB検証 パスワード違い)
        # if ( $general_row && $general_row->password ne $params->{password} ) {
        #     $self->stash->{password} = 'パスワードが違います';
        #     $db_error = 1;
        # }

        # my $general_id = $general_row->id;

        # DB を実装していないので暫定の処置 ####
        # 不合格の場合 (メルアド違い)
        if ( 'yoyakku' ne $params->{login} ) {
            $self->stash->{login} = 'メールアドレス違い';
            $db_error = 1;
        }

        # 不合格の場合 (パスワード違い)
        if ( '0520' ne $params->{password} ) {
            $self->stash->{password} = 'パスワードが違います',;
            $db_error = 1;
        }

        my $general_id = '10';

        # リダイレクト先を選択するための検証(profile テーブル)
        # my $profile_row
        #     = $teng->single( 'profile', +{ general_id => $general_id } );

        # if ( !$profile_row ) {
        #     $self->stash->{login} = '管理者へ連絡ください',
        #     $db_error = 1;
        # }

        # my $status = $profile_row->status;

        my $status = '1'; # 暫定値

        #セッション書き込み
        $self->session(session_general_id => $general_id);

        # profile 設定が終了している
        return $self->redirect_to('index') if $status && !$db_error;

        # profile 設定が終了してない
        return $self->redirect_to('profile') if !$db_error;
    }

    # エラー時の出力
    my $html = $self->render_to_string(
        templates => 'auth/up_login_general',
        format    => 'html',
    )->to_string;

    my $output = HTML::FillInForm->fill( \$html, $params );

    # 不合格の場合 (入力値検証)
    return $self->render( text => $output ) if $validator->has_error();

    # 不合格の場合 (DB 検証)
    return $self->render( text => $output );
};

sub up_login_admin {
    my $self = shift;

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
    my $db_error;
    if ( !$validator->has_error() ) {
        # my $admin_row
        #     = $teng->single( 'admin', +{ login => $params->{login} } );

        # 不合格の場合 (DB検証 メルアド違い)
        # if ( !$admin_row ) {
        #     $self->stash->{login} = 'メールアドレス違い';
        #     $db_error = 1;
        # }

        # 不合格の場合 (DB検証 パスワード違い)
        # if ( $admin_row && $admin_row->password ne $params->{password} ) {
        #     $self->stash->{password} = 'パスワードが違います';
        #     $db_error = 1;
        # }

        # my $admin_id = $admin_row->id;

        # DB を実装していないので暫定の処置 ####
        # 不合格の場合 (メルアド違い)
        if ( 'yoyakku' ne $params->{login} ) {
            $self->stash->{login} = 'メールアドレス違い';
            $db_error = 1;
        }

        # 不合格の場合 (パスワード違い)
        if ( '0520' ne $params->{password} ) {
            $self->stash->{password} = 'パスワードが違います',;
            $db_error = 1;
        }

        my $admin_id = '10';

        # リダイレクト先を選択するための検証(profile テーブル)
        # my $profile_row
        #     = $teng->single( 'profile', +{ admin_id => $admin_id } );

        # if ( !$profile_row ) {
        #     $self->stash->{login} = '管理者へ連絡ください',
        #     $db_error = 1;
        # }

        # my $status = $profile_row->status;

        my $status = '1'; # 暫定値

        #セッション書き込み
        $self->session(session_admin_id => $admin_id);

        # profile 設定が終了している
        return $self->redirect_to('index') if $status && !$db_error;

        # profile 設定が終了してない
        return $self->redirect_to('profile') if !$db_error;
    }

    # エラー時の出力
    my $html = $self->render_to_string(
        templates => 'auth/up_login_admin',
        format    => 'html',
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
        templates => 'auth/root_login',
        format    => 'html',
    )->to_string;

    my $output = HTML::FillInForm->fill( \$html, $params );

    return $self->render( text => $output );
}

1;

__END__


# up_login_general.html.ep
# ログインフォーム、一般（テスト用）フォーム========================================
any '/up_login_general' => sub {
my $self = shift;
# テンプレート用bodyのクラス名
my $class = "up_login_admin";
$self->stash(class => $class);


if (uc $self->req->method eq 'POST') {
    #ログイン押すとpostで入ってくる、バリデード実行
    my $validator = $self->create_validator;
    $validator->field('login')->required(1)->length(1,50)->callback(sub {
        my $login    = shift;
        my $password = $self->param('password');

        my $judg_login = 0;
        my $general_ref      = $teng->single('general', +{login => $login});

        my $login_name    ;
        my $login_password;

        if ($general_ref) {
            $login_name     = $general_ref->login;
            $login_password = $general_ref->password;
            if ($login_name eq $login and $login_password ne $password) {
                $judg_login = 2 ;
            }
        }
        else {
            $judg_login = 1 ;
        }

        return   ($judg_login == 1) ? (0, 'メールアドレス違い'  )
               : ($judg_login == 2) ? (0, 'パスワードが違います')
               :                       1
               ;
    });
    $validator->field('password')->required(1)->length(1,50);
    #mojoのコマンドでパラメーターをハッシュで取得入力した値をFIllin時に使うため、
    my $param_hash = $self->req->params->to_hash;
    $self->stash(param_hash => $param_hash);

    #入力検査合格、の時、値を新規もしくは修正アップロード実行
    if ( $self->validate($validator,$param_hash) ) {
        #sql検索
        my $login     = $self->param('login');
        my $general_ref = $teng->single('general', +{login => $login});
        my $general_id    = $general_ref->id;
        #セッションに書き込み
        $self->session(session_general_id => $general_id);
        #リダイレクト先を選択する、profile設定が終わってないときはprofileへ#sqlへ確認
        my $profile_ref = $teng->single('profile', +{general_id => $general_id});
        my $status = $profile_ref->status;
        if ($status) {
            return $self->redirect_to('index');
        }
        else {
            return $self->redirect_to('profile');
        }
        #リターンなのでここでおしまい。
    }
    #入力検査合格しなかった場合、もう一度入力フォーム表示Fillinにて
    my $html = $self->render_partial()->to_string;
    $html = HTML::FillInForm->fill(\$html, $self->req->params,);
    return $self->render_text($html, format => 'html');
    #リターンなのでここでおしまい。
    #post以外(getの時)list画面から修正で移動してきた時
}


$self->render('up_login_general');
};

# up_login_admin.html.ep
# ログインフォーム、管理者入力フォーム========================================
any '/up_login_admin' => sub {
my $self = shift;
# テンプレート用bodyのクラス名
my $class = "up_login_admin";
$self->stash(class => $class);


if (uc $self->req->method eq 'POST') {
    #ログイン押すとpostで入ってくる、バリデード実行
    my $validator = $self->create_validator;
    $validator->field('login')->required(1)->length(1,50)->callback(sub {
        my $login    = shift;
        my $password = $self->param('password');

        my $judg_login = 0;
        #die "hoge";
        my $admin_ref      = $teng->single('admin', +{login => $login});

        my $login_name    ;
        my $login_password;

        if ($admin_ref) {
            $login_name     = $admin_ref->login;
            $login_password = $admin_ref->password;

            if ($login_name eq $login and $login_password ne $password) {
                $judg_login = 2 ;
            }
        }
        else {
            $judg_login = 1 ;
        }

        return   ($judg_login == 1) ? (0, 'メールアドレス違い'  )
               : ($judg_login == 2) ? (0, 'パスワードが違います')
               :                       1
               ;
    });

    $validator->field('password')->required(1)->length(1,50);
    #mojoのコマンドでパラメーターをハッシュで取得入力した値をFIllin時に使うため、
    my $param_hash = $self->req->params->to_hash;
    $self->stash(param_hash => $param_hash);

    #入力検査合格、の時、値を新規もしくは修正アップロード実行
    if ( $self->validate($validator,$param_hash) ) {
        #sql検索
        my $login     = $self->param('login');
        my $admin_ref = $teng->single('admin', +{login => $login});
        my $admin_id  = $admin_ref->id;


        #セッションにokと書き込み
        $self->session(session_admin_id => $admin_id);
        #リダイレクト先を選択する、profile設定が終わってないときはprofileへ#sqlへ確認
        my $profile_ref = $teng->single('profile', +{admin_id => $admin_id});
        my $status = $profile_ref->status;
        if ($status) {
            return $self->redirect_to('index');
        }
        else {
            return $self->redirect_to('profile');
        }
        #リターンなのでここでおしまい。
    }
    #入力検査合格しなかった場合、もう一度入力フォーム表示Fillinにて
    my $html = $self->render_partial()->to_string;
    $html = HTML::FillInForm->fill(\$html, $self->req->params,);
    return $self->render_text($html, format => 'html');
    #リターンなのでここでおしまい。
    #post以外(getの時)list画面から修正で移動してきた時
}


$self->render('up_login_admin');
};

# root_login.html.ep
# スーバーユーザー用ログイン入り口========================================
any '/root_login' => sub {
my $self = shift;
# テンプレート用bodyのクラス名
my $class = "up_login_admin";
$self->stash(class => $class);

if (uc $self->req->method eq 'POST') {
    #ログイン押すとpostで入ってくる、バリデード実行
    my $validator = $self->create_validator;
    $validator->field('login')->required(1)->length(1,10)->callback(sub {
        my $login    = shift;
        my $password = $self->param('password');

        my $judg_login = 0;
        #id検証
        if ($login eq "yoyakku") {
            if ($password eq "0520") {
                $judg_login = 0;
            }
            else {
                $judg_login = 2;
            }
        }
        else {
            $judg_login = 1;
        }

        return   ($judg_login == 1) ? (0, 'ID違い'  )
               : ($judg_login == 2) ? (0, 'password違い')
               :                       1
               ;
    });

    $validator->field('password')->required(1)->length(1,50);
    #mojoのコマンドでパラメーターをハッシュで取得入力した値をFIllin時に使うため、
    my $param_hash = $self->req->params->to_hash;
    $self->stash(param_hash => $param_hash);

    #入力検査合格、の時、値を新規もしくは修正アップロード実行
    if ( $self->validate($validator,$param_hash) ) {
        my $root_id     = $self->param('login');
        #セッションに書き込み
        $self->session(root_id => $root_id);
        return $self->redirect_to('mainte_list');
        #リターンなのでここでおしまい。
    }
    #入力検査合格しなかった場合、もう一度入力フォーム表示Fillinにて
    my $html = $self->render_partial()->to_string;
    $html = HTML::FillInForm->fill(\$html, $self->req->params,);
    return $self->render_text($html, format => 'html');
    #リターンなのでここでおしまい。
    #post以外(getの時)list画面から修正で移動してきた時
}

$self->render('root_login');
};

# up_login.html.ep
# ログインフォーム入り口========================================
get '/up_login' => sub {
    my $self = shift;
    # テンプレート用bodyのクラス名
    my $class = "up_login_admin";
    $self->stash(class => $class);

    $self->render('up_login');
};

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

=head1 DEPENDENCIES (依存モジュール)

=over 2

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<FormValidator::Lite>

=item * L<HTML::FillInForm>

=back

=head1 SEE ALSO (参照)

L<Yoyakku::Guides>
