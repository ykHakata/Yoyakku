package Yoyakku::Controller::Mainte::Roominfo;
use Mojo::Base 'Mojolicious::Controller';
use FormValidator::Lite;
use HTML::FillInForm;
use Yoyakku::Controller::Mainte qw{check_login_mainte switch_stash};
use Yoyakku::Model::Mainte::Roominfo qw{
    search_storeinfo_id_for_roominfo_rows
    get_init_valid_params_roominfo
    search_roominfo_id_row
    writing_roominfo
    check_roominfo_validator
};

# 部屋情報 一覧 検索
sub mainte_roominfo_serch {
    my $self = shift;

    return $self->redirect_to('/index') if $self->check_login_mainte();

     # テンプレートbodyのクラス名を定義
    my $class = 'mainte_roominfo_serch';
    $self->stash( class => $class );

    # id検索時のアクション (該当の店舗を検索)
    my $storeinfo_id = $self->param('storeinfo_id');

    # id 検索時は指定のid検索して出力
    my $roominfo_rows = search_storeinfo_id_for_roominfo_rows($storeinfo_id);

    $self->stash( roominfo_rows => $roominfo_rows );

    return $self->render(
        template => 'mainte/mainte_roominfo_serch',
        format   => 'html',
    );
}

# 部屋情報 編集
sub mainte_roominfo_new {
    my $self = shift;

    return $self->redirect_to('/index') if $self->check_login_mainte();

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    return $self->redirect_to('/mainte_roominfo_serch')
        if ( $method ne 'GET' ) && ( $method ne 'POST' );

    return $self->redirect_to('/mainte_roominfo_serch') if !$params->{id};

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_roominfo_new';
    $self->stash( class => $class );

    my $init_valid_params_roominfo = get_init_valid_params_roominfo();

    $self->stash($init_valid_params_roominfo);

    return $self->_update();
}

sub _update {
    my $self = shift;

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    return $self->_render_update_form($params) if 'GET' eq $method;

    my $flash_msg = +{ henkou => '修正完了', };

    return $self->_common( 'update', $flash_msg, );
}

sub _common {
    my $self      = shift;
    my $type      = shift;
    my $flash_msg = shift;

    my $params = $self->req->params->to_hash;

    my $valid_msg = check_roominfo_validator($params);

    return $self->stash($valid_msg), $self->_render_roominfo($params)
        if $valid_msg;

    writing_roominfo( $type, $params );
    $self->flash($flash_msg);

    return $self->redirect_to('mainte_roominfo_serch');
}

sub _render_update_form {
    my $self   = shift;
    my $params = shift;

    my $roominfo_row = $self->search_roominfo_id_row( $params->{id} );

    my $starttime_on;
    my $endingtime_on;

    # 開始、終了時刻はデータを調整する00->24表示にする
    if ( $roominfo_row->starttime_on ) {
        $starttime_on = substr( $roominfo_row->starttime_on, 0, 2 );
        $starttime_on += 0;
        if ( $starttime_on =~ /^[0-5]$/ ) {
            $starttime_on += 24;
        }
    }

    if ( $roominfo_row->endingtime_on ) {
        $endingtime_on = substr( $roominfo_row->endingtime_on, 0, 2 );
        $endingtime_on += 0;
        if ( $endingtime_on =~ /^[0-6]$/ ) {
            $endingtime_on += 24;
        }
    }

    # 入力フォームフィルイン用
    $params = +{
        id                => $roominfo_row->id,
        storeinfo_id      => $roominfo_row->storeinfo_id,
        name              => $roominfo_row->name,
        starttime_on      => $starttime_on,
        endingtime_on     => $endingtime_on,
        rentalunit        => $roominfo_row->rentalunit,
        time_change       => $roominfo_row->time_change,
        pricescomments    => $roominfo_row->pricescomments,
        privatepermit     => $roominfo_row->privatepermit,
        privatepeople     => $roominfo_row->privatepeople,
        privateconditions => $roominfo_row->privateconditions,
        bookinglimit      => $roominfo_row->bookinglimit,
        cancellimit       => $roominfo_row->cancellimit,
        remarks           => $roominfo_row->remarks,
        webpublishing     => $roominfo_row->webpublishing,
        webreserve        => $roominfo_row->webreserve,
        status            => $roominfo_row->status,
        create_on         => $roominfo_row->create_on,
        modify_on         => $roominfo_row->modify_on,
    };

    return $self->_render_roominfo($params);
}

# テンプレート画面のレンダリング
sub _render_roominfo {
    my $self   = shift;
    my $params = shift;

    my $html = $self->render_to_string(
        template => 'mainte/mainte_roominfo_new',
        format   => 'html',
    )->to_string;

    my $output = HTML::FillInForm->fill( \$html, $params );

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
