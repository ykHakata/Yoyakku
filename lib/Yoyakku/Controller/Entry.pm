package Yoyakku::Controller::Entry;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Entry;

has( model_entry => sub { Yoyakku::Model::Entry->new(); } );

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Entry - 登録のコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Entry version 0.0.1

=head1 SYNOPSIS (概要)

    登録、関連機能のリクエストをコントロール

=cut

sub index {
    my $self  = shift;
    my $model = $self->model_entry;

    return $self->redirect_to('index')
        if ( uc $self->req->method ne 'GET' )
        && ( uc $self->req->method ne 'POST' );

    # ログイン中は回覧できない
    return $self->redirect_to('index')
        if $model->check_auth_db_yoyakku( $self->session );

    my $header_stash = $model->get_header_stash_entry();

    $self->stash($header_stash);
    $self->stash->{params} = $self->req->params->to_hash;

    my $path = $self->req->url->path->to_abs_string;

    return $self->entry() if $path eq '/entry';
    return $self->redirect_to('index');
}

=head2 entry

    登録画面

=cut

sub entry {
    my $self  = shift;
    my $model = $self->model_entry;

    my $switch_load;
    my $mail_j;
    my $get_ads_navi_rows = $model->get_ads_navi_rows();

    $self->stash(
        class        => 'entry',
        switch_load  => $switch_load,
        mail_j       => $mail_j,
        adsNavi_rows => $get_ads_navi_rows,
        template     => 'entry/entry',
        format       => 'html',
    );

    return $self->_insert() if uc $self->req->method eq 'POST';
    return $self->render();
}

sub _insert {
    my $self  = shift;
    my $model = $self->model_entry;

    $model->type('insert');
    $model->flash_msg( +{ touroku => '登録完了' } );

    return $self->_common();
}

sub _common {
    my $self  = shift;
    my $model = $self->model_entry;

    my $valid_msg
        = $model->check_validator( 'entry', $self->stash->{params} );

    return $self->stash($valid_msg), $self->_render_entry()
        if $valid_msg;

    my $valid_msg_db
        = $model->check_entry_validator_db( $self->stash->{params} );

    return $self->stash($valid_msg_db), $self->_render_entry()
        if $valid_msg_db;

    $model->writing_entry($self->stash->{params});
    $self->flash( $model->flash_msg() );

    $self->stash( $model->mail_temp() );

    my $mail_body = $self->render_to_string(
        template => 'mail/entry',
        format   => 'mail',
    )->to_string;

    $model->mail_body($mail_body);
    $model->send_gmail();

    return $self->redirect_to('entry');
}

sub _render_entry {
    my $self  = shift;
    my $model = $self->model_entry;

    my $html = $self->render_to_string(
        template => 'entry/entry',
        format   => 'html',
    )->to_string;

    my $args = +{
        html   => \$html,
        params => $self->stash->{params},
    };
    my $output = $model->set_fill_in_params($args);
    return $self->render( text => $output );
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Entry>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut


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
