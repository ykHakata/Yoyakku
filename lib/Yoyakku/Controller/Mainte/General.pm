package Yoyakku::Controller::Mainte::General;
use Mojo::Base 'Mojolicious::Controller';
use HTML::FillInForm;
use Yoyakku::Controller::Mainte qw{check_login_mainte switch_stash};
use Yoyakku::Model::Mainte::General qw{
    search_general_id_rows
    get_init_valid_params_general
    search_general_id_row
    check_general_validator
    check_general_validator_db
    writing_general
};

# 一般ユーザー 一覧 検索
sub mainte_general_serch {
    my $self = shift;

    return $self->redirect_to('/index') if $self->check_login_mainte();

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_general_serch';
    $self->stash( class => $class );

    # id検索時のアクション
    my $general_id = $self->param('general_id');

    # id 検索時は指定のid検索して出力
    my $general_rows = search_general_id_rows($general_id);

    $self->stash( general_rows => $general_rows );

    return $self->render(
        template => 'mainte/mainte_general_serch',
        format   => 'html',
    );
}

# 一般ユーザー 新規 編集
sub mainte_general_new {
    my $self = shift;

    return $self->redirect_to('/index') if $self->check_login_mainte();

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    return $self->redirect_to('/mainte_general_serch')
        if ( $method ne 'GET' ) && ( $method ne 'POST' );

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_general_new';
    $self->stash( class => $class );

    my $init_valid_params_general = get_init_valid_params_general();

    $self->stash($init_valid_params_general);

    return $self->_insert() if !$params->{id};
    return $self->_update();
}

sub _insert {
    my $self = shift;

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    return $self->_render_general($params) if 'GET' eq $method;
    return $self->_common( 'insert', +{ touroku => '登録完了' }, );
}

sub _update {
    my $self = shift;

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    return $self->_render_update_form($params) if 'GET' eq $method;
    return $self->_common( 'update', +{ henkou => '修正完了' }, );
}

sub _common {
    my $self      = shift;
    my $type      = shift;
    my $flash_msg = shift;

    my $params = $self->req->params->to_hash;

    my $valid_msg = check_general_validator($params);

    return $self->stash($valid_msg), $self->_render_general($params)
        if $valid_msg;

    my $valid_msg_db = check_general_validator_db( $type, $params, );

    return $self->stash($valid_msg_db), $self->_render_general($params)
        if $valid_msg_db;

    writing_general( $type, $params );
    $self->flash($flash_msg);

    return $self->redirect_to('mainte_general_serch');
}

sub _render_update_form {
    my $self   = shift;
    my $params = shift;

    my $general_row = search_general_id_row( $params->{id} );

    $params = +{
        id        => $general_row->id,
        login     => $general_row->login,
        password  => $general_row->password,
        status    => $general_row->status,
        create_on => $general_row->create_on,
        modify_on => $general_row->modify_on,
    };
    return $self->_render_general($params);
}

# テンプレート画面のレンダリング
sub _render_general {
    my $self   = shift;
    my $params = shift;

    my $html = $self->render_to_string(
        template => 'mainte/mainte_general_new',
        format   => 'html',
    )->to_string;

    my $output = HTML::FillInForm->fill( \$html, $params );

    return $self->render( text => $output );
}

1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Controller::Mainte::General - general テーブルのコントローラー

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Controller::Mainte::General version 0.0.1

=head1 SYNOPSIS (概要)

システム管理者 general 関連機能のリクエストをコントロール

=head2 mainte_general_serch

    リクエスト
    URL: http:// ... /mainte_general_serch
    METHOD: GET

    リクエスト
    URL: http:// ... /mainte_general_serch
    METHOD: GET
    PARAMETERS:
        id: (指定の数字)

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/mainte/mainte_general_serch

    GET リクエストに id が指定された場合該当レコード表示
    該当レコードなき場合は全てのレコード表示

general テーブル登録情報の確認、検索

=head2 mainte_general_new

    リクエスト
    URL: http:// ... /mainte_general_new
    METHOD: GET

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/mainte/mainte_general_new

    general テーブルに新規にレコード登録画面

    リクエスト
    URL: http:// ... /mainte_general_serch
    METHOD: GET
    PARAMETERS:
        id: (指定の数字)

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/mainte/mainte_general_new

    general テーブル指定のレコードの修正画面

    リクエスト
    URL: http:// ... /mainte_general_new
    METHOD: POST
    PARAMETERS:
        id: (自動連番)
        login: (指定の ASCII 文字)
        password: (指定の ASCII 文字)
        status: (0: 未承認, 1: 承認済み, 2: 削除)
        create_on: (作成日 datetime 形式)
        modify_on: (修正日 datetime 形式)

    レスポンス (バリデートエラー時)
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/auth/mainte_general_new

    レスポンス (レコード書込み終了)
    URL: http:// ... /mainte_general_serch

    POST リクエストに id パラメーター存在しない場合、新規
    id パラメーター存在する場合、指定レコード更新

general テーブルに新規レコード追加、既存レコード修正

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<FormValidator::Lite>

=item * L<HTML::FillInForm>

=item * L<Yoyakku::Model::Mainte>

=item * L<Yoyakku::Model::Mainte::General>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
