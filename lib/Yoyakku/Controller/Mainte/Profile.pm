package Yoyakku::Controller::Mainte::Profile;
use Mojo::Base 'Mojolicious::Controller';
use FormValidator::Lite qw{Email};
use HTML::FillInForm;
use Yoyakku::Controller::Mainte qw{check_login_mainte switch_stash};
use Yoyakku::Model::Mainte::Profile qw{
    search_profile_id_rows
    get_general_rows_all
    get_admin_rows_all
    search_profile_id_row
    check_admin_and_general_id
    writing_profile
};

# 個人情報 一覧 検索
sub mainte_profile_serch {
    my $self = shift;

    # ログイン確認する
    return $self->redirect_to('/index') if $self->check_login_mainte();

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_profile_serch';
    $self->stash( class => $class );

    # id検索時のアクション
    my $profile_id = $self->param('profile_id');

    # id 検索時は指定のid検索して出力
    my $profile_rows = $self->search_profile_id_rows($profile_id);

    $self->stash( profile_rows => $profile_rows );

    return $self->render(
        template => 'mainte/mainte_profile_serch',
        format   => 'html',
    );
}

# 個人情報 新規 編集
sub mainte_profile_new {
    my $self = shift;

    # ログイン確認する
    return $self->redirect_to('/index') if $self->check_login_mainte();

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_profile_new';
    $self->stash( class => $class );

    # バリデート用
    $self->stash(
        general_id    => '',
        admin_id      => '',
        nick_name     => '',
        full_name     => '',
        phonetic_name => '',
        tel           => '',
        mail          => '',
    );

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    # 入力画面セレクト用の general admin ログイン名表示
    $self->stash(
        general_rows => $self->get_general_rows_all(),
        admin_rows   => $self->get_admin_rows_all(),
    );

    # 新規作成画面表示用
    return $self->_render_profile($params)
        if !$params->{id} && ( 'POST' ne $method );

    if ('POST' ne $method) {
        # 修正画面表示用
        my $profile_row = $self->search_profile_id_row( $params->{id} );

        # 入力フォームフィルイン用
        $params = +{
            id            => $profile_row->id,
            general_id    => $profile_row->general_id,
            admin_id      => $profile_row->admin_id,
            nick_name     => $profile_row->nick_name,
            full_name     => $profile_row->full_name,
            phonetic_name => $profile_row->phonetic_name,
            tel           => $profile_row->tel,
            mail          => $profile_row->mail,
            status        => $profile_row->status,
            create_on     => $profile_row->create_on,
            modify_on     => $profile_row->modify_on,
        };
    }

    # テンプレート画面のレンダリング
    return $self->_render_profile($params) if 'POST' ne $method;

    # 入力フォームに値を入力して登録するボタン押した場合
    # バリデード実行
    my $validator = FormValidator::Lite->new($params);

    $validator->check(
        general_id    => [ 'INT', ],
        admin_id      => [ 'INT', ],
        nick_name     => [ [ 'LENGTH', 0, 20, ], ],
        full_name     => [ [ 'LENGTH', 0, 20, ], ],
        phonetic_name => [ [ 'LENGTH', 0, 20, ], ],
        tel           => [ [ 'LENGTH', 0, 20, ], ],
        mail          => [ 'EMAIL_LOOSE', ],
    );

    $validator->set_message(
        'general_id.not_null'  => '指定の形式で入力してください',
        'admin_id.not_null'    => '指定の形式で入力してください',
        'nick_name.length'     => '文字数!!',
        'full_name.length'     => '文字数!!',
        'phonetic_name.length' => '文字数!!',
        'tel.length'           => '文字数!!',
        'mail.email_loose'     => 'Eメールを入力してください',
    );

    my @general_id_errors
        = $validator->get_error_messages_from_param('general_id');
    my @admin_id_errors
        = $validator->get_error_messages_from_param('admin_id');
    my @nick_name_errors
        = $validator->get_error_messages_from_param('nick_name');
    my @full_name_errors
        = $validator->get_error_messages_from_param('full_name');
    my @phonetic_name_errors
        = $validator->get_error_messages_from_param('phonetic_name');
    my @tel_errors    = $validator->get_error_messages_from_param('tel');
    my @mail_errors   = $validator->get_error_messages_from_param('mail');

    # バリデート用メッセージ
    $self->stash(
        general_id    => shift @general_id_errors,
        admin_id      => shift @admin_id_errors,
        nick_name     => shift @nick_name_errors,
        full_name     => shift @full_name_errors,
        phonetic_name => shift @phonetic_name_errors,
        tel           => shift @tel_errors,
        mail          => shift @mail_errors,
    );

    # 入力バリデート不合格の場合それ以降の作業はしない
    return $self->_render_profile($params) if $validator->has_error();

    # 既存データとの照合(DB バリデートチェック)
    if ( $params->{id} ) {
        # DB バリデート合格の場合 DB 書き込み(修正)
        # general_id, admin_id, 重複、既存の確認
        my $check_admin_and_general_msg = $self->check_admin_and_general_id(
            $params->{general_id},
            $params->{admin_id},
            $params->{id},
        );

        if ($check_admin_and_general_msg) {

            $self->stash->{general_id} = $check_admin_and_general_msg;

            # テンプレート画面のレンダリング
            return $self->_render_profile($params);
        }

        $self->writing_profile( 'update', $params );
        $self->flash( henkou => '修正完了' );

        # sqlにデータ入力したので list 画面にリダイレクト
        return $self->redirect_to('mainte_profile_serch');
    }

    # DB バリデート合格の場合 DB 書き込み(新規)

    # general_id, admin_id, 重複、既存の確認
    my $check_admin_and_general_msg = $self->check_admin_and_general_id(
        $params->{general_id},
        $params->{admin_id},
    );

    if ($check_admin_and_general_msg) {

        $self->stash->{general_id} = $check_admin_and_general_msg;

        # テンプレート画面のレンダリング
        return $self->_render_profile($params);
    }

    $self->writing_profile( 'insert', $params );
    $self->flash( touroku => '登録完了' );

    return $self->redirect_to('mainte_profile_serch');
}

# テンプレート画面のレンダリング
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
