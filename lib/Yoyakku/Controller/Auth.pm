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
