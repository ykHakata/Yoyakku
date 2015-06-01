package Yoyakku::Controller::Mainte::Admin;
use Mojo::Base 'Mojolicious::Controller';
use FormValidator::Lite;
use HTML::FillInForm;
use Yoyakku::Model qw{$teng};
# use Yoyakku::Util qw{now_datetime};
use Yoyakku::Controller::Mainte qw{_check_login_mainte _switch_stash};
use Yoyakku::Model::Mainte::Admin
    qw{search_admin_id_rows search_admin_id_row writing_admin check_admin_login_name};

# 管理ユーザー(admin) registrant_serch.html.ep
sub mainte_registrant_serch {
    my $self = shift;
    # die 'mainte_registrant_serch';
    # ログイン確認する
    return $self->redirect_to('/index') if $self->_check_login_mainte();

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_registrant_serch';
    $self->stash( class => $class );

    # id検索時のアクション
    my $admin_id = $self->param('admin_id');

    # id 検索時は指定のid検索して出力
    my $admin_rows = $self->search_admin_id_rows($admin_id);

    $self->stash( admins_ref => $admin_rows );

    return $self->render(
        template => 'mainte/mainte_registrant_serch',
        format   => 'html',
    );
}

# 管理ユーザー 新規 編集 (admin) registrant_new.html.ep
sub mainte_registrant_new {
    my $self = shift;

    # ログイン確認する
    return $self->redirect_to('/index') if $self->_check_login_mainte();

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_registrant_new';
    $self->stash( class => $class );

    # バリデート用
    $self->stash(
        login    => '',
        password => '',
    );

    my $req    = $self->req;
    my $params = $req->params->to_hash;
    my $method = uc $req->method;

    # 新規作成画面表示用
    return $self->_render_registrant($params)
        if !$params->{id} && ( 'POST' ne $method );

    if ('POST' ne $method) {
        # 修正画面表示用
        my $admin_row = $self->search_admin_id_row( $params->{id} );

        # 入力フォームフィルイン用
        $params = +{
            id        => $admin_row->id,
            login     => $admin_row->login,
            password  => $admin_row->password,
            status    => $admin_row->status,
            create_on => $admin_row->create_on,
            modify_on => $admin_row->modify_on,
        };
    }

    # テンプレート画面のレンダリング
    return $self->_render_registrant($params) if 'POST' ne $method;

    # 入力フォームに値を入力して登録するボタン押した場合
    # バリデード実行
    my $validator = FormValidator::Lite->new($req);

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

    # 入力バリデート不合格の場合それ以降の作業はしない
    return $self->_render_registrant($params) if $validator->has_error();

    # ログイン名(メルアド)の既存データとの照合
    # 既存データとの照合(DB バリデートチェック)
    if ( $params->{id} ) {
        # DB バリデート合格の場合 DB 書き込み(修正)
        $self->writing_admin( 'update', $params );
        $self->flash( henkou => '修正完了' );

        # sqlにデータ入力したので list 画面にリダイレクト
        return $self->redirect_to('mainte_registrant_serch');
    }

    # DB バリデート合格の場合 DB 書き込み(新規)
    my $check_admin_row
        = $self->check_admin_login_name( $req->param('login') );

    if ($check_admin_row) {

        # ログイン名がすでに存在している
        $self->stash->{login} = '既に使用されてます';

        # テンプレート画面のレンダリング
        return $self->_render_registrant($params);
    }

    $self->writing_admin( 'insert', $params );
    $self->flash( touroku => '登録完了' );

    return $self->redirect_to('mainte_registrant_serch');
}

# テンプレート画面のレンダリング
sub _render_registrant {
    my $self   = shift;
    my $params = shift;

    my $html = $self->render_to_string(
        template => 'mainte/mainte_registrant_new',
        format   => 'html',
    )->to_string;

    my $output = HTML::FillInForm->fill( \$html, $params );

    return $self->render( text => $output );
}


1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Controller::Mainte - システム管理者機能のコントローラー

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Controller::Mainte version 0.0.1

=head1 SYNOPSIS (概要)

システム管理者関連機能のリクエストをコントロール

=head2 mainte_list

    リクエスト
    URL: http:// ... /mainte_list
    METHOD: GET

    他詳細は調査、実装中

システム管理のオープニング画面

=head1 DEPENDENCIES (依存モジュール)

=over 2

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<FormValidator::Lite>

=item * L<HTML::FillInForm>

=item * L<Yoyakku::Model::Mainte>

=item * L<Yoyakku::Model>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Yoyakku::Guides>

=cut
