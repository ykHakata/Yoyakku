package Yoyakku::Controller::Mainte::Ads;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Mainte::Ads;

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Mainte::Ads->new();

    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session->{root_id} );

    my $header_stash = $model->get_header_stash_auth_mainte();

    return if !$header_stash;

    $self->stash($header_stash);

    return $model;
}

sub mainte_ads_serch {
    my $self  = shift;
    my $model = $self->_init();

    return $self->redirect_to('/index') if !$model;

    my $ads_rows = $model->search_ads_id_rows();

    $self->stash(
        class    => 'mainte_ads_serch',
        ads_rows => $ads_rows,
    );

    return $self->render(
        template => 'mainte/mainte_ads_serch',
        format   => 'html',
    );
}

sub mainte_ads_new {
    my $self  = shift;
    my $model = $self->_init();

    return $self->redirect_to('/index') if !$model;

    return $self->redirect_to('/mainte_ads_serch')
        if ( $model->method() ne 'GET' ) && ( $model->method() ne 'POST' );

    my $init_valid_params_ads = $model->get_init_valid_params_ads();

    $self->stash(
        class          => 'mainte_ads_new',
        storeinfo_rows => $model->get_storeinfo_rows_all(),
        region_rows    => $model->get_region_rows_pref(),
        %{$init_valid_params_ads},
    );

    return $self->_insert($model) if !$model->params()->{id};
    return $self->_update($model);
}

sub _insert {
    my $self  = shift;
    my $model = shift;

    return $self->_render_ads($model) if 'GET' eq $model->method();

    $model->type('insert');
    $model->flash_msg( +{ touroku => '登録完了' } );

    return $self->_common($model);
}

sub _update {
    my $self  = shift;
    my $model = shift;

    return $self->_render_ads( $model->get_update_form_params_ads() )
        if 'GET' eq $model->method();

    $model->type('update');
    $model->flash_msg( +{ henkou => '修正完了' } );

    return $self->_common($model);
}

sub _common {
    my $self  = shift;
    my $model = shift;

    my $valid_msg = $model->check_ads_validator();

    return $self->stash($valid_msg), $self->_render_ads($model) if $valid_msg;

    $model->writing_ads();
    $self->flash( $model->flash_msg() );

    return $self->redirect_to('mainte_ads_serch');
}

sub _render_ads {
    my $self  = shift;
    my $model = shift;

    my $html = $self->render_to_string(
        template => 'mainte/mainte_ads_new',
        format   => 'html',
    )->to_string;

    $model->html( \$html );
    my $output = $model->get_fill_in_ads();
    return $self->render( text => $output );
}

1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Controller::Mainte::Ads - ads テーブルのコントローラー

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Controller::Mainte::Ads version 0.0.1

=head1 SYNOPSIS (概要)

システム管理者 ads 関連機能のリクエストをコントロール

=head2 mainte_ads_serch

    リクエスト
    URL: http:// ... /mainte_ads_serch
    METHOD: GET

    リクエスト
    URL: http:// ... /mainte_ads_serch
    METHOD: GET
    PARAMETERS:
        id: (指定の数字)

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/mainte/mainte_ads_serch

    GET リクエストに id が指定された場合該当レコード表示
    該当レコードなき場合は全てのレコード表示

ads テーブル登録情報の一覧、検索

=head2 mainte_ads_new

    リクエスト
    URL: http:// ... /mainte_ads_new
    METHOD: GET

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/mainte/mainte_ads_new

    ads テーブルに新規にレコード登録画面

    リクエスト
    URL: http:// ... /mainte_ads_serch
    METHOD: GET
    PARAMETERS:
        id: (指定の数字)

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/mainte/mainte_ads_new

    ads テーブル指定のレコードの修正画面

    リクエスト
    URL: http:// ... /mainte_ads_new
    METHOD: POST
    PARAMETERS:
        id              INT  (例: 5) 広告ID
        kind            INT  (例: 5) 広告種別
        storeinfo_id    INT  (例: 5) 店舗ID
        region_id       INT  (例: 10000) 地域区分ID
        url             TEXT (例: 'http://www.heacon.com/') 広告リンク先
        displaystart_on TEXT (例: '2013-03-07') 表示開始日時
        displayend_on   TEXT (例: '2013-03-07') 表示終了日時
        name            TEXT (例: 'アニソン好きの集い') 広告名
        event_date      TEXT (例: '2013/3/7 18:00-22:00') イベント広告日時
        content         TEXT (例: 'とくにエヴァンゲリオン') 広告内容
        create_on       TEXT (例: '2015-06-06 12:24:12') 登録日
        modify_on       TEXT (例: '2015-06-06 12:24:12') 修正日

    レスポンス (バリデートエラー時)
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/auth/mainte_ads_new

    レスポンス (レコード書込み終了)
    URL: http:// ... /mainte_ads_serch

    POST リクエストに id パラメーター存在しない場合、新規
    id パラメーター存在する場合、指定レコード更新

ads テーブルに新規レコード追加、既存レコード修正

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Mainte::Ads>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
