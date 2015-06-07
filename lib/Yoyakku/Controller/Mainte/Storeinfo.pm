package Yoyakku::Controller::Mainte::Storeinfo;
use Mojo::Base 'Mojolicious::Controller';
use FormValidator::Lite qw{Email URL};
use HTML::FillInForm;
use Yoyakku::Controller::Mainte qw{check_login_mainte switch_stash};
use Yoyakku::Model::Mainte::Storeinfo qw{
    search_storeinfo_id_rows
    search_storeinfo_id_row
    search_zipcode_for_address
    writing_storeinfo
};

# 店舗情報 一覧 検索
sub mainte_storeinfo_serch {
    my $self = shift;

    # ログイン確認する
    return $self->redirect_to('/index') if $self->check_login_mainte();

     # テンプレートbodyのクラス名を定義
    my $class = 'mainte_storeinfo_serch';
    $self->stash( class => $class );

    # id検索時のアクション
    my $storeinfo_id = $self->param('storeinfo_id');

    # id 検索時は指定のid検索して出力
    my $storeinfo_rows = $self->search_storeinfo_id_rows($storeinfo_id);

    $self->stash( storeinfo_rows => $storeinfo_rows );

    return $self->render(
        template => 'mainte/mainte_storeinfo_serch',
        format   => 'html',
    );
}

# 店舗情報 新規 編集
sub mainte_storeinfo_new {
    my $self = shift;

    # ログイン確認する
    return $self->redirect_to('/index') if $self->check_login_mainte();

    # 編集のみを許可
    return $self->redirect_to('/mainte_storeinfo_serch')
        if !$self->param('id');

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_storeinfo_new';
    $self->stash( class => $class );

    # バリデート用
    $self->stash(
        name          => '',
        post          => '',
        state         => '',
        cities        => '',
        addressbelow  => '',
        tel           => '',
        mail          => '',
        remarks       => '',
        url           => '',
        locationinfor => '',
        status        => '',
    );

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    # 新規作成画面表示用
    return $self->_render_storeinfo($params)
        if !$params->{id} && ( 'POST' ne $method );

    if ('POST' ne $method) {
        # 修正画面表示用
        my $storeinfo_row = $self->search_storeinfo_id_row( $params->{id} );

        # 入力フォームフィルイン用
        $params = +{
            id            => $storeinfo_row->id,
            region_id     => $storeinfo_row->region_id,
            admin_id      => $storeinfo_row->admin_id,
            name          => $storeinfo_row->name,
            icon          => $storeinfo_row->icon,
            post          => $storeinfo_row->post,
            state         => $storeinfo_row->state,
            cities        => $storeinfo_row->cities,
            addressbelow  => $storeinfo_row->addressbelow,
            tel           => $storeinfo_row->tel,
            mail          => $storeinfo_row->mail,
            remarks       => $storeinfo_row->remarks,
            url           => $storeinfo_row->url,
            locationinfor => $storeinfo_row->locationinfor,
            status        => $storeinfo_row->status,
            create_on     => $storeinfo_row->create_on,
            modify_on     => $storeinfo_row->modify_on,
        };
    }

    # テンプレート画面のレンダリング
    return $self->_render_storeinfo($params) if 'POST' ne $method;

    # 郵便番号検索ボタンが押されたときの処理
    if ( $params->{kensaku} && $params->{kensaku} eq '検索する' ) {

        my $address_params
            = $self->search_zipcode_for_address( $params->{post} );

        $params->{region_id} = $address_params->{region_id};
        $params->{post}      = $address_params->{post};
        $params->{state}     = $address_params->{state};
        $params->{cities}    = $address_params->{cities};

        return $self->_render_storeinfo($params);
    }

    # 入力フォームに値を入力して登録するボタン押した場合
    # バリデード実行
    my $validator = FormValidator::Lite->new($params);

    $validator->check(
        name          => [ [ 'LENGTH', 0, 20, ], ],
        post          => [ 'INT', ],
        state         => [ [ 'LENGTH', 0, 20, ], ],
        cities        => [ [ 'LENGTH', 0, 20, ], ],
        addressbelow  => [ [ 'LENGTH', 0, 20, ], ],
        tel           => [ [ 'LENGTH', 0, 20, ], ],
        mail          => [ 'EMAIL_LOOSE', ],
        remarks       => [ [ 'LENGTH', 0, 200, ], ],
        url           => [ 'HTTP_URL', ],
        locationinfor => [ [ 'LENGTH', 0, 20, ], ],
        status        => [ 'INT', ],
    );

    $validator->set_message(
        'name.length'         => '文字数!!',
        'post.int'            => '指定の形式で入力してください',
        'state.length'        => '文字数!!',
        'cities.length'       => '文字数!!',
        'addressbelow.length' => '文字数!!',
        'tel.length'          => '文字数!!',
        'mail.email_loose'    => 'Eメールを入力してください',
        'remarks.length'      => '文字数!!',
        'url.http_url'        => '指定の形式で入力してください',
        'locationinfor.length' => '文字数!!',
        'status.int' => '指定の形式で入力してください',
    );

    my @name_errors   = $validator->get_error_messages_from_param('name');
    my @post_errors   = $validator->get_error_messages_from_param('post');
    my @state_errors  = $validator->get_error_messages_from_param('state');
    my @cities_errors = $validator->get_error_messages_from_param('cities');
    my @addressbelow_errors
        = $validator->get_error_messages_from_param('addressbelow');
    my @tel_errors     = $validator->get_error_messages_from_param('tel');
    my @mail_errors    = $validator->get_error_messages_from_param('mail');
    my @remarks_errors = $validator->get_error_messages_from_param('remarks');
    my @url_errors     = $validator->get_error_messages_from_param('url');
    my @locationinfor_errors
        = $validator->get_error_messages_from_param('locationinfor');
    my @status_errors = $validator->get_error_messages_from_param('status');

    # バリデート用メッセージ
    $self->stash(
        name          => shift @name_errors,
        post          => shift @post_errors,
        state         => shift @state_errors,
        cities        => shift @cities_errors,
        addressbelow  => shift @addressbelow_errors,
        tel           => shift @tel_errors,
        mail          => shift @mail_errors,
        remarks       => shift @remarks_errors,
        url           => shift @url_errors,
        locationinfor => shift @locationinfor_errors,
        status        => shift @status_errors,
    );

    # 入力バリデート不合格の場合それ以降の作業はしない
    return $self->_render_storeinfo($params) if $validator->has_error();

    if ( $params->{id} ) {
        # DB バリデート合格の場合 DB 書き込み(修正)
        $self->writing_storeinfo( 'update', $params );
        $self->flash( henkou => '修正完了' );

        # sqlにデータ入力したので list 画面にリダイレクト
        return $self->redirect_to('mainte_storeinfo_serch');
    }

    return _render_storeinfo($params);
}

# テンプレート画面のレンダリング
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
