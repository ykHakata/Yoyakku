package Yoyakku::Controller::Mainte::Profile;
use Mojo::Base 'Mojolicious::Controller';
use FormValidator::Lite;
use HTML::FillInForm;
use Yoyakku::Controller::Mainte qw{check_login_mainte switch_stash};
use Yoyakku::Model::Mainte::Profile qw{
    search_profile_id_rows
    select_general_rows
    select_admin_rows
};

# 個人情報 一覧 検索
sub mainte_profile_serch {
    my $self = shift;

    # ログイン確認する
    return $self->redirect_to('/index') if $self->check_login_mainte();

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_profile_serch';
    $self->stash( class => $class );

    # id検索時のアクション
    my $profile_id = $self->param('profile_id');

    # id 検索時は指定のid検索して出力
    my $profile_rows = $self->search_profile_id_rows($profile_id);

    $self->stash( profile_rows => $profile_rows );

    return $self->render(
        template => 'mainte/mainte_profile_serch',
        format   => 'html',
    );
}



# # mainte_profile_new.html.ep
# #個人情報の新規作成、修正、sql入力コントロール
# 個人情報 新規 編集
sub mainte_profile_new {
    my $self = shift;

    # ログイン確認する
    return $self->redirect_to('/index') if $self->check_login_mainte();

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_profile_new';
    $self->stash( class => $class );

    # バリデート用
    $self->stash(
        general_id    => '',
        admin_id      => '',
        nick_name     => '',
        full_name     => '',
        phonetic_name => '',
        tel           => '',
        mail          => '',
    );

    my $req    = $self->req;
    my $params = $req->params->to_hash;
    my $method = uc $req->method;

    # セレクト用の general admin ログイン名表示
    $self->stash(
        generals_ref => $self->select_general_rows(),
        admins_ref   => $self->select_admin_rows(),
    );

    # 新規作成画面表示用
    return $self->_render_profile($params)
        if !$params->{id} && ( 'POST' ne $method );

    if ('POST' ne $method) {
        # 修正画面表示用
        my $profile_row = $self->search_profile_id_row( $params->{id} );

        # 入力フォームフィルイン用
        $params = +{
            id            => $profile_row->id,
            general_id    => $profile_row->general_id,
            admin_id      => $profile_row->admin_id,
            nick_name     => $profile_row->nick_name,
            full_name     => $profile_row->full_name,
            phonetic_name => $profile_row->phonetic_name,
            tel           => $profile_row->tel,
            mail          => $profile_row->mail,
            status        => $profile_row->status,
            create_on     => $profile_row->create_on,
            modify_on     => $profile_row->modify_on,
        };
    }

    # テンプレート画面のレンダリング
    return $self->_render_profile($params) if 'POST' ne $method;

    # 入力フォームに値を入力して登録するボタン押した場合
    # バリデード実行
    my $validator = FormValidator::Lite->new($req);

    $validator->check(
        login    => [ 'NOT_NULL', ],
        password => [ 'NOT_NULL', ],
    );

    $validator->set_message(
        'login.not_null'    => '必須入力',
        'password.not_null' => '必須入力',
    );

    my @login_errors = $validator->get_error_messages_from_param('login');
    my @pass_errors  = $validator->get_error_messages_from_param('password');

    $self->stash->{login}    = shift @login_errors;
    $self->stash->{password} = shift @pass_errors;

    # 入力バリデート不合格の場合それ以降の作業はしない
    return $self->_render_profile($params) if $validator->has_error();

    # ログイン名(メルアド)の既存データとの照合
    # 既存データとの照合(DB バリデートチェック)
    if ( $params->{id} ) {
        # DB バリデート合格の場合 DB 書き込み(修正)
        $self->writing_profile( 'update', $params );
        $self->flash( henkou => '修正完了' );

        # sqlにデータ入力したので list 画面にリダイレクト
        return $self->redirect_to('mainte_profile_serch');
    }

    # DB バリデート合格の場合 DB 書き込み(新規)
    my $check_profile_row
        = $self->check_profile_login_name( $req->param('login') );

    if ($check_profile_row) {

        # ログイン名がすでに存在している
        $self->stash->{login} = '既に使用されてます';

        # テンプレート画面のレンダリング
        return $self->_render_profile($params);
    }

    $self->writing_profile( 'insert', $params );
    $self->flash( touroku => '登録完了' );

    return $self->redirect_to('mainte_profile_serch');
}

# テンプレート画面のレンダリング
sub _render_profile {
    my $self   = shift;
    my $params = shift;

    my $html = $self->render_to_string(
        template => 'mainte/mainte_profile_new',
        format   => 'html',
    )->to_string;

    my $output = HTML::FillInForm->fill( \$html, $params );

    return $self->render( text => $output );
}










# #書いてないけど、新規作成一発目はテンプレートの入力フォームレンダリング
# #---------
# if (uc $self->req->method eq 'POST') {#post判定する
#     #新規入力も修正もボタン押すとpostで入ってくる、両方バリデード実行
#     my $validator = $self->create_validator;# バリデーション()
#     $validator->field('general_id')->required(0)->callback(sub {
#         my $general_id    = shift;
#         my $admin_id      = $self->param('admin_id');
#         my $judg_id;
#         # 既に指定済みのidの重複をさける
#         my $id      = $self->param('id');

#         my @profiles = $teng->search_named(q{select * from profile;});

#         for my $profile_ref (@profiles) {
#             if ($profile_ref->id ne $id) {
#                 if ($profile_ref->general_id eq $general_id) {
#                     return (0, '既に利用されています');
#                 }
#                 if ($profile_ref->admin_id eq $admin_id) {
#                     return (0, '既に利用されています');
#                 }
#             }
#         }

#         if ($general_id eq "not_selected") {
#             $general_id = undef;
#         }
#         if ($admin_id eq "not_selected") {
#             $admin_id = undef;
#         }

#         if ($general_id and $admin_id) {
#             $judg_id = 1;
#         }
#         elsif (! $general_id and ! $admin_id) {
#             $judg_id = 1;
#         }

#         return   ($judg_id == 1) ? (0, '一般,管理どちらかにしてください'  )
#                :                    1
#                ;
#     });
#     $validator->field('nick_name')->required(0)->length(1,30);
#     $validator->field('full_name')->required(0)->length(1,30);
#     $validator->field('phonetic_name')->required(0)->length(1,30);
#     $validator->field('tel')->required(0)->length(1,30);
#     $validator->field('mail')->required(0)->email;

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
#         my $admin_id       = $self->param('admin_id');
#         my $nick_name      = $self->param('nick_name');
#         my $full_name      = $self->param('full_name');
#         my $phonetic_name  = $self->param('phonetic_name');
#         my $tel            = $self->param('tel');
#         my $mail           = $self->param('mail');
#         my $status         = $self->param('status');
#         my $create_on      = $today->datetime(date => '-', T => ' ');
#         my $modify_on      = $today->datetime(date => '-', T => ' ');
#         # not_selected を変換
#         if ($general_id eq "not_selected") {
#             $general_id = undef;
#         }
#         if ($admin_id eq "not_selected") {
#             $admin_id = undef;
#         }

#         if ($id) {
#         #idがある時、修正データの場合sql実行
#             my $count = $teng->update('profile' => {
#                 'general_id'    => $general_id,
#                 'admin_id'      => $admin_id,
#                 'nick_name'     => $nick_name,
#                 'full_name'     => $full_name,
#                 'phonetic_name' => $phonetic_name,
#                 'tel'           => $tel,
#                 'mail'          => $mail,
#                 'status'        => $status,
#                 'modify_on'     => $modify_on,
#             },{
#                 'id'            => $id,
#             });
#             $self->flash(henkou => '修正完了');
#         }
#         else { #idが無い場合、新規登録sql実行
#             my $row = $teng->insert('profile' => {
#                 'general_id'    => $general_id,
#                 'admin_id'      => $admin_id,
#                 'nick_name'     => $nick_name,
#                 'full_name'     => $full_name,
#                 'phonetic_name' => $phonetic_name,
#                 'tel'           => $tel,
#                 'mail'          => $mail,
#                 'status'        => $status,
#                 'create_on'     => $create_on,
#             });
#             $self->flash(touroku => '登録完了');
#         }
#         #sqlにデータ入力したのでlist画面にリダイレクト
#         return $self->redirect_to('mainte_profile_serch');
#         #リターンなのでここでおしまい。
#     }

# } else {#post以外(getの時)list画面から修正で移動してきた時
#     #idがある時、修正なのでsqlより該当のデータ抽出
#     my $id = $self->param('id');   #ID
#     my ($general_id,$admin_id,$nick_name,$full_name,$phonetic_name,$tel,$mail,$status,$create_on,$modify_on);

#     if ($id) {
#         # id検索、sql実行
#         my @rows = $teng->single('profile', {'id' => $id });
#         foreach my $row (@rows) {
#             $id            = $row->id ;
#             $general_id    = $row->general_id;
#             $admin_id      = $row->admin_id;
#             $nick_name     = $row->nick_name;
#             $full_name     = $row->full_name;
#             $phonetic_name = $row->phonetic_name;
#             $tel           = $row->tel;
#             $mail          = $row->mail;
#             $status        = $row->status;
#             $create_on     = $row->create_on ;
#             $modify_on     = $row->modify_on ;
#         }
#     }


1;

__END__
# mainte_profile_serch.html.ep
#個人情報のデータ検索コントロール-----------------------------
get '/mainte_profile_serch' => sub {
    my $self = shift;
    my $class = "mainte_profile_serch"; # テンプレートbodyのクラス名を定義
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
        my @rows = $teng->single('profile', {'id' => $id });
        $self->stash(rows_ref => \@rows);
    }else{ # sqlすべてのデータ出力
        my @rows = $teng->search_named(q{select * from profile;});
        $self->stash(rows_ref => \@rows);
    }
    $self->render('mainte_profile_serch');
};

#mainte_profile_new.html.ep
#個人情報の新規作成、修正、sql入力コントロール-----------------------------
any '/mainte_profile_new' => sub {
my $self = shift;
my $class = "mainte_profile_new"; # テンプレートbodyのクラス名を定義
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
my @admins = $teng->search_named(q{select * from admin;});
$self->stash(admins_ref => \@admins);


#書いてないけど、新規作成一発目はテンプレートの入力フォームレンダリング
#---------
if (uc $self->req->method eq 'POST') {#post判定する
    #新規入力も修正もボタン押すとpostで入ってくる、両方バリデード実行
    my $validator = $self->create_validator;# バリデーション()
    $validator->field('general_id')->required(0)->callback(sub {
        my $general_id    = shift;
        my $admin_id      = $self->param('admin_id');
        my $judg_id;
        # 既に指定済みのidの重複をさける
        my $id      = $self->param('id');

        my @profiles = $teng->search_named(q{select * from profile;});

        for my $profile_ref (@profiles) {
            if ($profile_ref->id ne $id) {
                if ($profile_ref->general_id eq $general_id) {
                    return (0, '既に利用されています');
                }
                if ($profile_ref->admin_id eq $admin_id) {
                    return (0, '既に利用されています');
                }
            }
        }

        if ($general_id eq "not_selected") {
            $general_id = undef;
        }
        if ($admin_id eq "not_selected") {
            $admin_id = undef;
        }

        if ($general_id and $admin_id) {
            $judg_id = 1;
        }
        elsif (! $general_id and ! $admin_id) {
            $judg_id = 1;
        }

        return   ($judg_id == 1) ? (0, '一般,管理どちらかにしてください'  )
               :                    1
               ;
    });
    $validator->field('nick_name')->required(0)->length(1,30);
    $validator->field('full_name')->required(0)->length(1,30);
    $validator->field('phonetic_name')->required(0)->length(1,30);
    $validator->field('tel')->required(0)->length(1,30);
    $validator->field('mail')->required(0)->email;

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
        my $admin_id       = $self->param('admin_id');
        my $nick_name      = $self->param('nick_name');
        my $full_name      = $self->param('full_name');
        my $phonetic_name  = $self->param('phonetic_name');
        my $tel            = $self->param('tel');
        my $mail           = $self->param('mail');
        my $status         = $self->param('status');
        my $create_on      = $today->datetime(date => '-', T => ' ');
        my $modify_on      = $today->datetime(date => '-', T => ' ');
        # not_selected を変換
        if ($general_id eq "not_selected") {
            $general_id = undef;
        }
        if ($admin_id eq "not_selected") {
            $admin_id = undef;
        }

        if ($id) {
        #idがある時、修正データの場合sql実行
            my $count = $teng->update('profile' => {
                'general_id'    => $general_id,
                'admin_id'      => $admin_id,
                'nick_name'     => $nick_name,
                'full_name'     => $full_name,
                'phonetic_name' => $phonetic_name,
                'tel'           => $tel,
                'mail'          => $mail,
                'status'        => $status,
                'modify_on'     => $modify_on,
            },{
                'id'            => $id,
            });
            $self->flash(henkou => '修正完了');
        }
        else { #idが無い場合、新規登録sql実行
            my $row = $teng->insert('profile' => {
                'general_id'    => $general_id,
                'admin_id'      => $admin_id,
                'nick_name'     => $nick_name,
                'full_name'     => $full_name,
                'phonetic_name' => $phonetic_name,
                'tel'           => $tel,
                'mail'          => $mail,
                'status'        => $status,
                'create_on'     => $create_on,
            });
            $self->flash(touroku => '登録完了');
        }
        #sqlにデータ入力したのでlist画面にリダイレクト
        return $self->redirect_to('mainte_profile_serch');
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
    my ($general_id,$admin_id,$nick_name,$full_name,$phonetic_name,$tel,$mail,$status,$create_on,$modify_on);

    if ($id) {
        # id検索、sql実行
        my @rows = $teng->single('profile', {'id' => $id });
        foreach my $row (@rows) {
            $id            = $row->id ;
            $general_id    = $row->general_id;
            $admin_id      = $row->admin_id;
            $nick_name     = $row->nick_name;
            $full_name     = $row->full_name;
            $phonetic_name = $row->phonetic_name;
            $tel           = $row->tel;
            $mail          = $row->mail;
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
            admin_id      => $admin_id,
            nick_name     => $nick_name,
            full_name     => $full_name,
            phonetic_name => $phonetic_name,
            tel           => $tel,
            mail          => $mail,
            status        => $status,
            create_on     => $create_on ,
            modify_on     => $modify_on
        },
    );
    #Fillin画面表示実行returnなのでここでおしまい。
    return $self->render_text($html, format => 'html');
}
};
