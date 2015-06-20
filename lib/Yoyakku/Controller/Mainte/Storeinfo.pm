package Yoyakku::Controller::Mainte::Storeinfo;
use Mojo::Base 'Mojolicious::Controller';
use HTML::FillInForm;
use Yoyakku::Controller::Mainte qw{check_login_mainte switch_stash};
use Yoyakku::Model::Mainte::Storeinfo qw{
    search_storeinfo_id_rows
    get_init_valid_params_storeinfo
    get_update_form_params_storeinfo
    search_zipcode_for_address
    check_storeinfo_validator
    writing_storeinfo
};

# 店舗情報 一覧 検索
sub mainte_storeinfo_serch {
    my $self = shift;

    return $self->redirect_to('/index') if $self->check_login_mainte();

     # テンプレートbodyのクラス名を定義
    my $class = 'mainte_storeinfo_serch';
    $self->stash( class => $class );

    my $storeinfo_rows
        = search_storeinfo_id_rows( $self->param('storeinfo_id') );
    $self->stash( storeinfo_rows => $storeinfo_rows );

    return $self->render(
        template => 'mainte/mainte_storeinfo_serch',
        format   => 'html',
    );
}

# 店舗情報 編集
sub mainte_storeinfo_new {
    my $self = shift;

    return $self->redirect_to('/index') if $self->check_login_mainte();

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    return $self->redirect_to('/mainte_storeinfo_serch')
        if ( $method ne 'GET' ) && ( $method ne 'POST' );

    return $self->redirect_to('/mainte_storeinfo_serch') if !$params->{id};

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_storeinfo_new';
    $self->stash( class => $class );

    my $init_valid_params_storeinfo = get_init_valid_params_storeinfo();

    $self->stash($init_valid_params_storeinfo);

    return $self->_update();
}

sub _update {
    my $self = shift;

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    return $self->_render_storeinfo(
        get_update_form_params_storeinfo($params) )
        if 'GET' eq $method;

    # 郵便番号検索ボタンが押されたときの処理
    return $self->_render_storeinfo( search_zipcode_for_address($params) )
        if $params->{kensaku} && $params->{kensaku} eq '検索する';

    return $self->_common( 'update', +{ henkou => '修正完了', }, );
}

sub _common {
    my $self      = shift;
    my $type      = shift;
    my $flash_msg = shift;

    my $params = $self->req->params->to_hash;

    my $valid_msg = check_storeinfo_validator($params);

    return $self->stash($valid_msg), $self->_render_storeinfo($params)
        if $valid_msg;

    writing_storeinfo( $type, $params );
    $self->flash($flash_msg);

    return $self->redirect_to('mainte_storeinfo_serch');
}

sub _render_storeinfo {
    my $self   = shift;
    my $params = shift;

    my $html = $self->render_to_string(
        template => 'mainte/mainte_storeinfo_new',
        format   => 'html',
    )->to_string;

    my $output = HTML::FillInForm->fill( \$html, $params );

    return $self->render( text => $output );
}

1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Controller::Mainte::Storeinfo - storeinfo テーブルのコントローラー

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Controller::Mainte::Storeinfo version 0.0.1

=head1 SYNOPSIS (概要)

システム管理者 storeinfo 関連機能のリクエストをコントロール

=head2 mainte_storeinfo_serch

    リクエスト
    URL: http:// ... /mainte_storeinfo_serch
    METHOD: GET

    リクエスト
    URL: http:// ... /mainte_storeinfo_serch
    METHOD: GET
    PARAMETERS:
        storeinfo_id: (指定の数字)

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/mainte/mainte_storeinfo_serch

    GET リクエストに storeinfo_id が指定された場合該当レコード表示
    該当レコードなき場合は全てのレコード表示

storeinfo テーブル登録情報の確認、検索

=head2 mainte_storeinfo_new

    リクエスト
    URL: http:// ... /mainte_storeinfo_serch
    METHOD: GET
    PARAMETERS:
        id: (指定の数字)

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/mainte/mainte_storeinfo_new

    storeinfo テーブル指定のレコードの修正画面

    リクエスト
    URL: http:// ... /mainte_storeinfo_new
    METHOD: POST
    PARAMETERS:
        id:             INTEGER (例: 10, 自動採番)
        region_id:      INTEGER (例: 10, 自動採番)
        admin_id:       INTEGER (例: 10, 自動採番)
        name:           TEXT (例: ヨヤックスタジオ)
        icon:           TEXT (例: ファイルアップロード)
        post:           TEXT (例: 8120041)
        state:          TEXT (例: 福岡県)
        cities:         TEXT (例: 福岡市博多区)
        addressbelow:   TEXT (例: 吉塚4丁目12-9)
        tel:            TEXT ( 例: 080-3456-4321, )
        mail:           TEXT ( 例: yoyakku@gmail.com, メールアドレス形式)
        remarks:        TEXT (例: 駅前の便利な場所にあるスタジオ)
        url:            TEXT (例: http://www.yoyakku.com/)
        locationinfor:  TEXT (例: 位置情報のテキスト)
        status:         INTEGER (例: 0: web公開, 1: web非公開, 2: 削除)
        create_on:      TEXT ( 例: 2015-06-06 12:24:12, datetime 形式)
        modify_on:      TEXT ( 例: 2015-06-06 12:24:12, datetime 形式)

    レスポンス (バリデートエラー時)
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/auth/mainte_storeinfo_new

    レスポンス (レコード書込み終了)
    URL: http:// ... /mainte_storeinfo_serch

storeinfo テーブルに既存レコード修正

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<FormValidator::Lite>

=item * L<HTML::FillInForm>

=item * L<Yoyakku::Model::Mainte>

=item * L<Yoyakku::Model::Mainte::Storeinfo>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
