package Yoyakku::Controller::Mainte::Admin;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Mainte::Admin;

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Mainte::Admin->new();

    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session->{root_id} );

    my $header_stash = $model->check_auth_admin();

    return $self->redirect_to('/index') if !$header_stash;

    $self->stash($header_stash);

    return $model;
}

sub mainte_registrant_serch {
    my $self  = shift;
    my $model = $self->_init();

    my $admin_rows = $model->search_admin_id_rows();

    $self->stash(
        class      => 'mainte_registrant_serch',
        admin_rows => $admin_rows,
    );

    return $self->render(
        template => 'mainte/mainte_registrant_serch',
        format   => 'html',
    );
}

sub mainte_registrant_new {
    my $self  = shift;
    my $model = $self->_init();

    return $self->redirect_to('/mainte_registrant_serch')
        if ( $model->method() ne 'GET' ) && ( $model->method() ne 'POST' );

    my $init_valid_params_admin = $model->get_init_valid_params_admin();

    $self->stash(
        class => 'mainte_registrant_new',
        %{$init_valid_params_admin},
    );

    return $self->_insert($model) if !$model->params()->{id};
    return $self->_update($model);
}

sub _insert {
    my $self  = shift;
    my $model = shift;

    return $self->_render_registrant($model) if 'GET' eq $model->method();

    $model->type('insert');
    $model->flash_msg( +{ touroku => '登録完了' } );

    return $self->_common($model);
}

sub _update {
    my $self  = shift;
    my $model = shift;

    return $self->_render_registrant( $model->get_update_form_params_admin() )
        if 'GET' eq $model->method();

    $model->type('update');
    $model->flash_msg( +{ henkou => '修正完了' } );

    return $self->_common($model);
}

sub _common {
    my $self  = shift;
    my $model = shift;

    my $valid_msg = $model->check_admin_validator();

    return $self->stash($valid_msg), $self->_render_registrant($model)
        if $valid_msg;

    my $valid_msg_db = $model->check_admin_validator_db();

    return $self->stash($valid_msg_db), $self->_render_registrant($model)
        if $valid_msg_db;

    $model->writing_admin();
    $self->flash( $model->flash_msg() );

    return $self->redirect_to('mainte_registrant_serch');
}

sub _render_registrant {
    my $self  = shift;
    my $model = shift;

    my $html = $self->render_to_string(
        template => 'mainte/mainte_registrant_new',
        format   => 'html',
    )->to_string;

    $model->html( \$html );
    my $output = $model->get_fill_in_registrant();
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
