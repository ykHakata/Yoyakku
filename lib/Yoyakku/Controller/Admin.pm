package Yoyakku::Controller::Admin;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Admin;

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Admin - 店舗管理のコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Admin version 0.0.1

=head1 SYNOPSIS (概要)

    店舗管理、関連機能のリクエストをコントロール

=cut

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Admin->new();
    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session );
    $model->check_auth_db_yoyakku();
    my $header_stash = $model->get_header_stash_admin();
    return $header_stash if $header_stash eq 'index';
    return $header_stash if $header_stash eq 'profile';
    $self->stash($header_stash);
    return $model;
}

=head2 admin_store_edit

    選択店舗情報確認コントロール

=cut

sub admin_store_edit {
    my $self = shift;

    my $model = $self->_init();
    return $self->redirect_to($model) if $model eq 'index';
    return $self->redirect_to($model) if $model eq 'profile';
    return $self->redirect_to('index')
        if ( $model->method() ne 'GET' ) && ( $model->method() ne 'POST' );

    my $init_valid_params_admin_store_edit
        = $model->get_init_valid_params_admin_store_edit();

    my $switch_com = $model->get_switch_com();
    $self->stash(
        class      => 'admin_store_edit',
        switch_com => $switch_com,
        %{$init_valid_params_admin_store_edit},
    );

    if ( 'GET' eq $model->method() ) {
        $model->get_login_storeinfo_params();
        return $self->_render_admin_store_edit($model);
    }

    return $self->_cancel($model) if $model->params('cancel');
}

sub _cancel {
    my $self  = shift;
    my $model = shift;
    $model->get_login_storeinfo_id();
    return $self->_render_admin_store_edit($model);
}

sub _update {

}

sub _common {

}

sub _render_admin_store_edit {
    my $self  = shift;
    my $model = shift;

    my $html = $self->render_to_string(
        template => 'admin/admin_store_edit',
        format   => 'html',
    )->to_string;

    $model->html( \$html );
    my $output = $model->get_fill_in_admin();
    return $self->render( text => $output );
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Admin>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut



#admin_store_edit.html.ep
#選択店舗情報確認コントロール-----------------------------
any '/admin_store_edit' => sub {
my $self = shift;
# テンプレートbodyのクラス名を定義

#----------
#sql入力にはpost、判定のif文
if (uc $self->req->method eq 'POST') {
#submitボタンによる選別
my $cancel      = $self->param('cancel');
my $post_search = $self->param('post_search');
#キャンセルボタンの場合
if ($cancel) {
        #値をすべて空にする
        my $id            = $self->param('id');#idだけ残す
        my $region_id     ;
        #my $admin_id     ;
        my $name          ;
        my $icon          ;
        my $post          ;
        my $state         ;
        my $cities        ;
        my $addressbelow  ;
        my $tel           ;
        my $mail          ;
        my $remarks       ;
        my $url           ;
        #my $locationinfor;
        #my $status       ;
        #my $create_on    ;
        #my $modify_on    ;
        #修正用フォーム、Fillinつかって表示 値はsqlより該当idのデータをつかう
        my $html = $self->render_partial()->to_string;
        $html = HTML::FillInForm->fill(
            \$html,{
            id            => $id ,
            region_id     => $region_id ,
            #admin_id      => $admin_id ,
            name          => $name ,
            icon          => $icon ,
            post          => $post ,
            state         => $state ,
            cities        => $cities ,
            addressbelow  => $addressbelow ,
            tel           => $tel ,
            mail          => $mail ,
            remarks       => $remarks ,
            url           => $url ,
            #locationinfor => $locationinfor ,
            #status        => $status ,
            #create_on     => $create_on ,
            #modify_on     => $modify_on
        },
        );
        #Fillin画面表示実行returnなのでここでおしまい。
        return $self->render_text($html, format => 'html');
}
#検索(郵便)の場合
elsif ($post_search) {
        my $id            = $self->param('id');
        my $region_id     = $self->param('region_id');
        #my $admin_id      = $self->param('admin_id');
        my $name          = $self->param('name');
        my $icon          = $self->param('icon');
        my $post          = $self->param('post');
        my $state         = $self->param('state');
        my $cities        = $self->param('cities');
        my $addressbelow  = $self->param('addressbelow');
        my $tel           = $self->param('tel');
        my $mail          = $self->param('mail');
        my $remarks       = $self->param('remarks');
        my $url           = $self->param('url');
        #my $locationinfor = $self->param('locationinfor');
        #my $status        = $self->param('status');
        #my $create_on     = $self->param('create_on');
        #my $modify_on     = $self->param('modify_on');
        my $mark = 0;
        #郵便データ検索
        if ($post) {
            my @post_rows = $teng->search_named(q{select * from post;});
            #該当データ取り出し
            foreach my $post_row_ref (@post_rows) {
                if ($post_row_ref->post_id == $post) {
                    $post      = $post_row_ref->post_id;
                    $region_id = $post_row_ref->region_id;
                    $state     = $post_row_ref->state;
                    $cities    = $post_row_ref->cities;
                    $mark      = 1;
                }
            }
            #該当する郵便番号見つからない時のメッセージ
            if (! $mark) {
                    $region_id = 0;
                    $state     = "登録なし";
                    $cities    = "登録なし";
            }
        }
        #修正用フォーム、Fillinつかって表示 値はsqlより該当idのデータをつかう
        my $html = $self->render_partial()->to_string;
        $html = HTML::FillInForm->fill(
            \$html,{
            id            => $id ,
            region_id     => $region_id ,
            #admin_id      => $admin_id ,
            name          => $name ,
            icon          => $icon ,
            post          => $post ,
            state         => $state ,
            cities        => $cities ,
            addressbelow  => $addressbelow ,
            tel           => $tel ,
            mail          => $mail ,
            remarks       => $remarks ,
            url           => $url ,
            #locationinfor => $locationinfor ,
            #status        => $status ,
            #create_on     => $create_on ,
            #modify_on     => $modify_on
        },
        );
        #Fillin画面表示実行returnなのでここでおしまい。
        return $self->render_text($html, format => 'html');
}
#完了の場合
else {
    #完了の場合バリデート実行
    my $validator = $self->create_validator;# バリデーション()
    $validator->field('name'         )->required(1)->length(1,20);
    $validator->field('post'         )->required(1)->regexp(qr/^\d{3}\d{4}$/);
    $validator->field('state'        )->required(1)->length(1,20);
    $validator->field('cities'       )->required(1)->length(1,20);
    $validator->field('addressbelow' )->required(1)->length(1,20);
    $validator->field('tel'          )->required(1)->length(1,20);
    $validator->field('mail'         )->required(0)->email;
    $validator->field('remarks'      )->required(0)->length(1,200);
    $validator->field('url'          )->required(1)->regexp(qr/^https?:\/\/.+/);
    #$validator->field('locationinfor')->required(1)->length(1,20);
    #$validator->field('status'       )->required(1)->length(1,20);
    #mojoのコマンドでパラメーターをハッシュで取得入力した値をFIllin時に使うため、
    my $param_hash = $self->req->params->to_hash;
    $self->stash(param_hash => $param_hash);
    #入力検査合格、の時、修正アップロード実行
    if ( $self->validate($validator,$param_hash) ) {
    #念のためにここで改めて時刻取得
    my $today = localtime;
    #入力用パラメータ受け取り
    my $id           = $self->param('id');
    my $region_id    = $self->param('region_id');
    my $name         = $self->param('name');
    my $icon         = $self->param('icon');
    my $post         = $self->param('post');
    my $state        = $self->param('state');
    my $cities       = $self->param('cities');
    my $addressbelow = $self->param('addressbelow');
    my $tel          = $self->param('tel');
    my $mail         = $self->param('mail');
    my $url          = $self->param('url');
    my $remarks      = $self->param('remarks');
    my $modify_on    = $today->datetime(date => '-', T => ' ');   #修正日
    #修正データの場合sql実行
    if ($id) {
        my $count = $teng->update(
            'storeinfo' => {
                'region_id'     => $region_id,      #地域区分ID
                #'admin_id'      => $admin_id,       #管理ユーザーID ログインしたときに出来るはず
                'name'          => $name,           #店舗名
                'icon'          => $icon,           #店舗アイコン
                'post'          => $post,           #住所郵便
                'state'         => $state,          #住所都道府県
                'cities'        => $cities,         #住所市町村
                'addressbelow'  => $addressbelow,   #住所以下
                'tel'           => $tel,            #電話番号
                'mail'          => $mail,           #メールアドレス
                'remarks'       => $remarks,        #店舗備考欄
                'url'           => $url,            #店舗リンク先
                #    'locationinfor' => $locationinfor,  #地図位置情報 どうやってつくる？
                #    'status'        => $status,         #ステータス 定義がきまってない。
                'modify_on'     => $modify_on,      #修正日 新規はないので、
            }, {
                'id' => $id,
            }
        );

    #sqlにデータ入力したのでリダイレクト
    return $self->redirect_to('admin_store_comp');
    #リターンなのでここでおしまい。
    }
    #idが無い場合、は正常に働いていないので、deiを出しておく
    else { die "idganai!!"; }
    }
    #入力検査合格しなかった場合、もう一度入力フォーム表示Fillinにて
    my $html = $self->render_partial()->to_string;
    $html = HTML::FillInForm->fill(\$html, $self->req->params,);
    return $self->render_text($html, format => 'html');
    #リターンなのでここでおしまい。
}

}

#Fillin画面表示実行returnなのでここでおしまい。
return $self->render_text($html, format => 'html');

#$self->render('admin_store_edit');
};
