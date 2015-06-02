package Yoyakku::Controller::Mainte::General;
use Mojo::Base 'Mojolicious::Controller';
# use FormValidator::Lite;
# use HTML::FillInForm;
use Yoyakku::Controller::Mainte qw{check_login_mainte switch_stash};
use Yoyakku::Model::Mainte::General
    qw{
        search_general_id_rows
    };

# mainte_general_serch.html.ep
#一般ユーザーのデータ検索コントロール-----------------------------
sub mainte_general_serch {
    my $self = shift;

    # ログイン確認する
    return $self->redirect_to('/index') if $self->check_login_mainte();

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_general_serch';
    $self->stash( class => $class );
    # id検索時のアクション
    my $general_id = $self->param('general_id');

    # id 検索時は指定のid検索して出力
    my $general_rows = $self->search_general_id_rows($general_id);

    $self->stash( rows_ref => $general_rows );

    return $self->render(
        template => 'mainte/mainte_general_serch',
        format   => 'html',
    );
}

1;



# #mainte_general_new.html.ep
# #一般ユーザーの新規作成、修正、sql入力コントロール-----------------------------
# any '/mainte_general_new' => sub {
# my $self = shift;
# my $class = "mainte_general_new"; # テンプレートbodyのクラス名を定義
# $self->stash(class => $class);
# #ログイン機能==========================================
# my $login_id;
# my $login;
# my $switch_header;

# $login_id = $self->session('root_id');

# if ($login_id) {
#     if ($login_id eq "yoyakku") {
#         $login = $login_id;
#         $switch_header = 1;
#     }
#     else {return $self->redirect_to('index');}
# }
# else {
#     return $self->redirect_to('index');
# }

# $self->stash(login => $login);# #ログイン名をヘッダーの右に表示させる
# # headerの切替
# $self->stash(switch_header => $switch_header);
# #====================================================
# #====================================================
# #日付変更線を６時に変更
# my $now_date    = localtime;

# my $chang_date_ref = chang_date_6($now_date);

# my $now_date    = $chang_date_ref->{now_date};
# my $next1m_date = $chang_date_ref->{next1m_date};
# my $next2m_date = $chang_date_ref->{next2m_date};
# my $next3m_date = $chang_date_ref->{next3m_date};
# #====================================================
# ##新しい日付情報取得のスクリプト======================
# ## 時刻(日付)取得、現在、1,2,3ヶ月後
# #my $now_date    = localtime;
# #
# ##翌月の計算をやり直す
# #my $first_day   = localtime->strptime($now_date->strftime(   '%Y-%m-01'                             ),'%Y-%m-%d');
# #my $last_day    = localtime->strptime($now_date->strftime(   '%Y-%m-' . $now_date->month_last_day   ),'%Y-%m-%d');
# #my $next1m_date = localtime->strptime($now_date->strftime(   '%Y-%m-' . $now_date->month_last_day   ),'%Y-%m-%d') + 86400;
# #my $next2m_date = localtime->strptime($next1m_date->strftime('%Y-%m-' . $next1m_date->month_last_day),'%Y-%m-%d') + 86400;
# #my $next3m_date = localtime->strptime($next2m_date->strftime('%Y-%m-' . $next2m_date->month_last_day),'%Y-%m-%d') + 86400;
# # 時刻(日付)取得、現在、1,2,3ヶ月後(ヘッダー用)
# $self->stash(
#     now_data    => $now_date,
#     next1m_data => $next1m_date,
#     next2m_data => $next2m_date,
#     next3m_data => $next3m_date
# );

# #書いてないけど、新規作成一発目はテンプレートの入力フォームレンダリング
# #---------
# if (uc $self->req->method eq 'POST') {#post判定する
#     #新規入力も修正もボタン押すとpostで入ってくる、両方バリデード実行
#     my $validator = $self->create_validator;# バリデーション()
#     $validator->field('login')->required(1)->length(1,20)->callback(sub {
#         my $login    = shift;

#         my $id        = $self->param('id');

#         my $judg_login = 0;
#         my $general_ref      = $teng->single('general', +{login => $login});

#         #my $login_name    ;

#         # 今編集しているidのログインidのダブりは省く
#         if ($general_ref) {
#             #die "hoge";
#             if ($general_ref->id eq $id) {
#                 $general_ref = 0;
#             }
#         }


#         if ($general_ref) {
#             $judg_login = 1 ;
#         }
#         else {
#             $judg_login = 0 ;
#         }

#         return   ($judg_login == 1) ? (0, '既に使用されてます'  )
#                :                       1
#                ;
#     });




#     $validator->field('password')->required(1)->length(1,10);
#     #mojoのコマンドでパラメーターをハッシュで取得入力した値をFIllin時に使うため、
#     my $param_hash = $self->req->params->to_hash;
#     $self->stash(param_hash => $param_hash);
#     #入力検査合格、の時、値を新規もしくは修正アップロード実行
#     if ( $self->validate($validator,$param_hash) ) {
#         #入力値を全部受け取っておく念のために時刻取得
#         my $today = localtime;
#         # 入力フォームから受ける値変数
#         my $id        = $self->param('id');
#         my $login     = $self->param('login');
#         my $password  = $self->param('password');
#         my $status    = $self->param('status');
#         my $create_on = $today->datetime(date => '-', T => ' ');
#         my $modify_on = $today->datetime(date => '-', T => ' ');
#         if ($id) {
#         #idがある時、修正データの場合sql実行
#             my $count = $teng->update('general' => {
#                 'login'     => $login,
#                 'password'  => $password,
#                 'status'    => $status,
#                 'modify_on' => $modify_on,
#             },{
#                 'id'        => $id,
#             });
#             $self->flash(henkou => '修正完了');
#         }
#         else { #idが無い場合、新規登録sql実行
#             my $row = $teng->insert('general' => {
#                 'login'     => $login,
#                 'password'  => $password,
#                 'status'    => $status,
#                 'create_on' => $create_on,
#             });
#             $self->flash(touroku => '登録完了');
#         }
#         #sqlにデータ入力したのでlist画面にリダイレクト
#         return $self->redirect_to('mainte_general_serch');
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
#     my ($login,$password,$status,$create_on,$modify_on);
#     if ($id) {
#         # id検索、sql実行
#         my @rows = $teng->single('general', {'id' => $id });
#         foreach my $row (@rows) {
#             $id        = $row->id ;
#             $login     = $row->login ;
#             $password  = $row->password ;
#             $status    = $row->status ;
#             $create_on = $row->create_on ;
#             $modify_on = $row->modify_on ;
#         }
#     }
#     #修正用フォーム、Fillinつかって表示 値はsqlより該当idのデータをつかう
#     my $html = $self->render_partial()->to_string;
#     $html = HTML::FillInForm->fill(
#         \$html,{
#             id        => $id ,
#             login     => $login ,
#             password  => $password ,
#             status    => $status ,
#             create_on => $create_on ,
#             modify_on => $modify_on
#         },
#     );
#     #Fillin画面表示実行returnなのでここでおしまい。
#     return $self->render_text($html, format => 'html');
# }
# };


__END__

# mainte_general_serch.html.ep
#一般ユーザーのデータ検索コントロール-----------------------------
get '/mainte_general_serch' => sub {
    my $self = shift;
    my $class = "mainte_general_serch"; # テンプレートbodyのクラス名を定義
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
        my @rows = $teng->single('general', {'id' => $id });
        $self->stash(rows_ref => \@rows);
    }else{ # sqlすべてのデータ出力
        my @rows = $teng->search_named(q{select * from general;});
        $self->stash(rows_ref => \@rows);
    }
    $self->render('mainte_general_serch');
};

#mainte_general_new.html.ep
#一般ユーザーの新規作成、修正、sql入力コントロール-----------------------------
any '/mainte_general_new' => sub {
my $self = shift;
my $class = "mainte_general_new"; # テンプレートbodyのクラス名を定義
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

#書いてないけど、新規作成一発目はテンプレートの入力フォームレンダリング
#---------
if (uc $self->req->method eq 'POST') {#post判定する
    #新規入力も修正もボタン押すとpostで入ってくる、両方バリデード実行
    my $validator = $self->create_validator;# バリデーション()
    $validator->field('login')->required(1)->length(1,20)->callback(sub {
        my $login    = shift;

        my $id        = $self->param('id');

        my $judg_login = 0;
        my $general_ref      = $teng->single('general', +{login => $login});

        #my $login_name    ;

        # 今編集しているidのログインidのダブりは省く
        if ($general_ref) {
            #die "hoge";
            if ($general_ref->id eq $id) {
                $general_ref = 0;
            }
        }


        if ($general_ref) {
            $judg_login = 1 ;
        }
        else {
            $judg_login = 0 ;
        }

        return   ($judg_login == 1) ? (0, '既に使用されてます'  )
               :                       1
               ;
    });




    $validator->field('password')->required(1)->length(1,10);
    #mojoのコマンドでパラメーターをハッシュで取得入力した値をFIllin時に使うため、
    my $param_hash = $self->req->params->to_hash;
    $self->stash(param_hash => $param_hash);
    #入力検査合格、の時、値を新規もしくは修正アップロード実行
    if ( $self->validate($validator,$param_hash) ) {
        #入力値を全部受け取っておく念のために時刻取得
        my $today = localtime;
        # 入力フォームから受ける値変数
        my $id        = $self->param('id');
        my $login     = $self->param('login');
        my $password  = $self->param('password');
        my $status    = $self->param('status');
        my $create_on = $today->datetime(date => '-', T => ' ');
        my $modify_on = $today->datetime(date => '-', T => ' ');
        if ($id) {
        #idがある時、修正データの場合sql実行
            my $count = $teng->update('general' => {
                'login'     => $login,
                'password'  => $password,
                'status'    => $status,
                'modify_on' => $modify_on,
            },{
                'id'        => $id,
            });
            $self->flash(henkou => '修正完了');
        }
        else { #idが無い場合、新規登録sql実行
            my $row = $teng->insert('general' => {
                'login'     => $login,
                'password'  => $password,
                'status'    => $status,
                'create_on' => $create_on,
            });
            $self->flash(touroku => '登録完了');
        }
        #sqlにデータ入力したのでlist画面にリダイレクト
        return $self->redirect_to('mainte_general_serch');
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
    my ($login,$password,$status,$create_on,$modify_on);
    if ($id) {
        # id検索、sql実行
        my @rows = $teng->single('general', {'id' => $id });
        foreach my $row (@rows) {
            $id        = $row->id ;
            $login     = $row->login ;
            $password  = $row->password ;
            $status    = $row->status ;
            $create_on = $row->create_on ;
            $modify_on = $row->modify_on ;
        }
    }
    #修正用フォーム、Fillinつかって表示 値はsqlより該当idのデータをつかう
    my $html = $self->render_partial()->to_string;
    $html = HTML::FillInForm->fill(
        \$html,{
            id        => $id ,
            login     => $login ,
            password  => $password ,
            status    => $status ,
            create_on => $create_on ,
            modify_on => $modify_on
        },
    );
    #Fillin画面表示実行returnなのでここでおしまい。
    return $self->render_text($html, format => 'html');
}
};
