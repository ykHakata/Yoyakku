package Yoyakku::Controller::Mainte::Ads;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Mainte::Ads;
use Data::Dumper;
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
    # return $self->_update($model);
}

sub _insert {
    my $self  = shift;
    my $model = shift;

    return $self->_render_ads($model) if 'GET' eq $model->method();

    $model->type('insert');
    $model->flash_msg( +{ touroku => '登録完了' } );

    return $self->_common($model);
}

sub _common {
    my $self  = shift;
    my $model = shift;

    my $valid_msg = $model->check_ads_validator();

    return $self->stash($valid_msg), $self->_render_ads($model)
        if $valid_msg;

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




# #書いてないけど、新規作成一発目はテンプレートの入力フォームレンダリング
# #---------
# #書き直し
# #post判定する
# if (uc $self->req->method eq 'POST') {
#     #新規入力も修正もボタン押すとpostで入ってくる、両方バリデード実行
#     # バリデーション()
#     my $validator = $self->create_validator;
#     $validator->field('url_ads')->required(1)->regexp(qr/^https?:\/\/.+/);
#     $validator->field('displaystart_on_ads')->required(1)->constraint('date', split => '-');
#     $validator->field('displayend_on_ads')->required(1)->constraint('date', split => '-');
#     $validator->field('name_ads')->required(1)->length(1,30);
#     $validator->field('content_ads')->required(1)->length(1,140);
#     $validator->field('event_date_ads')->required(1)->length(1,30);
#     #mojoのコマンドでパラメーターをハッシュで取得入力した値をFIllin時に使うため、
#     my $param_hash = $self->req->params->to_hash;
#     $self->stash(param_hash => $param_hash);
#     #入力検査合格、の時、値を新規もしくは修正アップロード実行
#     if ( $self->validate($validator,$param_hash) ) {
#         #ここでいったん入力値を全部受け取っておく 日付データ作成する
#         my $today = localtime;
#         my $in_ads_id               = $self->param('id_ads');             #広告ID
#         my $in_ads_kind             = $self->param('kind_ads');            #広告種別
#         my $in_ads_storeinfo_id     = $self->param('storeinfo_id_ads');    #店舗ID
#         my $in_ads_region_id        = $self->param('region_id_ads');        #地域区分ID
#         my $in_ads_url              = $self->param('url_ads');              #広告リンク先
#         my $in_ads_displaystart_on  = $self->param('displaystart_on_ads');  #表示開始日時
#         my $in_ads_displayend_on    = $self->param('displayend_on_ads');     #表示終了日時
#         my $in_ads_name             = $self->param('name_ads');              #広告名
#         my $in_ads_content          = $self->param('content_ads');         #広告内容
#         my $in_ads_event_date       = $self->param('event_date_ads');     #イベント広告日時
#         my $in_ads_create_on        = $today->datetime(date => '-', T => ' ');    #登録日time::pieceで自動挿入
#         my $in_ads_modify_on        = $today->datetime(date => '-', T => ' ');    #修正日time::pieceで自動挿入
#         #idがある時、修正データの場合sql実行
#         if ($in_ads_id) {
#             #修正データをsqlへ送り込む
#             my $count = $teng->update(
#                 'ads' => {
#                     'kind'             => $in_ads_kind,            #広告種別
#                     'storeinfo_id'     => $in_ads_storeinfo_id,    #店舗ID
#                     'region_id'        => $in_ads_region_id,        #地域区分ID
#                     'url'              => $in_ads_url,              #広告リンク先
#                     'displaystart_on'  => $in_ads_displaystart_on,  #表示開始日時
#                     'displayend_on'    => $in_ads_displayend_on,     #表示終了日時
#                     'name'             => $in_ads_name,              #広告名
#                     'content'          => $in_ads_content,         #広告内容
#                     'event_date'       => $in_ads_event_date,     #イベント広告日時
#                     'modify_on'        => $in_ads_modify_on,     #修正日
#                 }, {
#                     'id' => $in_ads_id,
#                 }
#             );
#             $self->flash(henkou => '修正完了');
#         } else {
#         #idが無い場合、新規登録sql実行 新規登録データをsqlへ送り込む
#         my $row = $teng->insert('ads' => {
#                 'kind'             => $in_ads_kind,            #広告種別
#                 'storeinfo_id'     => $in_ads_storeinfo_id,    #店舗ID
#                 'region_id'        => $in_ads_region_id,        #地域区分ID
#                 'url'              => $in_ads_url,              #広告リンク先
#                 'displaystart_on'  => $in_ads_displaystart_on,  #表示開始日時
#                 'displayend_on'    => $in_ads_displayend_on,     #表示終了日時
#                 'name'             => $in_ads_name,              #広告名
#                 'content'          => $in_ads_content,         #広告内容
#                 'event_date'       => $in_ads_event_date,     #イベント広告日時
#                 'create_on'        => $in_ads_create_on,   #登録日
#             });
#             $self->flash(touroku => '登録完了');
#         }
#         #sqlにデータ入力したのでlist画面にリダイレクト
#         return $self->redirect_to('mainte_ads_serch');
#         #リターンなのでここでおしまい。
#     }
#     #入力検査合格しなかった場合、もう一度入力フォーム表示Fillinにて
#     my $html = $self->render_partial()->to_string;
#     $html = HTML::FillInForm->fill(\$html, $self->req->params,);
#     return $self->render_text($html, format => 'html');
#     #リターンなのでここでおしまい。
# #post以外(getの時)list画面から修正で移動してきた時
# } else {
#     #idがある時、修正なのでsqlより該当のデータ抽出
#     my $in_ads_id = $self->param('id_ads');   #広告ID
#     #変数定義
#     my ($id,$kind,$storeinfo_id,$region_id,$url,
#         $displaystart_on,$displayend_on,$name,$event_date,
#         $content,$create_on,$modify_on);
#     if ($in_ads_id) {
#         # id検索、sql実行
#         my @rows = $teng->single('ads', {'id' => $in_ads_id });
#         foreach my $row (@rows) {
#             $id              = $row->id ;
#             $kind            = $row->kind ;
#             $storeinfo_id    = $row->storeinfo_id ;
#             $region_id       = $row->region_id ;
#             $url             = $row->url ;
#             $displaystart_on = $row->displaystart_on ;
#             $displayend_on   = $row->displayend_on ;
#             $name            = $row->name ;
#             $event_date      = $row->event_date ;
#             $content         = $row->content ;
#             $create_on       = $row->create_on ;
#             $modify_on       = $row->modify_on ;
#         }
#     }
#     #修正用フォーム、Fillinつかって表示
#     #値はsqlより該当idのデータをつかう
#     my $html = $self->render_partial()->to_string;
#     $html = HTML::FillInForm->fill(
#         \$html,{
#             id_ads              => $id ,
#             kind_ads            => $kind ,
#             storeinfo_id_ads    => $storeinfo_id ,
#             region_id_ads       => $region_id ,
#             url_ads             => $url ,
#             displaystart_on_ads => $displaystart_on ,
#             displayend_on_ads   => $displayend_on ,
#             name_ads            => $name ,
#             event_date_ads      => $event_date ,
#             content_ads         => $content ,
#             create_on_ads       => $create_on ,
#             modify_on_ads       => $modify_on
#         },
#     );
#     #Fillin画面表示実行returnなのでここでおしまい。
#     return $self->render_text($html, format => 'html');
# }
# };









1;

__END__

#イベント広告のデータ検索コントロール-----------------------------
get '/mainte_ads_serch' => sub {
    my $self = shift;
    my $class = "mainte_ads_serch"; # テンプレートbodyのクラス名を定義
    $self->stash(class => $class);
#ログイン機能==========================================
my $login_id;
my $login;
my $switch_header;

$login_id = $self->session('root_id');

if ($login_id) {
    if ($login_id eq "yoyakku") {
        $login = $login_id;
        $switch_header = 1;
    }
    else {return $self->redirect_to('index');}
}
else {
    return $self->redirect_to('index');
}

$self->stash(login => $login);# #ログイン名をヘッダーの右に表示させる
# headerの切替
$self->stash(switch_header => $switch_header);
#====================================================
#====================================================
#日付変更線を６時に変更
my $now_date    = localtime;

my $chang_date_ref = chang_date_6($now_date);

my $now_date    = $chang_date_ref->{now_date};
my $next1m_date = $chang_date_ref->{next1m_date};
my $next2m_date = $chang_date_ref->{next2m_date};
my $next3m_date = $chang_date_ref->{next3m_date};
#====================================================
##新しい日付情報取得のスクリプト======================
## 時刻(日付)取得、現在、1,2,3ヶ月後
#my $now_date    = localtime;
#
##翌月の計算をやり直す
#my $first_day   = localtime->strptime($now_date->strftime(   '%Y-%m-01'                             ),'%Y-%m-%d');
#my $last_day    = localtime->strptime($now_date->strftime(   '%Y-%m-' . $now_date->month_last_day   ),'%Y-%m-%d');
#my $next1m_date = localtime->strptime($now_date->strftime(   '%Y-%m-' . $now_date->month_last_day   ),'%Y-%m-%d') + 86400;
#my $next2m_date = localtime->strptime($next1m_date->strftime('%Y-%m-' . $next1m_date->month_last_day),'%Y-%m-%d') + 86400;
#my $next3m_date = localtime->strptime($next2m_date->strftime('%Y-%m-' . $next2m_date->month_last_day),'%Y-%m-%d') + 86400;
# 時刻(日付)取得、現在、1,2,3ヶ月後(ヘッダー用)
$self->stash(
    now_data    => $now_date,
    next1m_data => $next1m_date,
    next2m_data => $next2m_date,
    next3m_data => $next3m_date
);

    my $ads_id = $self->param('ads_id');#id検索用
    if ($ads_id) {# id検索の場合実行
        my @ads_rows = $teng->single('ads', {'id' => $ads_id });
        $self->stash(ads_rows_ref => \@ads_rows);
    }else{ # sqlすべてのデータ出力
        my @ads_rows = $teng->search_named(q{select * from ads;});
        $self->stash(ads_rows_ref => \@ads_rows);
    }
    $self->render('mainte_ads_serch');
};

#イベント広告の新規作成、修正、sql入力コントロール-----------------------------
any '/mainte_ads_new' => sub {
my $self = shift;
my $class = "mainte_ads_new"; # テンプレートbodyのクラス名を定義
$self->stash(class => $class);
#ログイン機能==========================================
my $login_id;
my $login;
my $switch_header;

$login_id = $self->session('root_id');

if ($login_id) {
    if ($login_id eq "yoyakku") {
        $login = $login_id;
        $switch_header = 1;
    }
    else {return $self->redirect_to('index');}
}
else {
    return $self->redirect_to('index');
}

$self->stash(login => $login);# #ログイン名をヘッダーの右に表示させる
# headerの切替
$self->stash(switch_header => $switch_header);
#====================================================
#====================================================
#日付変更線を６時に変更
my $now_date    = localtime;

my $chang_date_ref = chang_date_6($now_date);

my $now_date    = $chang_date_ref->{now_date};
my $next1m_date = $chang_date_ref->{next1m_date};
my $next2m_date = $chang_date_ref->{next2m_date};
my $next3m_date = $chang_date_ref->{next3m_date};
#====================================================
##新しい日付情報取得のスクリプト======================
## 時刻(日付)取得、現在、1,2,3ヶ月後
#my $now_date    = localtime;
#
##翌月の計算をやり直す
#my $first_day   = localtime->strptime($now_date->strftime(   '%Y-%m-01'                             ),'%Y-%m-%d');
#my $last_day    = localtime->strptime($now_date->strftime(   '%Y-%m-' . $now_date->month_last_day   ),'%Y-%m-%d');
#my $next1m_date = localtime->strptime($now_date->strftime(   '%Y-%m-' . $now_date->month_last_day   ),'%Y-%m-%d') + 86400;
#my $next2m_date = localtime->strptime($next1m_date->strftime('%Y-%m-' . $next1m_date->month_last_day),'%Y-%m-%d') + 86400;
#my $next3m_date = localtime->strptime($next2m_date->strftime('%Y-%m-' . $next2m_date->month_last_day),'%Y-%m-%d') + 86400;
# 時刻(日付)取得、現在、1,2,3ヶ月後(ヘッダー用)
$self->stash(
    now_data    => $now_date,
    next1m_data => $next1m_date,
    next2m_data => $next2m_date,
    next3m_data => $next3m_date
);

#店舗IDと店舗名を表示する
my @storeinfos = $teng->search_named(q{select id,name from storeinfo;});
$self->stash(storeinfos => \@storeinfos);
# 地域IDと地域名を表示(全国都道府県のみ)
my @regions = $teng->search_named(q{
select id,name from region where id REGEXP '(^[0-4][0-9])0{3}$' order by id asc;
});
$self->stash(regions => \@regions);

#書いてないけど、新規作成一発目はテンプレートの入力フォームレンダリング
#---------
#書き直し
#post判定する
if (uc $self->req->method eq 'POST') {
    #新規入力も修正もボタン押すとpostで入ってくる、両方バリデード実行
    # バリデーション()
    my $validator = $self->create_validator;
    $validator->field('url_ads')->required(1)->regexp(qr/^https?:\/\/.+/);
    $validator->field('displaystart_on_ads')->required(1)->constraint('date', split => '-');
    $validator->field('displayend_on_ads')->required(1)->constraint('date', split => '-');
    $validator->field('name_ads')->required(1)->length(1,30);
    $validator->field('content_ads')->required(1)->length(1,140);
    $validator->field('event_date_ads')->required(1)->length(1,30);
    #mojoのコマンドでパラメーターをハッシュで取得入力した値をFIllin時に使うため、
    my $param_hash = $self->req->params->to_hash;
    $self->stash(param_hash => $param_hash);
    #入力検査合格、の時、値を新規もしくは修正アップロード実行
    if ( $self->validate($validator,$param_hash) ) {
        #ここでいったん入力値を全部受け取っておく 日付データ作成する
        my $today = localtime;
        my $in_ads_id               = $self->param('id_ads');             #広告ID
        my $in_ads_kind             = $self->param('kind_ads');            #広告種別
        my $in_ads_storeinfo_id     = $self->param('storeinfo_id_ads');    #店舗ID
        my $in_ads_region_id        = $self->param('region_id_ads');        #地域区分ID
        my $in_ads_url              = $self->param('url_ads');              #広告リンク先
        my $in_ads_displaystart_on  = $self->param('displaystart_on_ads');  #表示開始日時
        my $in_ads_displayend_on    = $self->param('displayend_on_ads');     #表示終了日時
        my $in_ads_name             = $self->param('name_ads');              #広告名
        my $in_ads_content          = $self->param('content_ads');         #広告内容
        my $in_ads_event_date       = $self->param('event_date_ads');     #イベント広告日時
        my $in_ads_create_on        = $today->datetime(date => '-', T => ' ');    #登録日time::pieceで自動挿入
        my $in_ads_modify_on        = $today->datetime(date => '-', T => ' ');    #修正日time::pieceで自動挿入
        #idがある時、修正データの場合sql実行
        if ($in_ads_id) {
            #修正データをsqlへ送り込む
            my $count = $teng->update(
                'ads' => {
                    'kind'             => $in_ads_kind,            #広告種別
                    'storeinfo_id'     => $in_ads_storeinfo_id,    #店舗ID
                    'region_id'        => $in_ads_region_id,        #地域区分ID
                    'url'              => $in_ads_url,              #広告リンク先
                    'displaystart_on'  => $in_ads_displaystart_on,  #表示開始日時
                    'displayend_on'    => $in_ads_displayend_on,     #表示終了日時
                    'name'             => $in_ads_name,              #広告名
                    'content'          => $in_ads_content,         #広告内容
                    'event_date'       => $in_ads_event_date,     #イベント広告日時
                    'modify_on'        => $in_ads_modify_on,     #修正日
                }, {
                    'id' => $in_ads_id,
                }
            );
            $self->flash(henkou => '修正完了');
        } else {
        #idが無い場合、新規登録sql実行 新規登録データをsqlへ送り込む
        my $row = $teng->insert('ads' => {
                'kind'             => $in_ads_kind,            #広告種別
                'storeinfo_id'     => $in_ads_storeinfo_id,    #店舗ID
                'region_id'        => $in_ads_region_id,        #地域区分ID
                'url'              => $in_ads_url,              #広告リンク先
                'displaystart_on'  => $in_ads_displaystart_on,  #表示開始日時
                'displayend_on'    => $in_ads_displayend_on,     #表示終了日時
                'name'             => $in_ads_name,              #広告名
                'content'          => $in_ads_content,         #広告内容
                'event_date'       => $in_ads_event_date,     #イベント広告日時
                'create_on'        => $in_ads_create_on,   #登録日
            });
            $self->flash(touroku => '登録完了');
        }
        #sqlにデータ入力したのでlist画面にリダイレクト
        return $self->redirect_to('mainte_ads_serch');
        #リターンなのでここでおしまい。
    }
    #入力検査合格しなかった場合、もう一度入力フォーム表示Fillinにて
    my $html = $self->render_partial()->to_string;
    $html = HTML::FillInForm->fill(\$html, $self->req->params,);
    return $self->render_text($html, format => 'html');
    #リターンなのでここでおしまい。
#post以外(getの時)list画面から修正で移動してきた時
} else {
    #idがある時、修正なのでsqlより該当のデータ抽出
    my $in_ads_id = $self->param('id_ads');   #広告ID
    #変数定義
    my ($id,$kind,$storeinfo_id,$region_id,$url,
        $displaystart_on,$displayend_on,$name,$event_date,
        $content,$create_on,$modify_on);
    if ($in_ads_id) {
        # id検索、sql実行
        my @rows = $teng->single('ads', {'id' => $in_ads_id });
        foreach my $row (@rows) {
            $id              = $row->id ;
            $kind            = $row->kind ;
            $storeinfo_id    = $row->storeinfo_id ;
            $region_id       = $row->region_id ;
            $url             = $row->url ;
            $displaystart_on = $row->displaystart_on ;
            $displayend_on   = $row->displayend_on ;
            $name            = $row->name ;
            $event_date      = $row->event_date ;
            $content         = $row->content ;
            $create_on       = $row->create_on ;
            $modify_on       = $row->modify_on ;
        }
    }
    #修正用フォーム、Fillinつかって表示
    #値はsqlより該当idのデータをつかう
    my $html = $self->render_partial()->to_string;
    $html = HTML::FillInForm->fill(
        \$html,{
            id_ads              => $id ,
            kind_ads            => $kind ,
            storeinfo_id_ads    => $storeinfo_id ,
            region_id_ads       => $region_id ,
            url_ads             => $url ,
            displaystart_on_ads => $displaystart_on ,
            displayend_on_ads   => $displayend_on ,
            name_ads            => $name ,
            event_date_ads      => $event_date ,
            content_ads         => $content ,
            create_on_ads       => $create_on ,
            modify_on_ads       => $modify_on
        },
    );
    #Fillin画面表示実行returnなのでここでおしまい。
    return $self->render_text($html, format => 'html');
}
};
