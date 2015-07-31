package Yoyakku::Controller::Profile;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Profile;

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Profile->new();

    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session );

    my $header_stash = $model->get_header_stash_auth_profile();

    return $self->redirect_to('/index') if !$header_stash;

    $self->stash($header_stash);

    return $model;
}

sub profile_comp {
    my $self  = shift;
    my $model = $self->_init();

    $self->stash(
        class         => 'profile_comp',
        login         => $model->login_name(),
        switch_acting => $model->get_switch_acting(),
    );

    $model->set_form_params_profile('profile_comp');
    $model->template('profile_comp');
    return $self->_render_profile($model);
}

sub profile {
    my $self  = shift;
    my $model = $self->_init();

    my $init_valid_params_profile = $model->get_init_valid_params_profile();

    $self->stash(
        class          => 'profile',
        login          => $model->login_name(),
        storeinfo_rows => $model->get_storeinfo_rows_all(),
        switch_acting  => $model->get_switch_acting(),
        %{$init_valid_params_profile},
    );

    $model->template('profile');

    return $self->_insert($model) if !$model->profile_row();
    return $self->_update($model);
}

sub _insert {
    my $self  = shift;
    my $model = shift;

    if ( 'GET' eq $model->method() ) {
        $model->set_form_params_profile('profile');
        return $self->_render_profile($model);
    }

    $model->type('insert');
    $model->flash_msg( +{ touroku => '登録完了' } );

    return $self->_common($model);
}

sub _update {
    my $self  = shift;
    my $model = shift;

    if ( 'GET' eq $model->method() ) {
        $model->set_form_params_profile('profile');
        return $self->_render_profile($model);
    }

    $model->type('update');
    $model->flash_msg( +{ henkou => '修正完了' } );

    return $self->_common($model);
}

sub _common {
    my $self  = shift;
    my $model = shift;

    my $valid_msg = $model->check_profile_with_auth_validator();

    return $self->stash($valid_msg), $self->_render_profile($model)
        if $valid_msg;

    $model->writing_profile();
    $self->flash( $model->flash_msg() );
    return $self->redirect_to('profile_comp');
}

sub _render_profile {
    my $self  = shift;
    my $model = shift;

    my $html = $self->render_to_string(
        template => $model->template(),
        format   => 'html',
    )->to_string;

    $model->html( \$html );
    my $output = $model->get_fill_in_profile();
    return $self->render( text => $output );
}

#         if ($id) {
#         #idがある時、修正データの場合sql実行profile and admin or general
#             my $count = $teng->update('profile' => {
#                 'nick_name'     => $nick_name,
#                 'full_name'     => $full_name,
#                 'phonetic_name' => $phonetic_name,
#                 'tel'           => $tel,
#                 'mail'          => $mail,
#                 'status'        => $status,
#                 'modify_on'     => $modify_on,
#             },{
#                 'id'            => $profile_id,
#             });

#             if ($general_id) {
#                 my $count = $teng->update('general' => {
#                     'password'  => $password,
#                     'status'    => $status,
#                     'modify_on' => $modify_on,
#                 },{
#                     'id'        => $id,
#                 });
#             }
#             elsif ($admin_id) {
#                 # まずはadmin書き込みstatus=1で承認
#                 my $count = $teng->update('admin' => {
#                     'password'  => $password,
#                     'status'    => $status,
#                     'modify_on' => $modify_on,
#                 },{
#                     'id'        => $id,
#                 });
#                 #今みている管理者idのidとステータスを取り出し
#                 my $admin_ref        = $teng->single('admin', +{id => $admin_id});
#                 my $new_admin_id     = $admin_ref->id;
#                 my $new_admin_status = $admin_ref->status;
#                 # storeinfoのデータを取得する
#                 my @storeinfos = $teng->search_named(q{select * from storeinfo;});
#                 my $check_admin_id = 1; #1はstoreinfo作成
#                 for my $storeinfo_ref (@storeinfos) {
#                     if ($storeinfo_ref->admin_id == $new_admin_id) {$check_admin_id = 0;} #0は作成しない
#                 }
#                 if ($check_admin_id) { #1なので書き込み実施
#                     if ($new_admin_status == 1) {
#                         my $row = $teng->insert('storeinfo' => {
#                             'admin_id'  => $new_admin_id,
#                             'status'    => 1,
#                             'create_on' => $create_on,
#                         });
#                         #今作った管理ユーザーidに該当するstoreinfoのstoreinfo_idを取得する もう一度storeinfoのデータを取得する
#                         my @storeinfos = $teng->search_named(q{select * from storeinfo;});
#                         my $new_storeinfo_id;
#                         foreach my $storeinfo_ref (@storeinfos) { #storeinfo検索
#                             if ($storeinfo_ref->admin_id == $new_admin_id) {$new_storeinfo_id = $storeinfo_ref->id;}#id取得
#                         } #storeinfo_idをつかってroominfoを１０件作成
#                         if ($new_storeinfo_id) {
#                             for (my $i=0;$i <10;++$i) {
#                                 my $row = $teng->insert('roominfo' => {
#                                     'storeinfo_id'      => $new_storeinfo_id,
#                                     'name'              => undef,
#                                     'starttime_on'      => "10:00",
#                                     'endingtime_on'     => "22:00",
#                                     'rentalunit'        => 1 ,
#                                     'pricescomments'    => "例）１時間２０００円より",
#                                     'privatepermit'     => 0,
#                                     'privatepeople'     => 2,
#                                     'privateconditions' => 0,
#                                     'bookinglimit'      => 0,
#                                     'cancellimit'       => 8,
#                                     'remarks'           => "例）スタジオ内の飲食は禁止です。",
#                                     'webpublishing'     => 1,
#                                     'webreserve'        => 3,
#                                     'status'            => 0,
#                                     'create_on'         => $create_on,
#                                 });
#                             }
#                         }
#                     }
#                 }
#             }
#             else {
#                 die "stop!!想定外エラー";
#             }
#             $self->flash(henkou => '修正完了');
#         }
#         else {
#         #idが無い場合は想定外！
#         die "stop!!想定外のエラー";
#         }
#         #sqlにデータ入力したのでlist画面にリダイレクト
#         return $self->redirect_to('profile_comp');
#         #リターンなのでここでおしまい。
#     }
#     #入力検査合格しなかった場合、もう一度入力フォーム表示Fillinにて
#     my $html = $self->render_partial()->to_string;
#     $html = HTML::FillInForm->fill(\$html, $self->req->params,);
#     return $self->render_text($html, format => 'html');
#     #リターンなのでここでおしまい。
# }

1;

__END__

# profile_comp.html.ep
# 個人情報、画面========================================
get '/profile_comp' => sub {
my $self = shift;
# テンプレート用bodyのクラス名
my $class = "profile_comp";
$self->stash(class => $class);


#ログイン機能==========================================
my $login_id;
my $login;
my $switch_header;

my $admin_id   = $self->session('session_admin_id'  );
my $general_id = $self->session('session_general_id');

if ($admin_id) {
    my $admin_ref   = $teng->single('admin', +{id => $admin_id});
    my $profile_ref = $teng->single('profile', +{admin_id => $admin_id});
       $login       = q{(admin)}.$profile_ref->nick_name;

    my $status = $admin_ref->status;
    if ($status) {
        my $storeinfo_ref = $teng->single('storeinfo', +{admin_id => $admin_id});
        if ($storeinfo_ref->status eq 0) {
            $switch_header = 9;
        }
            $switch_header = 7;
    }
    else {
        $switch_header = 8;
    }
    #お気に入りリスト表示
    my $switch_acting;
    $self->stash(switch_acting => $switch_acting);
}
elsif ($general_id) {
    my $general_ref  = $teng->single('general', +{id => $general_id});
    #$login         = $general_ref->login;
    my $profile_ref = $teng->single('profile', +{general_id => $general_id});
    $login          = $profile_ref->nick_name;

    my $status = $general_ref->status;
    if ($status) {
        $switch_header = 6;
    }
    else {
        $switch_header = 8;
    }
    #お気に入りリスト表示
    my $switch_acting = 1;
    $self->stash(switch_acting => $switch_acting);
}
else {
    #$switch_header = 2;
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
#--------
# データの表示,ログイン情報とprofile
my $id;
my $login;
my $password;
my $profile_ref;
my @actings_ref;

if ($admin_id) {
    my $admin_ref   = $teng->single('admin', +{id => $admin_id});
    $id             = $admin_ref->id;
    $login          = $admin_ref->login;
    $password       = $admin_ref->password;
    $profile_ref    = $teng->single('profile', +{admin_id => $admin_id});
}
elsif ($general_id) {
    my $general_ref = $teng->single('general', +{id => $general_id});
    $id             = $general_ref->id;
    $login          = $general_ref->login;
    $password       = $general_ref->password;
    $profile_ref    = $teng->single('profile', +{general_id => $general_id});
    @actings_ref    = $teng->search('acting',  +{general_id => $general_id , status => 1 });
}
else {
    die "stop!!予期せぬエラー";
}
#値作成==profile
my $profile_id    = $profile_ref->id ;
my $nick_name     = $profile_ref->nick_name;
my $full_name     = $profile_ref->full_name;
my $phonetic_name = $profile_ref->phonetic_name;
my $tel           = $profile_ref->tel;
my $mail          = $profile_ref->mail;
my @acting;

for my $acting_ref (@actings_ref) {
    push (@acting , $acting_ref->storeinfo_id);
}
my $acting_1_ref    = $teng->single('storeinfo', +{id => $acting[0]});
my $acting_2_ref    = $teng->single('storeinfo', +{id => $acting[1]});
my $acting_3_ref    = $teng->single('storeinfo', +{id => $acting[2]});

my $acting_1;
my $acting_2;
my $acting_3;

if ($acting_1_ref) {
    $acting_1      = $acting_1_ref->name;
}
if ($acting_2_ref) {
    $acting_2      = $acting_2_ref->name;
}
if ($acting_3_ref) {
    $acting_3      = $acting_3_ref->name;
}


#修正用フォーム、Fillinつかって表示 値はsqlより該当idのデータをつかう
my $html = $self->render_partial()->to_string;
$html = HTML::FillInForm->fill(
    \$html,{
        id            => $id ,
        login         => $login ,
        password      => $password ,
        #password_2    => $password ,
        profile_id    => $profile_id ,
        nick_name     => $nick_name,
        full_name     => $full_name,
        phonetic_name => $phonetic_name,
        tel           => $tel,
        mail          => $mail,
        acting_1      => $acting_1,
        acting_2      => $acting_2,
        acting_3      => $acting_3,
    },
);
#Fillin画面表示実行returnなのでここでおしまい。
return $self->render_text($html, format => 'html');


#$self->render('profile_comp');
};


# profile.html.ep
# 個人情報、画面========================================
any '/profile' => sub {
my $self = shift;
# テンプレート用bodyのクラス名
my $class = "profile";
$self->stash(class => $class);

#ログイン機能==========================================
my $login_id;
my $login;
my $switch_header;

my $admin_id   = $self->session('session_admin_id'  );
my $general_id = $self->session('session_general_id');

if ($admin_id) {
    my $admin_ref   = $teng->single('admin', +{id => $admin_id});
    my $profile_ref = $teng->single('profile', +{admin_id => $admin_id});
       $login       = q{(admin)}.$profile_ref->nick_name;

    my $status = $admin_ref->status;
    if ($status) {
        my $storeinfo_ref = $teng->single('storeinfo', +{admin_id => $admin_id});
        if ($storeinfo_ref->status eq 0) {
            $switch_header = 9;
        }
            $switch_header = 7;
    }
    else {
        $switch_header = 8;
    }
    #お気に入りリスト表示
    my $switch_acting;
    $self->stash(switch_acting => $switch_acting);
}
elsif ($general_id) {
    my $general_ref  = $teng->single('general', +{id => $general_id});
    #$login         = $general_ref->login;
    my $profile_ref = $teng->single('profile', +{general_id => $general_id});
    $login          = $profile_ref->nick_name;

    my $status = $general_ref->status;
    if ($status) {
        $switch_header = 6;
    }
    else {
        $switch_header = 8;
    }
    #お気に入りリスト表示
    my $switch_acting = 1;
    $self->stash(switch_acting => $switch_acting);
}
else {
    #$switch_header = 2;
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
#========
#お気に入り店舗のための選択データ取り出し
my @storeinfos = $teng->search_named(q{select * from storeinfo;});
$self->stash(storeinfos_ref => \@storeinfos);

#========
#--------
if (uc $self->req->method eq 'POST') {#post判定する
    #新規入力も修正もボタン押すとpostで入ってくる、両方バリデード実行
    my $validator = $self->create_validator;# バリデーション()
    $validator->field('nick_name')->required(1)->length(1,30);

    $validator->field('password')->regexp(qr/[a-zA-Z0-9]{4,}/);
    $validator->field('password_2')->required(1)->callback(sub {
        my $password_2 = shift;
        my $password   = $self->param('password');

        if ($password ne $password_2) {
            return (0, '入力したパスワードが違います');
        }
        else {
            return 1;
        }
    });
    $validator->field('full_name')->required(0)->length(1,30);
    $validator->field('phonetic_name')->required(0)->length(1,30);
    $validator->field('tel')->required(1)->length(1,30);
    $validator->field('mail')->required(0)->email;


    #actingのバリでを考えてみる
    #選択しなくてもよいが、同じstoreinfo_idが重複はng!
    $validator->field('acting_1')->required(0)->callback(sub {
        my $acting_1    = shift;
        my $acting_2    = $self->param('acting_2');
        my $acting_3    = $self->param('acting_3');

        my $judg_id;

        if ($acting_1) {
            if ($acting_1 eq $acting_2) {$judg_id = 1;}
            if ($acting_1 eq $acting_3) {$judg_id = 1;}
        }
        if ($acting_2) {
            if ($acting_2 eq $acting_1) {$judg_id = 1;}
            if ($acting_2 eq $acting_3) {$judg_id = 1;}
        }
        if ($acting_3) {
            if ($acting_3 eq $acting_1) {$judg_id = 1;}
            if ($acting_3 eq $acting_2) {$judg_id = 1;}
        }

        return   ($judg_id == 1) ? (0, '同じものは入力不可'  )
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
        # admin or general
        my $id             = $self->param('id');
        my $password       = $self->param('password');
        # profile
        my $profile_id     = $self->param('profile_id');
        my $nick_name      = $self->param('nick_name');
        my $full_name      = $self->param('full_name');
        my $phonetic_name  = $self->param('phonetic_name');
        my $tel            = $self->param('tel');
        my $mail           = $self->param('mail');
        my $status         = 1 ; # 承認させる
        my $create_on      = $today->datetime(date => '-', T => ' ');
        my $modify_on      = $today->datetime(date => '-', T => ' ');

        #先にお気に入りの登録をする
        my $acting_1       = $self->param('acting_1');
        my $acting_2       = $self->param('acting_2');
        my $acting_3       = $self->param('acting_3');
        #ステータスが1のactingをすべて0にしておく
        my @actings_ref    = $teng->search('acting',  +{general_id => $general_id , status => 1});
        if (@actings_ref) {
            my @acting_status;
            for my $acting_ref (@actings_ref) {
                push (@acting_status,$acting_ref->id);
            }

            for my $acting_id (@acting_status) {
                my $count = $teng->update('acting' => {
                    'status'        => 0,
                    'modify_on'     => $modify_on,
                },{
                    'id'            => $acting_id,
                });
            }
        }
        #すべてのactingを取り出し
        if ($acting_1) {
            my $acting1_ref    = $teng->single('acting',  +{general_id => $general_id , storeinfo_id => $acting_1});
            if ($acting1_ref) {
                my $acting_id = $acting1_ref->id;
                my $count = $teng->update('acting' => {
                    'status'        => $status,
                    'modify_on'     => $modify_on,
                },{
                    'id'            => $acting_id,
                });
            }
            else {
                my $row = $teng->insert('acting' => {
                    'general_id'    => $general_id,
                    'storeinfo_id'  => $acting_1,
                    'status'        => $status,
                    'create_on'     => $create_on,
                });
            }
        }


        if ($acting_2) {
            my $acting2_ref    = $teng->single('acting',  +{general_id => $general_id , storeinfo_id => $acting_2});
            if ($acting2_ref) {
                my $acting_id = $acting2_ref->id;
                my $count = $teng->update('acting' => {
                    'status'        => $status,
                    'modify_on'     => $modify_on,
                },{
                    'id'            => $acting_id,
                });
            }
            else {
                my $row = $teng->insert('acting' => {
                    'general_id'    => $general_id,
                    'storeinfo_id'  => $acting_2,
                    'status'        => $status,
                    'create_on'     => $create_on,
                });
            }
        }



        if ($acting_3) {
            my $acting3_ref    = $teng->single('acting',  +{general_id => $general_id , storeinfo_id => $acting_3});
            if ($acting3_ref) {
                my $acting_id = $acting3_ref->id;
                my $count = $teng->update('acting' => {
                    'status'        => $status,
                    'modify_on'     => $modify_on,
                },{
                    'id'            => $acting_id,
                });
            }
            else {
                my $row = $teng->insert('acting' => {
                    'general_id'    => $general_id,
                    'storeinfo_id'  => $acting_3,
                    'status'        => $status,
                    'create_on'     => $create_on,
                });
            }
        }








        ##if# (@actings_ref) {
        ##  #  for my $acting_ref (@actings_ref) {
        ##  #      if ($acting_1) {
        ##  #          if ($acting_ref->storeinfo_id eq $acting_1) {
        ##  #              my $acting_id = $acting_ref->id;
        ##  #              my $count = $teng->update('acting' => {
        ##  #                  'status'        => $status,
        ##  #                  'modify_on'     => $modify_on,
        ##  #              },{
        ##  #                  'id'            => $acting_id,
        ##  #              });
        ##  #          }
        ##  #          else {
        ##  #              my $row = $teng->insert('acting' => {
        ##  #                  'general_id'    => $general_id,
        ##  #                  'storeinfo_id'  => $acting_1,
        ##  #                  'status'        => $status,
        ##  #                  'create_on'     => $create_on,
        ##  #              });
        ##  #          }
        ##  #      }








                    #if ($acting_ref->storeinfo_id eq $acting_2) {
                    #    my $acting_id = $acting_ref->id;
                    #    my $count = $teng->update('acting' => {
                    #        'status'        => $status,
                    #        'modify_on'     => $modify_on,
                    #    },{
                    #        'id'            => $acting_id,
                    #    });
                    #}
                    #if ($acting_ref->storeinfo_id eq $acting_3) {
                    #    my $acting_id = $acting_ref->id;
                    #    my $count = $teng->update('acting' => {
                    #        'status'        => $status,
                    #        'modify_on'     => $modify_on,
                    #    },{
                    #        'id'            => $acting_id,
                    #    });
                    #}



        #   #     my $acting_id = $acting_ref->id;
        #   #     my $count = $teng->update('acting' => {
        #   #         'status'        => 0,
        #   #         'modify_on'     => $modify_on,
        #   #     },{
        #   #         'id'            => $acting_id,
        #   #     });






        #    }
        #}
        #else {
        #    if ($acting_1) {
        #        my $row = $teng->insert('acting' => {
        #            'general_id'    => $general_id,
        #            'storeinfo_id'  => $acting_1,
        #            'status'        => $status,
        #            'create_on'     => $create_on,
        #        });
        #    }
        #    if ($acting_2) {
        #        my $row = $teng->insert('acting' => {
        #            'general_id'    => $general_id,
        #            'storeinfo_id'  => $acting_2,
        #            'status'        => $status,
        #            'create_on'     => $create_on,
        #        });
        #    }
        #    if ($acting_3) {
        #        my $row = $teng->insert('acting' => {
        #            'general_id'    => $general_id,
        #            'storeinfo_id'  => $acting_3,
        #            'status'        => $status,
        #            'create_on'     => $create_on,
        #        });
        #    }
        #}

        if ($id) {
        #idがある時、修正データの場合sql実行profile and admin or general
            my $count = $teng->update('profile' => {
                'nick_name'     => $nick_name,
                'full_name'     => $full_name,
                'phonetic_name' => $phonetic_name,
                'tel'           => $tel,
                'mail'          => $mail,
                'status'        => $status,
                'modify_on'     => $modify_on,
            },{
                'id'            => $profile_id,
            });

            if ($general_id) {
                my $count = $teng->update('general' => {
                    'password'  => $password,
                    'status'    => $status,
                    'modify_on' => $modify_on,
                },{
                    'id'        => $id,
                });
            }
            elsif ($admin_id) {
                # まずはadmin書き込みstatus=1で承認
                my $count = $teng->update('admin' => {
                    'password'  => $password,
                    'status'    => $status,
                    'modify_on' => $modify_on,
                },{
                    'id'        => $id,
                });
                #今みている管理者idのidとステータスを取り出し
                my $admin_ref        = $teng->single('admin', +{id => $admin_id});
                my $new_admin_id     = $admin_ref->id;
                my $new_admin_status = $admin_ref->status;
                # storeinfoのデータを取得する
                my @storeinfos = $teng->search_named(q{select * from storeinfo;});
                my $check_admin_id = 1; #1はstoreinfo作成
                for my $storeinfo_ref (@storeinfos) {
                    if ($storeinfo_ref->admin_id == $new_admin_id) {$check_admin_id = 0;} #0は作成しない
                }
                if ($check_admin_id) { #1なので書き込み実施
                    if ($new_admin_status == 1) {
                        my $row = $teng->insert('storeinfo' => {
                            'admin_id'  => $new_admin_id,
                            'status'    => 1,
                            'create_on' => $create_on,
                        });
                        #今作った管理ユーザーidに該当するstoreinfoのstoreinfo_idを取得する もう一度storeinfoのデータを取得する
                        my @storeinfos = $teng->search_named(q{select * from storeinfo;});
                        my $new_storeinfo_id;
                        foreach my $storeinfo_ref (@storeinfos) { #storeinfo検索
                            if ($storeinfo_ref->admin_id == $new_admin_id) {$new_storeinfo_id = $storeinfo_ref->id;}#id取得
                        } #storeinfo_idをつかってroominfoを１０件作成
                        if ($new_storeinfo_id) {
                            for (my $i=0;$i <10;++$i) {
                                my $row = $teng->insert('roominfo' => {
                                    'storeinfo_id'      => $new_storeinfo_id,
                                    'name'              => undef,
                                    'starttime_on'      => "10:00",
                                    'endingtime_on'     => "22:00",
                                    'rentalunit'        => 1 ,
                                    'pricescomments'    => "例）１時間２０００円より",
                                    'privatepermit'     => 0,
                                    'privatepeople'     => 2,
                                    'privateconditions' => 0,
                                    'bookinglimit'      => 0,
                                    'cancellimit'       => 8,
                                    'remarks'           => "例）スタジオ内の飲食は禁止です。",
                                    'webpublishing'     => 1,
                                    'webreserve'        => 3,
                                    'status'            => 0,
                                    'create_on'         => $create_on,
                                });
                            }
                        }
                    }
                }
            }
            else {
                die "stop!!想定外エラー";
            }
            $self->flash(henkou => '修正完了');
        }
        else {
        #idが無い場合は想定外！
        die "stop!!想定外のエラー";
        }
        #sqlにデータ入力したのでlist画面にリダイレクト
        return $self->redirect_to('profile_comp');
        #リターンなのでここでおしまい。
    }
    #入力検査合格しなかった場合、もう一度入力フォーム表示Fillinにて
    my $html = $self->render_partial()->to_string;
    $html = HTML::FillInForm->fill(\$html, $self->req->params,);
    return $self->render_text($html, format => 'html');
    #リターンなのでここでおしまい。
}
#--------
# データの表示,ログイン情報とprofile
my $id;
my $login;
my $password;
my $profile_ref;
my @actings_ref;

if ($admin_id) {
    my $admin_ref   = $teng->single('admin', +{id => $admin_id});
    $id             = $admin_ref->id;
    $login          = $admin_ref->login;
    $password       = $admin_ref->password;
    $profile_ref    = $teng->single('profile', +{admin_id => $admin_id});
}
elsif ($general_id) {
    my $general_ref = $teng->single('general', +{id => $general_id});
    $id             = $general_ref->id;
    $login          = $general_ref->login;
    $password       = $general_ref->password;
    $profile_ref    = $teng->single('profile', +{general_id => $general_id});
    @actings_ref    = $teng->search('acting',  +{general_id => $general_id , status => 1 });
}
else {
    die "stop!!予期せぬエラー";
}
#値作成==profile
my $profile_id    = $profile_ref->id ;
my $nick_name     = $profile_ref->nick_name;
my $full_name     = $profile_ref->full_name;
my $phonetic_name = $profile_ref->phonetic_name;
my $tel           = $profile_ref->tel;
my $mail          = $profile_ref->mail;
my @acting;

for my $acting_ref (@actings_ref) {
    push (@acting , $acting_ref->storeinfo_id);
}
my $acting_1_ref    = $teng->single('storeinfo', +{id => $acting[0]});
my $acting_2_ref    = $teng->single('storeinfo', +{id => $acting[1]});
my $acting_3_ref    = $teng->single('storeinfo', +{id => $acting[2]});

my $acting_1;
my $acting_2;
my $acting_3;

if ($acting_1_ref) {
    $acting_1      = $acting_1_ref->id;
}
if ($acting_2_ref) {
    $acting_2      = $acting_2_ref->id;
}
if ($acting_3_ref) {
    $acting_3      = $acting_3_ref->id;
}

#修正用フォーム、Fillinつかって表示 値はsqlより該当idのデータをつかう
my $html = $self->render_partial()->to_string;
$html = HTML::FillInForm->fill(
    \$html,{
        id            => $id ,
        login         => $login ,
        password      => $password ,
        password_2    => $password ,
        profile_id    => $profile_id ,
        nick_name     => $nick_name,
        full_name     => $full_name,
        phonetic_name => $phonetic_name,
        tel           => $tel,
        mail          => $mail,
        acting_1      => $acting_1,
        acting_2      => $acting_2,
        acting_3      => $acting_3,
});
#Fillin画面表示実行returnなのでここでおしまい。
return $self->render_text($html, format => 'html');

#$self->render('profile');
};

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Controller::Profile - ログイン機能のコントローラー

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Controller::Profile version 0.0.1

=head1 SYNOPSIS (概要)

プロフィール関連機能のリクエストをコントロール

=head2 profile

    リクエスト
    URL: http:// ... /profile
    METHOD: GET

    他詳細は調査、実装中

プロフィール登録画面

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<HTML::FillInForm>

=item * L<Yoyakku::Model>

=item * L<Yoyakku::Model::Profile>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
