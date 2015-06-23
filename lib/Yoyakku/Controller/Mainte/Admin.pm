package Yoyakku::Controller::Mainte::Admin;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Mainte::Admin qw{
    check_auth_admin
    search_admin_id_rows
    get_init_valid_params_admin
    get_update_form_params_admin
    check_admin_validator
    check_admin_validator_db
    writing_admin
    get_fill_in_registrant
};

sub _auth {
    my $self         = shift;
    my $header_stash = check_auth_admin( $self->session->{root_id} );
    return 1 if !$header_stash;
    $self->stash($header_stash);
    return;
}

sub mainte_registrant_serch {
    my $self = shift;

    return $self->redirect_to('/index') if $self->_auth();

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_registrant_serch';
    $self->stash( class => $class );

    my $admin_rows = search_admin_id_rows( $self->param('admin_id') );
    $self->stash( admin_rows => $admin_rows );

    return $self->render(
        template => 'mainte/mainte_registrant_serch',
        format   => 'html',
    );
}

sub mainte_registrant_new {
    my $self = shift;

    return $self->redirect_to('/index') if $self->_auth();

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    return $self->redirect_to('/mainte_registrant_serch')
        if ( $method ne 'GET' ) && ( $method ne 'POST' );

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_registrant_new';
    $self->stash( class => $class );

    my $init_valid_params_admin = get_init_valid_params_admin();
    $self->stash($init_valid_params_admin);

    return $self->_insert() if !$params->{id};
    return $self->_update();
}

sub _insert {
    my $self = shift;

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    return $self->_render_registrant($params) if 'GET' eq $method;
    return $self->_common( 'insert', +{ touroku => '登録完了' }, );
}

sub _update {
    my $self = shift;

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    return $self->_render_registrant( get_update_form_params_admin($params) )
        if 'GET' eq $method;

    return $self->_common( 'update', +{ henkou => '修正完了' }, );
}

sub _common {
    my $self      = shift;
    my $type      = shift;
    my $flash_msg = shift;

    my $params = $self->req->params->to_hash;

    my $valid_msg = check_admin_validator($params);

    return $self->stash($valid_msg), $self->_render_registrant($params)
        if $valid_msg;

    my $valid_msg_db = check_admin_validator_db( $type, $params, );

    return $self->stash($valid_msg_db), $self->_render_registrant($params)
        if $valid_msg_db;

    writing_admin( $type, $params );
    $self->flash($flash_msg);

    return $self->redirect_to('mainte_registrant_serch');
}

sub _render_registrant {
    my $self   = shift;
    my $params = shift;

    my $html = $self->render_to_string(
        template => 'mainte/mainte_registrant_new',
        format   => 'html',
    )->to_string;

    my $output = get_fill_in_registrant( \$html, $params );
    return $self->render( text => $output );
}

1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Controller::Mainte::Admin - admin テーブルのコントローラー

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Controller::Mainte::Admin version 0.0.1

=head1 SYNOPSIS (概要)

システム管理者 adimn 関連機能のリクエストをコントロール

=head2 mainte_registrant_serch

    リクエスト
    URL: http:// ... /mainte_registrant_serch
    METHOD: GET

    リクエスト
    URL: http:// ... /mainte_registrant_serch
    METHOD: GET
    PARAMETERS:
        id: (指定の数字)

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/mainte/mainte_registrant_serch

    GET リクエストに id が指定された場合該当レコード表示
    該当レコードなき場合は全てのレコード表示

admin テーブル登録情報の一覧、検索

=head2 mainte_registrant_new

    リクエスト
    URL: http:// ... /mainte_registrant_new
    METHOD: GET

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/mainte/mainte_registrant_new

    admin テーブルに新規にレコード登録画面

    リクエスト
    URL: http:// ... /mainte_registrant_serch
    METHOD: GET
    PARAMETERS:
        id: (指定の数字)

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/mainte/mainte_registrant_new

    admin テーブル指定のレコードの修正画面

    リクエスト
    URL: http:// ... /mainte_registrant_new
    METHOD: POST
    PARAMETERS:
        id:         INT  (例: 5) 管理ユーザーID
        login:      TEXT (例: 'yoyakku@gmail.com') ログインID名
        password:   TEXT (例: 'yoyakku0000') ログインパスワード
        status:     INT  (例: 0: 未承認, 1: 承認済み, 2: 削除) ステータス
        create_on:  TEXT (例: '2015-06-06 12:24:12') 登録日
        modify_on:  TEXT (例: '2015-06-06 12:24:12') 修正日

    レスポンス (バリデートエラー時)
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/auth/mainte_registrant_new

    レスポンス (レコード書込み終了)
    URL: http:// ... /mainte_registrant_serch

    POST リクエストに id パラメーター存在しない場合、新規
    id パラメーター存在する場合、指定レコード更新

admin テーブルに新規レコード追加、既存レコード修正

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Mainte::Admin>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
