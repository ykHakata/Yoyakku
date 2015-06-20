package Yoyakku::Controller::Mainte::Profile;
use Mojo::Base 'Mojolicious::Controller';
use HTML::FillInForm;
use Yoyakku::Controller::Mainte qw{check_login_mainte switch_stash};
use Yoyakku::Model::Mainte::Profile qw{
    search_profile_id_rows
    get_init_valid_params_profile
    get_update_form_params_profile
    get_general_rows_all
    get_admin_rows_all
    check_profile_validator
    check_profile_validator_db
    writing_profile
};

# 個人情報 一覧 検索
sub mainte_profile_serch {
    my $self = shift;

    return $self->redirect_to('/index') if $self->check_login_mainte();

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_profile_serch';
    $self->stash( class => $class );

    my $profile_rows = search_profile_id_rows( $self->param('profile_id') );
    $self->stash( profile_rows => $profile_rows );

    return $self->render(
        template => 'mainte/mainte_profile_serch',
        format   => 'html',
    );
}

# 個人情報 新規 編集
sub mainte_profile_new {
    my $self = shift;

    return $self->redirect_to('/index') if $self->check_login_mainte();

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    return $self->redirect_to('/mainte_profile_serch')
        if ( $method ne 'GET' ) && ( $method ne 'POST' );

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_profile_new';
    $self->stash( class => $class );

    my $init_valid_params_profile = get_init_valid_params_profile();

    $self->stash($init_valid_params_profile);

    # 入力画面セレクト用の general admin ログイン名表示
    $self->stash(
        general_rows => get_general_rows_all(),
        admin_rows   => get_admin_rows_all(),
    );

    return $self->_insert() if !$params->{id};
    return $self->_update();
}

sub _insert {
    my $self = shift;

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    return $self->_render_profile($params) if 'GET' eq $method;
    return $self->_common( 'insert', +{ touroku => '登録完了' }, );
}

sub _update {
    my $self = shift;

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    return $self->_render_profile( get_update_form_params_profile($params) )
        if 'GET' eq $method;

    return $self->_common( 'update', +{ henkou => '修正完了' }, );
}

sub _common {
    my $self      = shift;
    my $type      = shift;
    my $flash_msg = shift;

    my $params = $self->req->params->to_hash;

    my $valid_msg = check_profile_validator($params);

    return $self->stash($valid_msg), $self->_render_profile($params)
        if $valid_msg;

    my $valid_msg_db = check_profile_validator_db( $type, $params, );

    return $self->stash($valid_msg_db), $self->_render_profile($params)
        if $valid_msg_db;

    writing_profile( $type, $params );
    $self->flash($flash_msg);

    return $self->redirect_to('mainte_profile_serch');
}

sub _render_profile {
    my $self   = shift;
    my $params = shift;

    my $html = $self->render_to_string(
        template => 'mainte/mainte_profile_new',
        format   => 'html',
    )->to_string;

    my $output = HTML::FillInForm->fill( \$html, $params );

    return $self->render( text => $output );
}

1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Controller::Mainte::Profile - Profile テーブルのコントローラー

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Controller::Mainte::Profile version 0.0.1

=head1 SYNOPSIS (概要)

システム管理者 Profile 関連機能のリクエストをコントロール

=head2 mainte_profile_serch

    リクエスト
    URL: http:// ... /mainte_profile_serch
    METHOD: GET

    リクエスト
    URL: http:// ... /mainte_profile_serch
    METHOD: GET
    PARAMETERS:
        id: (指定の数字)

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/mainte/mainte_profile_serch

    GET リクエストに id が指定された場合該当レコード表示
    該当レコードなき場合は全てのレコード表示

profile テーブル登録情報の確認、検索

=head2 mainte_profile_new

    リクエスト
    URL: http:// ... /mainte_profile_new
    METHOD: GET

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/mainte/mainte_profile_new

    profile テーブルに新規にレコード登録画面

    リクエスト
    URL: http:// ... /mainte_profile_serch
    METHOD: GET
    PARAMETERS:
        id: (指定の数字)

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/mainte/mainte_profile_new

    profile テーブル指定のレコードの修正画面

    リクエスト
    URL: http:// ... /mainte_profile_new
    METHOD: POST
    PARAMETERS:
        id:            INTEGER ( 例: 10, 自動連番)
        general_id:    INTEGER ( 例: 12, admin_id が存在する場合は null)
        admin_id:      INTEGER ( 例: 14, general_id が存在する場合は null)
        nick_name:     TEXT ( 例: ヨヤック, )
        full_name:     TEXT ( 例: 黒田清隆, )
        phonetic_name: TEXT ( 例: くろだ きよたか, )
        tel:           TEXT ( 例: 080-3456-4321, )
        mail:          TEXT ( 例: yoyakku@gmail.com, メールアドレス形式)
        status:        INTEGER ( 例: 0: 未承認, 1: 承認済み, 2: 削除)
        create_on:     TEXT ( 例: 2015-06-06 12:24:12, datetime 形式)
        modify_on:     TEXT ( 例: 2015-06-06 12:24:12, datetime 形式)

    レスポンス (バリデートエラー時)
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/auth/mainte_profile_new

    レスポンス (レコード書込み終了)
    URL: http:// ... /mainte_profile_serch

    POST リクエストに id パラメーター存在しない場合、新規
    id パラメーター存在する場合、指定レコード更新

profile テーブルに新規レコード追加、既存レコード修正

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<FormValidator::Lite>

=item * L<HTML::FillInForm>

=item * L<Yoyakku::Model::Mainte>

=item * L<Yoyakku::Model::Mainte::Profile>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
