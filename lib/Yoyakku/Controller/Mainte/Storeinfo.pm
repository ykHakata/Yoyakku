package Yoyakku::Controller::Mainte::Storeinfo;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Mainte::Storeinfo;

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Mainte::Storeinfo->new();

    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session->{root_id} );

    my $header_stash = $model->get_header_stash_auth_mainte();

    return $self->redirect_to('/index') if !$header_stash;

    $self->stash($header_stash);

    return $model;
}

sub mainte_storeinfo_serch {
    my $self  = shift;
    my $model = $self->_init();

    my $storeinfo_rows = $model->search_storeinfo_id_rows();

    $self->stash(
        class          => 'mainte_storeinfo_serch',
        storeinfo_rows => $storeinfo_rows,
    );

    return $self->render(
        template => 'mainte/mainte_storeinfo_serch',
        format   => 'html',
    );
}

sub mainte_storeinfo_new {
    my $self  = shift;
    my $model = $self->_init();

    return $self->redirect_to('/mainte_storeinfo_serch')
        if ( $model->method() ne 'GET' ) && ( $model->method() ne 'POST' );

    return $self->redirect_to('/mainte_storeinfo_serch')
        if !$model->params()->{id};

    my $init_valid_params_storeinfo
        = $model->get_init_valid_params_storeinfo();

    $self->stash(
        class => 'mainte_storeinfo_new',
        %{$init_valid_params_storeinfo},
    );

    return $self->_update($model);
}

sub _update {
    my $self  = shift;
    my $model = shift;

    return $self->_render_storeinfo(
        $model->get_update_form_params_storeinfo() )
        if 'GET' eq $model->method();

    # 郵便番号検索ボタンが押されたときの処理
    return $self->_render_storeinfo( $model->search_zipcode_for_address() )
        if $model->params()->{kensaku}
        && $model->params()->{kensaku} eq '検索する';

    $model->type('update');
    $model->flash_msg( +{ henkou => '修正完了' } );

    return $self->_common($model);
}

sub _common {
    my $self  = shift;
    my $model = shift;

    my $valid_msg = $model->check_storeinfo_validator();

    return $self->stash($valid_msg), $self->_render_storeinfo($model)
        if $valid_msg;

    $model->writing_storeinfo();
    $self->flash( $model->flash_msg() );

    return $self->redirect_to('mainte_storeinfo_serch');
}

sub _render_storeinfo {
    my $self  = shift;
    my $model = shift;

    my $html = $self->render_to_string(
        template => 'mainte/mainte_storeinfo_new',
        format   => 'html',
    )->to_string;

    $model->html( \$html );
    my $output = $model->get_fill_in_storeinfo();
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
