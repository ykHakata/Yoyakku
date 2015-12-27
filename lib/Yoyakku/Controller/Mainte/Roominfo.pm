package Yoyakku::Controller::Mainte::Roominfo;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Mainte::Roominfo;

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Mainte::Roominfo->new();

    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session->{root_id} );

    my $header_stash = $model->get_header_stash_auth_mainte();

    return if !$header_stash;

    $self->stash($header_stash);

    return $model;
}

sub mainte_roominfo_serch {
    my $self  = shift;
    my $model = $self->_init();

    return $self->redirect_to('/index') if !$model;

    my $roominfo_rows = $model->search_storeinfo_id_for_roominfo_rows();

    $self->stash(
        class         => 'mainte_roominfo_serch',
        roominfo_rows => $roominfo_rows,
    );

    return $self->render(
        template => 'mainte/mainte_roominfo_serch',
        format   => 'html',
    );
}

sub mainte_roominfo_new {
    my $self  = shift;
    my $model = $self->_init();

    return $self->redirect_to('/index') if !$model;

    return $self->redirect_to('/mainte_roominfo_serch')
        if ( $model->method() ne 'GET' ) && ( $model->method() ne 'POST' );

    return $self->redirect_to('/mainte_roominfo_serch')
        if !$model->params()->{id};

    my $init_valid_params_roominfo = $model->get_init_valid_params_roominfo();

    $self->stash(
        class => 'mainte_roominfo_new',
        %{$init_valid_params_roominfo},
    );

    return $self->_update($model);
}

sub _update {
    my $self  = shift;
    my $model = shift;

    return $self->_render_roominfo(
        $model->get_update_form_params_roominfo() )
        if 'GET' eq $model->method();

    $model->type('update');
    $model->flash_msg( +{ henkou => '修正完了' } );

    return $self->_common($model);
}

sub _common {
    my $self  = shift;
    my $model = shift;

    my $valid_msg = $model->check_validator( 'roominfo', $model->params() );

    return $self->stash($valid_msg), $self->_render_roominfo($model)
        if $valid_msg;

    $model->writing_roominfo();
    $self->flash( $model->flash_msg() );

    return $self->redirect_to('mainte_roominfo_serch');
}

sub _render_roominfo {
    my $self  = shift;
    my $model = shift;

    my $html = $self->render_to_string(
        template => 'mainte/mainte_roominfo_new',
        format   => 'html',
    )->to_string;

    $model->html( \$html );
    my $output = $model->get_fill_in_roominfo();
    return $self->render( text => $output );
}

1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Controller::Mainte::Roominfo - roominfo テーブルのコントローラー

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Controller::Mainte::Roominfo version 0.0.1

=head1 SYNOPSIS (概要)

システム管理者 roominfo 関連機能のリクエストをコントロール

=head2 mainte_roominfo_serch

    リクエスト
    URL: http:// ... /mainte_roominfo_serch
    METHOD: GET

    リクエスト
    URL: http:// ... /mainte_roominfo_serch
    METHOD: GET
    PARAMETERS:
        storeinfo_id: (指定の数字)

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/mainte/mainte_roominfo_serch

    GET リクエストに storeinfo_id が指定された場合該当レコード表示
    該当レコードなき場合は全てのレコード表示

roominfo テーブル登録情報の確認、検索

=head2 mainte_roominfo_new

    リクエスト
    URL: http:// ... /mainte_roominfo_serch
    METHOD: GET
    PARAMETERS:
        id: (指定の数字)

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/mainte/mainte_roominfo_new

    roominfo テーブル指定のレコードの修正画面

    リクエスト
    URL: http:// ... /mainte_roominfo_new
    METHOD: POST
    PARAMETERS:
        id:             INTEGER (例: 10, 自動採番) 部屋情報ID
        storeinfo_id:   INTEGER (例: 10, 自動採番) 店舗ID
        name:           TEXT    (例: Aスタ) 部屋名
        starttime_on:   TEXT    (例: 6: '6:00', 7: '7:00', 8: '8:00',
            9: '9:00', 10: '10:00', 11: '11:00', 12: '12:00', 13: '13:00',
            14: '14:00', 15: '15:00', 16: '16:00', 17: '17:00', 18: '18:00',
            19: '19:00', 20: '20:00', 21: '21:00', 22: '22:00', 23: '23:00',
            24: '24:00', 25: '25:00', 26: '26:00', 27: '27:00', 28: '28:00',
            29: '29:00') 開始時刻

        endingtime_on:  TEXT    (例: 7: '7:00', 8: '8:00', 9: '9:00',
            10: '10:00', 11: '11:00', 12: '12:00', 13: '13:00', 14: '14:00',
            15: '15:00', 16: '16:00', 17: '17:00', 18: '18:00', 19: '19:00',
            20: '20:00', 21: '21:00', 22: '22:00', 23: '23:00', 24: '24:00',
            25: '25:00', 26: '26:00', 27: '27:00', 28: '28:00', 29: '29:00',
            30: '30:00') 終了時刻

        rentalunit:     INTEGER (例: 1: 1時間, 2: 2時間) 貸出単位
        time_change:    INTEGER (例: 0: ':00', 1: ':30') 開始時間切り替え
        pricescomments: TEXT    (例: １時間1,500から) 料金コメント
        privatepermit:  INTEGER (例: 0: 許可する, 1: 許可しない) 個人練習許可

        privatepeople:  INTEGER (例: 1: 1人まで, 2: 2人まで, 3: 3人まで)
            個人練習許可人数

        privateconditions: INTEGER  (例: 0: 当日予約のみ, 1: １日前より,
            2: ２日前より, 3: ３日前より, 4: ４日前より, 5: ５日前より,
            6: ６日前より, 7: ７日前より, 8: 条件なし, ) 個人練習許可条件

        bookinglimit:   INTEGER (例: 0: 制限なし, 1: １時間前, 2: ２時間前,
            3: ３時間前) 予約制限

        cancellimit:    INTEGER (例: 0: 当日不可, 1: １日前不可,
            2: ２日前不可, 3: ３日前不可, 4: ４日前不可, 5: ５日前不可,
            6: ６日前不可, 7: ７日前不可, 8: 制限なし) キャンセル制限
            (ネット上でキャンセルできる制限)

        remarks:        TEXT    (例: 3～4人向け) 備考
        webpublishing:  INTEGER (例: 0: 公開する, 1: 公開しない) web公開設定
        webreserve:     INTEGER (例: 0: 今月のみ, 1: １ヶ月先, 2: ２ヶ月先,
            3: ３ヶ月先) web予約受付設定

        status:     INTEGER (例: 0: 利用停止, 1: 利用開始) ステータス
        create_on:  TEXT    ( 例: 2015-06-06 12:24:12, datetime 形式) 登録日
        modify_on:  TEXT    ( 例: 2015-06-06 12:24:12, datetime 形式) 修正日

    レスポンス (バリデートエラー時)
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/auth/mainte_roominfo_new

    レスポンス (レコード書込み終了)
    URL: http:// ... /mainte_roominfo_serch

roominfo テーブルに既存レコード修正

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<FormValidator::Lite>

=item * L<HTML::FillInForm>

=item * L<Yoyakku::Model::Mainte>

=item * L<Yoyakku::Model::Mainte::Roominfo>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
