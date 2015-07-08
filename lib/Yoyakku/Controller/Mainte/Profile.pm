package Yoyakku::Controller::Mainte::Profile;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Mainte::Profile;

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Mainte::Profile->new();

    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session->{root_id} );

    my $header_stash = $model->get_header_stash_auth_mainte();

    return $self->redirect_to('/index') if !$header_stash;

    $self->stash($header_stash);

    return $model;
}

sub mainte_profile_serch {
    my $self  = shift;
    my $model = $self->_init();

    my $profile_rows = $model->search_profile_id_rows();

    $self->stash(
        class        => 'mainte_profile_serch',
        profile_rows => $profile_rows,
    );

    return $self->render(
        template => 'mainte/mainte_profile_serch',
        format   => 'html',
    );
}

sub mainte_profile_new {
    my $self  = shift;
    my $model = $self->_init();

    return $self->redirect_to('/mainte_profile_serch')
        if ( $model->method() ne 'GET' ) && ( $model->method() ne 'POST' );

    my $init_valid_params_profile = $model->get_init_valid_params_profile();

    $self->stash(
        class        => 'mainte_profile_new',
        general_rows => $model->get_general_rows_all(),
        admin_rows   => $model->get_admin_rows_all(),
        %{$init_valid_params_profile},
    );

    return $self->_insert($model) if !$model->params()->{id};
    return $self->_update($model);
}

sub _insert {
    my $self  = shift;
    my $model = shift;

    return $self->_render_profile($model) if 'GET' eq $model->method();

    $model->type('insert');
    $model->flash_msg( +{ touroku => '登録完了' } );

    return $self->_common($model);
}

sub _update {
    my $self  = shift;
    my $model = shift;

    return $self->_render_profile( $model->get_update_form_params_profile() )
        if 'GET' eq $model->method();

    $model->type('update');
    $model->flash_msg( +{ henkou => '修正完了' } );

    return $self->_common($model);
}

sub _common {
    my $self  = shift;
    my $model = shift;

    my $valid_msg = $model->check_profile_validator();

    return $self->stash($valid_msg), $self->_render_profile($model)
        if $valid_msg;

    my $valid_msg_db = $model->check_profile_validator_db();

    return $self->stash($valid_msg_db), $self->_render_profile($model)
        if $valid_msg_db;

    $model->writing_profile();
    $self->flash( $model->flash_msg() );

    return $self->redirect_to('mainte_profile_serch');
}

sub _render_profile {
    my $self  = shift;
    my $model = shift;

    my $html = $self->render_to_string(
        template => 'mainte/mainte_profile_new',
        format   => 'html',
    )->to_string;

    $model->html( \$html );
    my $output = $model->get_fill_in_profile();
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

profile テーブル登録情報の一覧、検索

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
        id:             INT  (例: 5) 個人情報ID
        general_id:     INT  (例: 5, admin_id 存在時 null) 一般ユーザーID
        admin_id:       INT  (例: 5, general_id 存在時 null) 管理ユーザーID
        nick_name:      TEXT (例: 'ヨヤック') ニックネーム
        full_name:      TEXT (例: '黒田清隆') 氏名
        phonetic_name:  TEXT (例: 'くろだ きよたか') ふりがな
        tel:            TEXT (例: '080-3456-4321') 電話番号
        mail:           TEXT (例: 'yoyakku@gmail.com') メールアドレス
        status:         INT  (例: 0: 未承認, 1: 承認済み, 2: 削除) ステータス
        create_on:      TEXT (例: '2015-06-06 12:24:12') 登録日
        modify_on:      TEXT (例: '2015-06-06 12:24:12') 修正日

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

=item * L<Yoyakku::Model::Mainte::Profile>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
