package Yoyakku::Controller::Entry;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Entry;

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Controller::Entry - オープニングカレンダーのコントローラー

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Controller::Entry version 0.0.1

=head1 SYNOPSIS (概要)

    登録、関連機能のリクエストをコントロール

=cut

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Entry->new();
    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session );
    $model->check_auth_db_yoyakku();
    my $header_stash = $model->get_header_stash_entry();
    $self->stash($header_stash);
    return $model;
}

=head2 entry

    登録画面

=cut

sub entry {
    my $self  = shift;
    my $model = $self->_init();

    # my $now_date = $model->get_date_info('now_date');
    # my $caps     = $model->get_calender_caps();
    # my $cal_now  = $model->get_calendar_info($now_date);
    # my $ads_rows = $model->get_cal_info_ads_rows($now_date);

    # $self->stash(
    #     class    => 'entry_this_m',
    #     now_date => $now_date,
    #     cal_now  => $cal_now,
    #     caps     => $caps,
    #     ads_rows => $ads_rows,
    # );

    # アイコン?
    my $switch_load = 0;
    $self->stash(switch_load => $switch_load);

    my $mail_j;
    $self->stash(mail_j => $mail_j);

    my $class = "entry"; # テンプレートbodyのクラス名を定義
    $self->stash(class => $class);


    return $self->render( template => 'entry/entry', format => 'html', );
}

1;

__END__
#entry.html.ep
#ログイン登録希望、画面コントロール-----------------------------
any '/entry' => sub {
    my $self = shift;
    my $class = "entry"; # テンプレートbodyのクラス名を定義
    $self->stash(class => $class);
    #my $today = localtime;
    #$self->stash(today => $today);
#ログイン機能==========================================
my $login_id;
my $login;
my $switch_header;

my $admin_id   = $self->session('session_admin_id'  );
my $general_id = $self->session('session_general_id');

if ($admin_id) {
    #my $admin_ref   = $teng->single('admin', +{id => $admin_id});
    #my $profile_ref = $teng->single('profile', +{admin_id => $admin_id});
    #   $login       = q{(admin)}.$profile_ref->nick_name;
    #
    #my $status = $admin_ref->status;
    #if ($status) {
    #    my $storeinfo_ref = $teng->single('storeinfo', +{admin_id => $admin_id});
    #    if ($storeinfo_ref->status eq 0) {
    #        $switch_header = 9;
    #    }
    #        $switch_header = 4;
    #}
    #else {
    #    #$switch_header = 8;
    #    return $self->redirect_to('profile');
    #}
    return $self->redirect_to('index');
}
elsif ($general_id) {
    #my $general_ref  = $teng->single('general', +{id => $general_id});
    ##$login         = $general_ref->login;
    #my $profile_ref = $teng->single('profile', +{general_id => $general_id});
    #$login          = $profile_ref->nick_name;
    #
    #my $status = $general_ref->status;
    #if ($status) {
    #    $switch_header = 3;
    #}
    #else {
    #    #$switch_header = 8;
    #    return $self->redirect_to('profile');
    #}
    return $self->redirect_to('index');
}
else {
    $switch_header = 2;
    #return $self->redirect_to('index');
}

$self->stash(login => $login);# #ログイン名をヘッダーの右に表示させる
# headerの切替
$self->stash(switch_header => $switch_header);
#====================================================
#新しい日付情報取得のスクリプト======================
# 時刻(日付)取得、現在、1,2,3ヶ月後
my $now_date    = localtime;

#翌月の計算をやり直す
my $first_day   = localtime->strptime($now_date->strftime(   '%Y-%m-01'                             ),'%Y-%m-%d');
my $last_day    = localtime->strptime($now_date->strftime(   '%Y-%m-' . $now_date->month_last_day   ),'%Y-%m-%d');
my $next1m_date = localtime->strptime($now_date->strftime(   '%Y-%m-' . $now_date->month_last_day   ),'%Y-%m-%d') + 86400;
my $next2m_date = localtime->strptime($next1m_date->strftime('%Y-%m-' . $next1m_date->month_last_day),'%Y-%m-%d') + 86400;
my $next3m_date = localtime->strptime($next2m_date->strftime('%Y-%m-' . $next2m_date->month_last_day),'%Y-%m-%d') + 86400;
# 時刻(日付)取得、現在、1,2,3ヶ月後(ヘッダー用)
$self->stash(
    now_data    => $now_date,
    next1m_data => $next1m_date,
    next2m_data => $next2m_date,
    next3m_data => $next3m_date
);

# ナビ広告データ取得
my @adsNavi_rows = $teng->search_named(q{
select * from ads where kind=3 order by displaystart_on asc;
});
$self->stash(adsNavi_rows => \@adsNavi_rows);# テンプレートへ送り、

# 店舗登録フォームからの入力で管理者idを登録する
# 基本的なバリデートはjqueryでおこなっているので、
# すでに登録のあるメルアドなのかのバリデをsqlに接続して
# 行ってみる。
# バリデ実行後、新規入力、メール認証機能は後回しにして、
# データ新規登録、リダイレクト
# loadアイコンの切替
my $switch_load;
$self->stash(switch_load => $switch_load);

if (uc $self->req->method eq 'POST') {
    #新規入力も修正もボタン押すとpostで入ってくる、両方バリデード実行
    my $validator = $self->create_validator;
    $validator->field('mail_j')->required(1)->length(1,30)->callback(sub {
        my $login    = shift;
        # adminとgeneral両方チェックする
        my $select_usr = $self->param('select_usr');
        my $judg_login = 0;

        if ($select_usr eq "general") {
            my $general_ref  = $teng->single('general', +{login => $login});
            #my $login_name    ;
            $judg_login = ($general_ref) ? 1
                        :                  0
                        ;
        }
        elsif ($select_usr eq "admin") {
            my $admin_ref  = $teng->single('admin', +{login => $login});
            #my $login_name    ;
            $judg_login = ($admin_ref) ? 1
                        :                0
                        ;
        }


        return   ($judg_login == 1) ? (0, '既に使用されてます'  )
               :                       1
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
        my $login     = $self->param('mail_j');
        my $password  = "yoyakku";
        my $status    = 0;
        my $create_on = $today->datetime(date => '-', T => ' ');
        # admin書き込みか、generalか選別
        # 連続でprofileのデータもつくっておく(status未承認で)
        my $select_usr = $self->param('select_usr');
        if ($select_usr eq "general") {
            my $row = $teng->insert('general' => {
                'login'     => $login,
                'password'  => $password,
                'status'    => $status,
                'create_on' => $create_on,
            });
            #今作ったgeneralデータを呼び出し
            my $general_ref = $teng->single('general', +{login => $login});
            #profile用のデータつくる
            my $general_id  = $general_ref->id;
            my $nick_name   = $general_ref->login;
            my $mail        = $general_ref->login;
            my $row = $teng->insert('profile' => {
                'general_id'    => $general_id,
                #'admin_id'      => $admin_id,
                'nick_name'     => $nick_name,
                #'full_name'     => $full_name,
                #'phonetic_name' => $phonetic_name,
                #'tel'           => $tel,
                'mail'          => $mail,
                'status'        => $status,
                'create_on'     => $create_on,
            });

            #mailbox用のステータス
            my $mailbox_type_mail = 0;
            my $mailbox_status    = 0;
            #メール送信の為のデータを保存する=========
            my $row = $teng->insert('mailbox' => {
                #'id'                               =>,
                #'storeinfo_name'                   =>,
                #'storeinfo_post'                   =>,
                #'storeinfo_state'                  =>,
                #'storeinfo_cities'                 =>,
                #'storeinfo_addressbelow'           =>,
                #'storeinfo_tel'                    =>,
                #'storeinfo_mail'                   =>,
                #'storeinfo_url'                    =>,
                #'storeinfo_remarks'                =>,
                #'roominfo_name'                    =>,
                #'reserve_getstarted_on'            =>,
                #'reserve_enduse_on'                =>,
                #'reserve_useform'                  =>,
                #'roominfo_pricescomments'          =>,
                #'roominfo_remarks'                 =>,
                #'reserve_message'                  =>,
                #'admin_nick_name'                  =>,
                #'admin_full_name'                  =>,
                #'admin_tel'                        =>,
                #'admin_mail'                       =>,
                'general_nick_name'                => $nick_name,
                #'general_full_name'                =>,
                #'general_tel'                      =>,
                'general_mail'                     => $mail,
                #'before_roominfo_name'             =>,
                #'before_reserve_getstarted_on'     =>,
                #'before_reserve_enduse_on'         =>,
                #'before_reserve_useform'           =>,
                #'before_roominfo_pricescomments'   =>,
                #'before_roominfo_remarks'          =>,
                #'before_reserve_message'           =>,
                'type_mail'                        => $mailbox_type_mail,
                'status'                           => $mailbox_status,
                'create_on'                        => $create_on,
                #'modify_on'                        =>,
            });




            # 最後に登録完了メール送信
            # メッセージ作成
            #メール送信するため送信リストのテーブルを作る必要あり
            #送りたい
            # loadアイコン出現
            $switch_load = 1;
            $self->stash(switch_load => $switch_load);
#my $login_message = <<EOD;
#
#ログインＩＤ：$mail
#パスワード　：yoyakku
#EOD
#my $general_entry = $entry_message_1 . $login_message . $entry_message_2 . $footer_message;
#            my $utf8 = find_encoding('utf8');
#            # メール作成
#            my $subject = $utf8->encode('[yoyakku]ID登録完了のお知らせ');
#            my $body    = $utf8->encode($general_entry);
#
#            use Email::MIME;
#            my $email = Email::MIME->create(
#                header => [
#                    From    => 'yoyakku@gmail.com', # 送信元
#                    To      => $mail,    # 送信先
#                    Subject => $subject,           # 件名
#                ],
#                body => $body,                     # 本文
#                attributes => {
#                    content_type => 'text/plain',
#                    charset      => 'UTF-8',
#                    encoding     => '7bit',
#                },
#            );
#
#            # SMTP接続設定
#            #gmail
#            use Email::Sender::Transport::SMTP::TLS;
#            my $transport = Email::Sender::Transport::SMTP::TLS->new(
#                {
#                    host     => 'smtp.gmail.com',
#                    port     => 587,
#                    username => 'yoyakku@gmail.com',
#                    password => 'googleyoyakku',
#                }
#            );
#            # メール送信
#            use Try::Tiny;
#            use Email::Sender::Simple 'sendmail';
#            try {
#                sendmail($email, {'transport' => $transport});
#            } catch {
#                my $e = shift;
#                die "Error: $e";
#            };
        }
        elsif ($select_usr eq "admin") {
            my $row = $teng->insert('admin' => {
                'login'     => $login,
                'password'  => $password,
                'status'    => $status,
                'create_on' => $create_on,
            });
            #今作ったadminデータを呼び出し
            my $admin_ref = $teng->single('admin', +{login => $login});
            #profile用のデータつくる
            my $admin_id    = $admin_ref->id;
            my $nick_name   = $admin_ref->login;
            my $mail        = $admin_ref->login;
            my $row = $teng->insert('profile' => {
                #'general_id'    => $general_id,
                'admin_id'      => $admin_id,
                'nick_name'     => $nick_name,
                #'full_name'     => $full_name,
                #'phonetic_name' => $phonetic_name,
                #'tel'           => $tel,
                'mail'          => $mail,
                'status'        => $status,
                'create_on'     => $create_on,
            });

            #mailbox用のステータス
            my $mailbox_type_mail = 0;
            my $mailbox_status    = 0;
            #メール送信の為のデータを保存する=========
            my $row = $teng->insert('mailbox' => {
                #'id'                               =>,
                #'storeinfo_name'                   =>,
                #'storeinfo_post'                   =>,
                #'storeinfo_state'                  =>,
                #'storeinfo_cities'                 =>,
                #'storeinfo_addressbelow'           =>,
                #'storeinfo_tel'                    =>,
                #'storeinfo_mail'                   =>,
                #'storeinfo_url'                    =>,
                #'storeinfo_remarks'                =>,
                #'roominfo_name'                    =>,
                #'reserve_getstarted_on'            =>,
                #'reserve_enduse_on'                =>,
                #'reserve_useform'                  =>,
                #'roominfo_pricescomments'          =>,
                #'roominfo_remarks'                 =>,
                #'reserve_message'                  =>,
                'admin_nick_name'                  => $nick_name,
                #'admin_full_name'                  =>,
                #'admin_tel'                        =>,
                'admin_mail'                       => $mail,
                #'general_nick_name'                => $nick_name,
                #'general_full_name'                =>,
                #'general_tel'                      =>,
                #'general_mail'                     => $mail,
                #'before_roominfo_name'             =>,
                #'before_reserve_getstarted_on'     =>,
                #'before_reserve_enduse_on'         =>,
                #'before_reserve_useform'           =>,
                #'before_roominfo_pricescomments'   =>,
                #'before_roominfo_remarks'          =>,
                #'before_reserve_message'           =>,
                'type_mail'                        => $mailbox_type_mail,
                'status'                           => $mailbox_status,
                'create_on'                        => $create_on,
                #'modify_on'                        =>,
            });




            # 最後に登録完了メール送信
            # メッセージ作成
            # loadアイコン出現
            $switch_load = 1;
            $self->stash(switch_load => $switch_load);
#my $login_message = <<EOD;
#
#ログインＩＤ：$mail
#パスワード　：yoyakku
#EOD
#my $admin_entry = $entry_message_1 . $login_message . $entry_message_2 . $footer_message;
#            my $utf8 = find_encoding('utf8');
#            # メール作成
#            my $subject = $utf8->encode('[yoyakku]ID登録完了のお知らせ');
#            my $body    = $utf8->encode($admin_entry);
#
#            use Email::MIME;
#            my $email = Email::MIME->create(
#                header => [
#                    From    => 'yoyakku@gmail.com', # 送信元
#                    To      => $mail,    # 送信先
#                    Subject => $subject,           # 件名
#                ],
#                body => $body,                     # 本文
#                attributes => {
#                    content_type => 'text/plain',
#                    charset      => 'UTF-8',
#                    encoding     => '7bit',
#                },
#            );
#
#            # SMTP接続設定
#            #gmail
#            use Email::Sender::Transport::SMTP::TLS;
#            my $transport = Email::Sender::Transport::SMTP::TLS->new(
#                {
#                    host     => 'smtp.gmail.com',
#                    port     => 587,
#                    username => 'yoyakku@gmail.com',
#                    password => 'googleyoyakku',
#                }
#            );
#            # メール送信
#            use Try::Tiny;
#            use Email::Sender::Simple 'sendmail';
#            try {
#                sendmail($email, {'transport' => $transport});
#            } catch {
#                my $e = shift;
#                die "Error: $e";
#            };
        }
        # loadアイコン消える
        $switch_load = 0;
        $self->stash(switch_load => $switch_load);
        $self->flash(touroku => '登録完了');
        #sqlにデータ入力したのでlist画面にリダイレクト
        return $self->redirect_to('entry');
        #リターンなのでここでおしまい。

    }
    #入力検査合格しなかった場合、もう一度入力フォーム表示Fillinにて
    my $html = $self->render_partial()->to_string;
    $html = HTML::FillInForm->fill(\$html, $self->req->params,);
    return $self->render_text($html, format => 'html');
    #リターンなのでここでおしまい。

}

    $self->render('entry');
};
