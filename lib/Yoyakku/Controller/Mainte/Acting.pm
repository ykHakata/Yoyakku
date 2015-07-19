package Yoyakku::Controller::Mainte::Acting;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Mainte::Acting;

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Mainte::Acting->new();

    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session->{root_id} );

    my $header_stash = $model->get_header_stash_auth_mainte();

    return if !$header_stash;

    $self->stash($header_stash);

    return $model;
}

sub mainte_acting_serch {
    my $self  = shift;
    my $model = $self->_init();

    return $self->redirect_to('/index') if !$model;

    my $acting_rows = $model->search_acting_id_rows();

    $self->stash(
        class       => 'mainte_acting_serch',
        acting_rows => $acting_rows,
    );

    return $self->render(
        template => 'mainte/mainte_acting_serch',
        format   => 'html',
    );
}

sub mainte_acting_new {
    my $self  = shift;
    my $model = $self->_init();

    return $self->redirect_to('/index') if !$model;

    return $self->redirect_to('/mainte_acting_serch')
        if ( $model->method() ne 'GET' ) && ( $model->method() ne 'POST' );

    my $init_valid_params_acting = $model->get_init_valid_params_acting();

    $self->stash(
        class          => 'mainte_acting_new',
        general_rows   => $model->get_general_rows_all(),
        storeinfo_rows => $model->get_storeinfo_rows_all(),
        %{$init_valid_params_acting},
    );

    return $self->_insert($model) if !$model->params()->{id};
    return $self->_update($model);
}

sub _insert {
    my $self  = shift;
    my $model = shift;

    return $self->_render_acting($model) if 'GET' eq $model->method();

    $model->type('insert');
    $model->flash_msg( +{ touroku => '登録完了' } );

    return $self->_common($model);
}

sub _update {
    my $self  = shift;
    my $model = shift;

    # return $self->_render_acting( $model->get_update_form_params_admin() )
    #     if 'GET' eq $model->method();

    # $model->type('update');
    # $model->flash_msg( +{ henkou => '修正完了' } );

    # return $self->_common($model);
}

sub _common {
    my $self  = shift;
    my $model = shift;

    my $valid_msg = $model->check_acting_validator();

    return $self->stash($valid_msg), $self->_render_acting($model)
        if $valid_msg;

    my $valid_msg_db = $model->check_acting_validator_db();

    return $self->stash($valid_msg_db), $self->_render_acting($model)
        if $valid_msg_db;

    $model->writing_acting();
    $self->flash( $model->flash_msg() );

    return $self->redirect_to('mainte_acting_serch');
}

sub _render_acting {
    my $self  = shift;
    my $model = shift;

    my $html = $self->render_to_string(
        template => 'mainte/mainte_acting_new',
        format   => 'html',
    )->to_string;

    $model->html( \$html );
    my $output = $model->get_fill_in_acting();
    return $self->render( text => $output );
}

# #書いてないけど、新規作成一発目はテンプレートの入力フォームレンダリング
# #---------
# if (uc $self->req->method eq 'POST') {#post判定する
#     #新規入力も修正もボタン押すとpostで入ってくる、両方バリデード実行
#     my $validator = $self->create_validator;# バリデーション()
#     $validator->field('general_id')->required(0)->callback(sub {
#         my $general_id    = shift;
#         my $storeinfo_id  = $self->param('storeinfo_id');
#         my $judg_id;
#         # 既に指定済みのidの重複をさける
#         my $id      = $self->param('id');

#         my @actings = $teng->search_named(q{select * from acting;});

#         for my $acting_ref (@actings) {
#             if ($acting_ref->id ne $id) {
#                 if ( ($acting_ref->general_id eq $general_id) and ($acting_ref->storeinfo_id eq $storeinfo_id) ) {
#                     return (0, '既に利用されています');
#                 }
#             }
#         }

#         if ($general_id eq "not_selected") {
#             $judg_id = 1;
#         }
#         if ($storeinfo_id eq "not_selected") {
#             $judg_id = 1;
#         }

#         return   ($judg_id == 1) ? (0, '両方を選んでください'  )
#                :                    1
#                ;
#     });

#     #mojoのコマンドでパラメーターをハッシュで取得入力した値をFIllin時に使うため、
#     my $param_hash = $self->req->params->to_hash;
#     $self->stash(param_hash => $param_hash);
#     #入力検査合格、の時、値を新規もしくは修正アップロード実行
#     if ( $self->validate($validator,$param_hash) ) {
#         #入力値を全部受け取っておく念のために時刻取得
#         my $today = localtime;
#         # 入力フォームから受ける値変数
#         my $id             = $self->param('id');
#         my $general_id     = $self->param('general_id');
#         my $storeinfo_id   = $self->param('storeinfo_id');
#         my $status         = $self->param('status');
#         my $create_on      = $today->datetime(date => '-', T => ' ');
#         my $modify_on      = $today->datetime(date => '-', T => ' ');
#         # not_selected を変換
#         if ($general_id eq "not_selected") {
#             $general_id = undef;
#         }
#         if ($storeinfo_id eq "not_selected") {
#             $storeinfo_id = undef;
#         }

#         if ($id) {
#         #idがある時、修正データの場合sql実行
#             my $count = $teng->update('acting' => {
#                 'general_id'    => $general_id,
#                 'storeinfo_id'  => $storeinfo_id,
#                 'status'        => $status,
#                 'modify_on'     => $modify_on,
#             },{
#                 'id'            => $id,
#             });
#             $self->flash(henkou => '修正完了');
#         }
#         else { #idが無い場合、新規登録sql実行
#             my $row = $teng->insert('acting' => {
#                 'general_id'    => $general_id,
#                 'storeinfo_id'  => $storeinfo_id,
#                 'status'        => $status,
#                 'create_on'     => $create_on,
#             });
#             $self->flash(touroku => '登録完了');
#         }
#         #sqlにデータ入力したのでlist画面にリダイレクト
#         return $self->redirect_to('mainte_acting_serch');
#         #リターンなのでここでおしまい。
#     }
#     #入力検査合格しなかった場合、もう一度入力フォーム表示Fillinにて
#     my $html = $self->render_partial()->to_string;
#     $html = HTML::FillInForm->fill(\$html, $self->req->params,);
#     return $self->render_text($html, format => 'html');
#     #リターンなのでここでおしまい。
# } else {#post以外(getの時)list画面から修正で移動してきた時
#     #idがある時、修正なのでsqlより該当のデータ抽出
#     my $id = $self->param('id');   #ID
#     my ($general_id,$storeinfo_id,$status,$create_on,$modify_on);

#     if ($id) {
#         # id検索、sql実行
#         my @rows = $teng->single('acting', {'id' => $id });
#         foreach my $row (@rows) {
#             $id            = $row->id ;
#             $general_id    = $row->general_id;
#             $storeinfo_id  = $row->storeinfo_id;
#             $status        = $row->status;
#             $create_on     = $row->create_on ;
#             $modify_on     = $row->modify_on ;
#         }
#     }
#     #修正用フォーム、Fillinつかって表示 値はsqlより該当idのデータをつかう
#     my $html = $self->render_partial()->to_string;
#     $html = HTML::FillInForm->fill(
#         \$html,{
#             id            => $id ,
#             general_id    => $general_id,
#             storeinfo_id  => $storeinfo_id,
#             status        => $status,
#             create_on     => $create_on ,
#             modify_on     => $modify_on
#         },
#     );
#     #Fillin画面表示実行returnなのでここでおしまい。
#     return $self->render_text($html, format => 'html');
# }
# };







1;

__END__

# mainte_acting_serch.html.ep
#個人情報のデータ検索コントロール-----------------------------
get '/mainte_acting_serch' => sub {
    my $self = shift;
    my $class = "mainte_acting_serch"; # テンプレートbodyのクラス名を定義
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

    my $id = $self->param('id');#id検索用
    if ($id) {# id検索の場合実行
        my @rows = $teng->single('acting', {'id' => $id });
        $self->stash(rows_ref => \@rows);
    }else{ # sqlすべてのデータ出力
        my @rows = $teng->search_named(q{select * from acting;});
        $self->stash(rows_ref => \@rows);
    }
    $self->render('mainte_acting_serch');
};

#mainte_acting_new.html.ep
#個人情報の新規作成、修正、sql入力コントロール-----------------------------
any '/mainte_acting_new' => sub {
my $self = shift;
my $class = "mainte_acting_new"; # テンプレートbodyのクラス名を定義
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

# 入力サポート用にgeneral_idとadmin_idのログイン名を送り込み
#店舗IDと店舗名を表示する
my @generals = $teng->search_named(q{select * from general;});
$self->stash(generals_ref => \@generals);
my @storeinfos = $teng->search_named(q{select * from storeinfo;});
$self->stash(storeinfos_ref => \@storeinfos);


#書いてないけど、新規作成一発目はテンプレートの入力フォームレンダリング
#---------
if (uc $self->req->method eq 'POST') {#post判定する
    #新規入力も修正もボタン押すとpostで入ってくる、両方バリデード実行
    my $validator = $self->create_validator;# バリデーション()
    $validator->field('general_id')->required(0)->callback(sub {
        my $general_id    = shift;
        my $storeinfo_id  = $self->param('storeinfo_id');
        my $judg_id;
        # 既に指定済みのidの重複をさける
        my $id      = $self->param('id');

        my @actings = $teng->search_named(q{select * from acting;});

        for my $acting_ref (@actings) {
            if ($acting_ref->id ne $id) {
                if ( ($acting_ref->general_id eq $general_id) and ($acting_ref->storeinfo_id eq $storeinfo_id) ) {
                    return (0, '既に利用されています');
                }
            }
        }

        if ($general_id eq "not_selected") {
            $judg_id = 1;
        }
        if ($storeinfo_id eq "not_selected") {
            $judg_id = 1;
        }

        return   ($judg_id == 1) ? (0, '両方を選んでください'  )
               :                    1
               ;
    });

    #mojoのコマンドでパラメーターをハッシュで取得入力した値をFIllin時に使うため、
    my $param_hash = $self->req->params->to_hash;
    $self->stash(param_hash => $param_hash);
    #入力検査合格、の時、値を新規もしくは修正アップロード実行
    if ( $self->validate($validator,$param_hash) ) {
        #入力値を全部受け取っておく念のために時刻取得
        my $today = localtime;
        # 入力フォームから受ける値変数
        my $id             = $self->param('id');
        my $general_id     = $self->param('general_id');
        my $storeinfo_id   = $self->param('storeinfo_id');
        my $status         = $self->param('status');
        my $create_on      = $today->datetime(date => '-', T => ' ');
        my $modify_on      = $today->datetime(date => '-', T => ' ');
        # not_selected を変換
        if ($general_id eq "not_selected") {
            $general_id = undef;
        }
        if ($storeinfo_id eq "not_selected") {
            $storeinfo_id = undef;
        }

        if ($id) {
        #idがある時、修正データの場合sql実行
            my $count = $teng->update('acting' => {
                'general_id'    => $general_id,
                'storeinfo_id'  => $storeinfo_id,
                'status'        => $status,
                'modify_on'     => $modify_on,
            },{
                'id'            => $id,
            });
            $self->flash(henkou => '修正完了');
        }
        else { #idが無い場合、新規登録sql実行
            my $row = $teng->insert('acting' => {
                'general_id'    => $general_id,
                'storeinfo_id'  => $storeinfo_id,
                'status'        => $status,
                'create_on'     => $create_on,
            });
            $self->flash(touroku => '登録完了');
        }
        #sqlにデータ入力したのでlist画面にリダイレクト
        return $self->redirect_to('mainte_acting_serch');
        #リターンなのでここでおしまい。
    }
    #入力検査合格しなかった場合、もう一度入力フォーム表示Fillinにて
    my $html = $self->render_partial()->to_string;
    $html = HTML::FillInForm->fill(\$html, $self->req->params,);
    return $self->render_text($html, format => 'html');
    #リターンなのでここでおしまい。
} else {#post以外(getの時)list画面から修正で移動してきた時
    #idがある時、修正なのでsqlより該当のデータ抽出
    my $id = $self->param('id');   #ID
    my ($general_id,$storeinfo_id,$status,$create_on,$modify_on);

    if ($id) {
        # id検索、sql実行
        my @rows = $teng->single('acting', {'id' => $id });
        foreach my $row (@rows) {
            $id            = $row->id ;
            $general_id    = $row->general_id;
            $storeinfo_id  = $row->storeinfo_id;
            $status        = $row->status;
            $create_on     = $row->create_on ;
            $modify_on     = $row->modify_on ;
        }
    }
    #修正用フォーム、Fillinつかって表示 値はsqlより該当idのデータをつかう
    my $html = $self->render_partial()->to_string;
    $html = HTML::FillInForm->fill(
        \$html,{
            id            => $id ,
            general_id    => $general_id,
            storeinfo_id  => $storeinfo_id,
            status        => $status,
            create_on     => $create_on ,
            modify_on     => $modify_on
        },
    );
    #Fillin画面表示実行returnなのでここでおしまい。
    return $self->render_text($html, format => 'html');
}
};
