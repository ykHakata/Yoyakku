package Yoyakku::Controller::Setting::Roominfo;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Setting::Roominfo;

has( model_setting_roominfo =>
        sub { Yoyakku::Model::Setting::Roominfo->new(); } );

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Setting::Roominfo - 店舗管理のコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Setting::Roominfo version 0.0.1

=head1 SYNOPSIS (概要)

    店舗管理、関連機能のリクエストをコントロール

=cut

sub index {
    my $self  = shift;
    my $model = $self->model_setting_roominfo;

    return $self->redirect_to('index')
        if ( uc $self->req->method ne 'GET' )
        && ( uc $self->req->method ne 'POST' );

    return $self->redirect_to('index')
        if !$model->check_auth_db_yoyakku( $self->session );

    $self->stash->{login_row} = $model->get_login_row( $self->session );

    my $redirect_mode
        = $model->get_redirect_mode( $self->stash->{login_row} );

    return $self->redirect_to('index')
        if $redirect_mode && $redirect_mode eq 'index';

    return $self->redirect_to('profile')
        if $redirect_mode && $redirect_mode eq 'profile';

    my $header_stash
        = $model->get_setting_header_stash( $self->stash->{login_row} );

    $self->stash($header_stash);
    $self->stash->{params} = $self->req->params->to_hash;

    my $path = $self->req->url->path->to_abs_string;

    return $self->admin_reserv_edit() if $path eq '/admin_reserv_edit';
    return $self->up_admin_r_d_edit() if $path eq '/up_admin_r_d_edit';
    return $self->redirect_to('index');
}

=head2 admin_reserv_edit

    予約部屋情報設定コントロール

=cut

sub admin_reserv_edit {
    my $self  = shift;
    my $model = $self->model_setting_roominfo;

    my $init_valid_params_admin_reserv_edit
        = $model->get_init_valid_params_admin_reserv_edit();

    my $switch_com = $model->get_switch_com('admin_reserv_edit');

    $self->stash(
        class      => 'admin_reserv_edit',
        switch_com => $switch_com,
        template   => 'setting/admin_reserv_edit',
        %{$init_valid_params_admin_reserv_edit},
    );

    if ( 'GET' eq uc $self->req->method ) {
        $self->stash->{params}
            = $model->set_roominfo_params( $self->stash->{login_row} );
        return $self->_render_fill_in_form();
    }
    return $self->_cancel() if $self->stash->{params}->{cancel};
    return $self->_update();
}

=head2 up_admin_r_d_edit

    予約部屋詳細設定コントロール

=cut

sub up_admin_r_d_edit {
    my $self  = shift;
    my $model = $self->model_setting_roominfo;

    my $get_init_valid_params_up_admin_r_d_edit
        = $model->get_init_valid_params_up_admin_r_d_edit();

    my $switch_com = $model->get_switch_com('up_admin_r_d_edit');

    $self->stash(
        class      => 'admin_reserv_edit',
        switch_com => $switch_com,
        template   => 'setting/up_admin_r_d_edit',
        %{$get_init_valid_params_up_admin_r_d_edit},
    );

    if ( 'GET' eq uc $self->req->method ) {
        $self->stash->{params}
            = $model->set_roominfo_params( $self->stash->{login_row} );
        return $self->_render_fill_in_form();
    }

    return;
}

sub _cancel {
    my $self = shift;
    $self->stash->{params} = undef;
    $self->stash->{params}->{id}
        = $self->stash->{login_row}->fetch_storeinfo->get_roominfo_ids;
    return $self->_render_fill_in_form();
}

sub _update {
    my $self  = shift;
    my $model = $self->model_setting_roominfo;

    $model->type('update');

    my $check_params
        = $model->get_check_params_list( $self->stash->{params} );

    for my $check_param ( @{$check_params} ) {
        my $valid_msg = $model->check_validator( 'roominfo', $check_param );
        return $self->stash($valid_msg), $self->_render_fill_in_form()
            if $valid_msg;
    }

    for my $check_param ( @{$check_params} ) {
        $model->writing_admin_reserv($check_param);
    }

    return $self->redirect_to('up_admin_r_d_edit');
}

sub _render_fill_in_form {
    my $self = shift;

    my $html = $self->render_to_string( format => 'html', )->to_string;

    my $args = +{
        html   => \$html,
        params => $self->stash->{params},
    };

    my $output = $self->model_setting_roominfo->set_fill_in_params($args);
    return $self->render( text => $output );
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Setting::Roominfo>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut

#up_admin_r_d_edit.html.ep
#予約部屋、詳細設定入力コントロール-----------------------------
any '/up_admin_r_d_edit' => sub {
my $self = shift;
# テンプレートbodyのクラス名を定義
my $class = "admin_reserv_edit";
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
       $login_id    = $admin_id;
    my $status = $admin_ref->status;
    if ($status) {
        my $storeinfo_ref = $teng->single('storeinfo', +{admin_id => $admin_id});
        if ($storeinfo_ref->status eq 0) {
            $switch_header = 10;
        }
        else {
            $switch_header = 7;
        }
    }
    else {
        #$switch_header = 8;
        return $self->redirect_to('profile');
    }
    #return $self->redirect_to('index');
}
elsif ($general_id) {
    #my $general_ref  = $teng->single('general', +{id => $general_id});
    #my $profile_ref  = $teng->single('profile', +{general_id => $general_id});
    #$login           = $profile_ref->nick_name;
    #
    #my $status = $general_ref->status;
    #if ($status) {
    #    $switch_header = 6;
    #}
    #else {
    #    #$switch_header = 8;
    #    return $self->redirect_to('profile');
    #}
    return $self->redirect_to('index');
}
else {
    #$switch_header = 5;
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

# 左naviのコメント切替の為の変数
my $switch_com = 4;
$self->stash(switch_com => $switch_com);
##----------
##ログインidからstoreinfoのテーブルより該当テーブル抽出
my @storeinfo = $teng->single('storeinfo', {'admin_id' => $login_id });
my $storeinfo_id;
# id検索、sql実行店舗id取得
for my $storeinfo (@storeinfo) {$storeinfo_id = $storeinfo->id ;}
#店舗idから部屋idを１０件取得(管理者承認が終わった時点でデータできてる)
my @rows = $teng->search('roominfo', {'storeinfo_id' => $storeinfo_id },{order_by => 'id'});
#sqlで該当roominfoをid若い順に取り出し、
my (@id,@storeinfo_id,@name,@starttime_on,@endingtime_on,@rentalunit,
    @pricescomments,@privatepermit,@privatepeople,@privateconditions,
    @bookinglimit,@cancellimit,@remarks,@webpublishing,@webreserve,@status,
    @create_on,@modify_on,);
        foreach my $row (@rows) {
            push (@id                , $row->id);
#            push (@storeinfo_id      , $row->storeinfo_id);
            push (@name              , $row->name);
#            push (@starttime_on      , $starttime_on);
#            push (@endingtime_on     , $endingtime_on);
#            push (@rentalunit        , $row->rentalunit);
#            push (@pricescomments    , $row->pricescomments);
#            push (@privatepermit     , $row->privatepermit);
#            push (@privatepeople     , $row->privatepeople);
#            push (@privateconditions , $row->privateconditions);
            push (@bookinglimit      , $row->bookinglimit);
            push (@cancellimit       , $row->cancellimit);
            push (@remarks           , $row->remarks);
#            push (@webpublishing     , $row->webpublishing);
#            push (@webreserve        , $row->webreserve);
#            push (@status            , $row->status);
#            push (@create_on         , $row->create_on);
#            push (@modify_on         , $row->modify_on);
        }
    #修正用フォーム、Fillinつかって表示 値はsqlより該当idのデータをつかう
    my $html = $self->render_partial()->to_string;
    $html = HTML::FillInForm->fill(
        \$html,{
            id                => \@id,
#            storeinfo_id      => \@storeinfo_id,
            name              => \@name,
#            starttime_on      => \@starttime_on,
#            endingtime_on     => \@endingtime_on,
#            rentalunit        => \@rentalunit,
#            pricescomments    => \@pricescomments,
#            privatepermit     => \@privatepermit,
#            privatepeople     => \@privatepeople,
#            privateconditions => \@privateconditions,
            bookinglimit      => \@bookinglimit,
            cancellimit       => \@cancellimit,
            remarks           => \@remarks,
#            webpublishing     => \@webpublishing,
#            webreserve        => \@webreserve,
#            status            => \@status,
#            create_on         => \@create_on,
#            modify_on         => \@modify_on
        },
    );
#    #Fillin画面表示実行returnなのでここでおしまい。
#    return $self->render_text($html, format => 'html');
#post判定する
# バリデート、sqlへ入力、次の画面遷移までの手順を考えてみる
# post判定,getの場合、fillinでrender
if (uc $self->req->method eq 'POST') {
    #submitボタン判定、キャンセルの時は空の値、完了の時バリデート
    my $cancel = $self->param('cancel');
    #キャンセルボタンの場合
    if ($cancel) {
        #リダイレクトで設定の最初の画面に戻す
        return $self->redirect_to('admin_reserv_edit');
    }
    #完了ボタンの場合バリデーション実行
    else {
    #完了の場合バリデート実行
    my $validator = $self->create_validator;# バリデーション()

    $validator->field('remarks'       )->required(1)->callback(sub {
        my $value = shift;
        my @id      = $self->param('id');
        my @remarks = $self->param('remarks');
        for my $id (@id) {
            my $judg_remarks = shift @remarks ;

            return (0, '100文字まで')
                if ( $judg_remarks =~ m/.{101,}?/xm );
        }
        return 1 ;
    });
    #mojoのコマンドでパラメーターをハッシュで取得入力した値をFIllin時に使うため、
    my $param_hash = $self->req->params->to_hash;
    $self->stash(param_hash => $param_hash);


    #入力検査合格、の時、修正アップロード実行
    if ( $self->validate($validator,$param_hash) ) {
        #入力値を全部受け取っておく念のために時刻取得
        my $today = localtime;
        # 入力フォームから受ける値変数
        my @id                = $self->param('id');
        #my @storeinfo_id      = $self->param('storeinfo_id');
        my @name              = $self->param('name');
#        my @starttime_on      = $self->param('starttime_on');
#        my @endingtime_on     = $self->param('endingtime_on');
#        my @rentalunit        = $self->param('rentalunit');
#        my @pricescomments    = $self->param('pricescomments');
#        my @privatepermit     = $self->param('privatepermit');
#        my @privatepeople     = $self->param('privatepeople');
#        my @privateconditions = $self->param('privateconditions');
        my @bookinglimit      = $self->param('bookinglimit');
        my @cancellimit       = $self->param('cancellimit');
        my @remarks           = $self->param('remarks');
#        my @webpublishing     = $self->param('webpublishing');
#        my @webreserve        = $self->param('webreserve');
#        my @status            = $self->param('status');
#        my @create_on         = $self->param('create_on');
        my @modify_on         = $today->datetime(date => '-', T => ' ');
        # 修正日付の配列をつくる
        my $modify_on = $today->datetime(date => '-', T => ' ');
        my @modify_on;
        for my $i (@id) {
            push (@modify_on,$modify_on);
        }
        my $name             ;
#        my $starttime_on     ;
#        my $endingtime_on    ;
#        my $rentalunit       ;
#        my $pricescomments   ;
#        my $privatepermit    ;
#        my $privatepeople    ;
#        my $privateconditions;
        my $bookinglimit     ;
        my $cancellimit      ;
        my $remarks          ;
        my $modify_on        ;
        # $idのあるだけ繰り返しsqlへアップデート
        foreach my $id (@id) {
            $name              = shift @name             ;
#            $starttime_on      = shift @starttime_on     ;
#            $endingtime_on     = shift @endingtime_on    ;
#            $rentalunit        = shift @rentalunit       ;
#            $pricescomments    = shift @pricescomments   ;
#            $privatepermit     = shift @privatepermit    ;
#            $privatepeople     = shift @privatepeople    ;
#            $privateconditions = shift @privateconditions;
            $bookinglimit      = shift @bookinglimit     ;
            $cancellimit       = shift @cancellimit      ;
            $remarks           = shift @remarks          ;
            $modify_on         = shift @modify_on        ;
            #name(部屋名)が存在するときだけ書き込みするように
            if ($name) {
                my $count = $teng->update( #修正データをsqlへ送り込み,status->1(利用開始)
                    'roominfo' => {
                        #'storeinfo_id'      => $storeinfo_id,
                        #'name'              => $name,
                        #'starttime_on'      => $starttime_on,
                        #'endingtime_on'     => $endingtime_on,
                        #'rentalunit'        => $rentalunit,
                        #'pricescomments'    => $pricescomments,
                        #'privatepermit'     => $privatepermit,
                        #'privatepeople'     => $privatepeople,
                        #'privateconditions' => $privateconditions,
                        'bookinglimit'      => $bookinglimit,
                        'cancellimit'       => $cancellimit,
                        'remarks'           => $remarks,
                        #'webpublishing'     => $webpublishing,
                        #'webreserve'        => $webreserve,
                        'status'            => 1,
                        #'create_on'         => $create_on,
                        'modify_on'         => $modify_on,
                    },{
                        'id' => $id,
                    }
                );
            }
            #name無いときはstatus->0(利用不可)にしておく
            else {
                my $count = $teng->update(
                    'roominfo' => {
                        #'storeinfo_id'      => $storeinfo_id,
                        #'name'              => $name,
                        #'starttime_on'      => $starttime_on,
                        #'endingtime_on'     => $endingtime_on,
                        #'rentalunit'        => $rentalunit,
                        #'pricescomments'    => $pricescomments,
                        #'privatepermit'     => $privatepermit,
                        #'privatepeople'     => $privatepeople,
                        #'privateconditions' => $privateconditions,
                        'bookinglimit'      => $bookinglimit,
                        'cancellimit'       => $cancellimit,
                        'remarks'           => $remarks,
                        #'webpublishing'     => $webpublishing,
                        #'webreserve'        => $webreserve,
                        'status'            => 0,
                        #'create_on'         => $create_on,
                        'modify_on'         => $modify_on,
                    },{
                        'id' => $id,
                    }
                );
            }
        }
        #sqlにデータ入力したのでリダイレクト
        return $self->redirect_to('admin_reserv_comp');
        #リターンなのでここでおしまい。
    }
    #入力検査合格しなかった場合、もう一度入力フォーム表示Fillinにて
    my $html = $self->render_partial()->to_string;
    $html = HTML::FillInForm->fill(\$html, $self->req->params,);
    return $self->render_text($html, format => 'html');
    #リターンなのでここでおしまい。
    }
}
#get入力、そのままfillinでrender
else {
    #Fillin画面表示実行returnなのでここでおしまい。
    return $self->render_text($html, format => 'html');
}

};
