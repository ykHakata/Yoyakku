package Yoyakku::Controller::Management::Reserve;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Util qw{chang_date_6};
use Mojo::Util qw{dumper};
use Yoyakku::Util::Time qw{
    tp_from_datetime_over24
    parse_datetime
};
use Time::Piece;
use Time::Seconds;

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Management::Reserve - 店舗管理のコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Management::Reserve version 0.0.1

=head1 SYNOPSIS (概要)

    店舗管理、関連機能のリクエストをコントロール

=cut

sub index {
    my $self  = shift;
    my $model = $self->model->management->roominfo;

    return $self->redirect_to('index')
        if ( uc $self->req->method ne 'GET' )
        && ( uc $self->req->method ne 'POST' );

    $self->stash->{login_row}
        = $self->model->auth->get_logged_in_row( $self->session );
    return $self->redirect_to('index') if !$self->stash->{login_row};

    my $redirect_mode
        = $model->get_redirect_mode( $self->stash->{login_row} );

    return $self->redirect_to('index')
        if $redirect_mode && $redirect_mode eq 'index';

    return $self->redirect_to('profile')
        if $redirect_mode && $redirect_mode eq 'profile';

    my $header_stash
        = $model->get_management_header_stash( $self->stash->{login_row} );

    $self->stash($header_stash);
    $self->stash->{params} = $self->req->params->to_hash;

    my $path = $self->req->url->path->to_abs_string;

    return $self->admin_reserv_list() if $path eq '/admin_reserv_list';
    return $self->redirect_to('index');
}

=head2 up_admin_r_u_c_comp

    予約キャンセル完了画面

=cut

sub up_admin_r_u_c_comp {
    my $self = shift;
    $self->stash(
        class    => 'up_admin_r_u_c_comp',
        template => 'management/up_admin_r_u_c_comp',
        format   => 'html',
    );
    $self->render;
    return;
}

=head2 admin_reserv_list

    予約部屋情報設定コントロール

=cut

sub admin_reserv_list {
    my $self = shift;

    my $reserve = $self->model->management->reserve;

    # 入力フォーム切替用値取得
    my $cond_input_form = $reserve->cond_input_form( $self->stash->{params} );

    $self->stash(
        class        => 'admin_reserv_list',
        template     => 'management/admin_reserv_list',
        format       => 'html',
        cancel_conf  => $cond_input_form->{cancel_conf},
        switch_input => $cond_input_form->{switch_input},
    );

    # 管理者予約履歴 のための値
    my $reserve_history
        = $reserve->get_reserve_history( $self->stash->{login_row} );
    $self->stash(
        admin_now_reserves_ref   => $reserve_history->{now}->{reserve},
        year_reserve             => $reserve_history->{now}->{year},
        mon_reserve              => $reserve_history->{now}->{mon},
        admin_next1_reserves_ref => $reserve_history->{next1}->{reserve},
        next1_year_reserve       => $reserve_history->{next1}->{year},
        next1_mon_reserve        => $reserve_history->{next1}->{mon},
        admin_next2_reserves_ref => $reserve_history->{next2}->{reserve},
        next2_year_reserve       => $reserve_history->{next2}->{year},
        next2_mon_reserve        => $reserve_history->{next2}->{mon},
        admin_next3_reserves_ref => $reserve_history->{next3}->{reserve},
        next3_year_reserve       => $reserve_history->{next3}->{year},
        next3_mon_reserve        => $reserve_history->{next3}->{mon},
    );

    # カレンダーナビゲーション用の値
    my $params = $self->model->region->get_cal_params( $self->stash->{params} );

    # カレンダーナビにstoreidを埋め込む為の切替 (calnavi 0 の場合 store_id 不要)
    my $switch_calnavi = 0;
    my $store_id;

    $self->stash(
        switch_calnavi  => $switch_calnavi,
        store_id        => $store_id,
        border_date_day => $params->{border_date_day},
        select_date_ym  => $params->{select_date_ym},
        select_date_day => $params->{select_date_day},
        cal             => $params->{cal},
        caps            => $self->model->region->get_calender_caps(),
        back_mon_val    => $params->{back_mon_val},
        next_mon_val    => $params->{next_mon_val},
    );

    # 表示を切り替えるスイッチ
    my $switch_res_navi = 1;
    my $storeinfo_row   = $self->stash->{login_row}->fetch_storeinfo;
    my $storeinfo_name  = $storeinfo_row->name;

    # 予約情報取り出しの暫定コードで利用
    my $storeinfo_id = $storeinfo_row->id;

    my $roominfo_rows
        = $self->stash->{login_row}->fetch_storeinfo->fetch_roominfos;
    my $roominfo_ids   = [ map { $_->id } @{$roominfo_rows} ];
    my $roominfo_names = [ map { $_->name } @{$roominfo_rows} ];

    my $select_date = $params->{select_date_obj};

    # 利用停止になっている部屋を特定
    my $outside_room
        = $reserve->get_outside_room( $self->stash->{login_row} );

    # 現在時刻が予約の時間枠をすぎた場合予約不可 (本日の場合のみ)
    my $timeout_room
        = $reserve->get_timeout_room( $self->stash->{login_row},
        $select_date );

    # 営業時間外を特定
    my $close_store
        = $reserve->get_close_store( $self->stash->{login_row} );

    # 予約テーブル部屋一覧
    $self->stash(
        select_date_res => $params->{select_date},
        switch_res_navi => $switch_res_navi,
        storeinfo_name  => $storeinfo_name,
        id_ref          => $roominfo_ids,
        name_ref        => $roominfo_names,
        outside_ref     => $outside_room,
        timeout_ref     => $timeout_room,
        close_store_ref => $close_store,
    );

    # 予約情報取得
    my $get_select_res
        = $reserve->get_select_res( $select_date, $self->stash->{login_row} );

    $self->stash(
        select_res_ref        => $get_select_res->{select_res},
        select_detail_res_ref => $get_select_res->{select_detail_res},
    );

    # このへんの post, get での挙動の違いがわかりにく
    if ($self->req->method eq 'POST') {

        # 戻るボタンを押した時の挙動
        return $self->_turn_back if $self->stash->{params}->{back};

        # 予約取消ボタンが押されたときの挙動
        return $self->_cansel_reserve if $self->stash->{params}->{exe_cansel};
    }

    # 予約済みの所をクリックすると詳細がでるスクリプト
    return $self->_detail_reserve( $self->param('reserve_id') )
        if $self->param('reserve_id');

    # 新規予約をクリックすると必要な情報を表示するスクリプト
    return $self->_create_reserve( $self->param('new_res_room_id'),
        $select_date )
        if $self->param('new_res_room_id');

    $self->render;
    return;
}

# 予約済みの所をクリックすると詳細がでるスクリプト
sub _detail_reserve {
    my $self       = shift;
    my $reserve_id = shift;

    # 指定された予約情報取得
    my $teng = $self->model->db->base->teng;
    my $reserve_row = $teng->single( 'reserve', +{ id => $reserve_id } );

    # 開始時間切替情報
    $self->stash->{room_time_change}
        = $reserve_row->fetch_roominfo->time_change;

    # 予約者の情報を取得
    my $subscriber;
    if ( $reserve_row->general_id ) {
        $subscriber = $reserve_row->fetch_profile_general->nick_name;
    }
    else {
        $subscriber = $reserve_row->fetch_profile_admin->nick_name;
    }

    # 予約日付の整形
    my $tp
        = tp_from_datetime_over24( $reserve_row->getstarted_on, '06:00:00' );
    my $getstarted_parse = parse_datetime( $tp->over24_datetime );

    $tp = tp_from_datetime_over24( $reserve_row->enduse_on, '06:00:01' );
    my $enduse_parse = parse_datetime( $tp->over24_datetime );

    my $stash_params = +{
        id                 => $reserve_row->id,
        roominfo_id        => $reserve_row->roominfo_id,
        room_name          => $reserve_row->fetch_roominfo->name,
        getstarted_on_day  => $getstarted_parse->{date},
        getstarted_on_time => $getstarted_parse->{hour} + 0,
        enduse_on_day      => $enduse_parse->{date},
        enduse_on_time     => $enduse_parse->{hour} + 0,
        useform            => $reserve_row->useform,
        message            => $reserve_row->message,
        subscriber         => $subscriber,
        tel                => $reserve_row->tel,
    };
    $self->_render_reserve($stash_params);
    return;
}

# 新規予約をクリックすると必要な情報を表示するスクリプト (入力フォーム)
sub _create_reserve {
    my $self        = shift;
    my $roominfo_id = shift;
    my $select_date = shift;

    my $login_row     = $self->stash->{login_row};
    my $storeinfo_row = $login_row->fetch_storeinfo;

    # 予約代行のためのリスト抽出
    my $acting_rows = $storeinfo_row->fetch_actings;
    $self->stash->{actings_ref}
        = [ map { $_->fetch_profile } @{$acting_rows} ];

    # 開始時間切替情報
    $self->stash->{room_time_change}
        = $storeinfo_row->fetch_roominfo_select_id($roominfo_id)->time_change;

    # 予約開始日付を出力するスクリプト
    my $select_time = $self->param('select_time');

    my $stash_params = +{
        roominfo_id => $roominfo_id,
        room_name =>
            $storeinfo_row->fetch_roominfo_select_id($roominfo_id)->name,
        getstarted_on_day  => $select_date->date,
        getstarted_on_time => $select_time,
        enduse_on_day      => $select_date->date,
        enduse_on_time     => $select_time + 1,
        subscriber         => $login_row->fetch_profile->nick_name,
        tel                => $storeinfo_row->tel,
    };
    $self->_render_reserve($stash_params);
    return;
}

sub _render_reserve {
    my $self   = shift;
    my $params = shift;
    my $html   = $self->render_to_string->to_string;
    my $args   = +{
        html   => \$html,
        params => $params,
    };
    my $output = $self->model->management->reserve->set_fill_in_params($args);
    return $self->render( text => $output );
}

# 戻るボタンを押した時の挙動
sub _turn_back {
    my $self = shift;
    return $self->redirect_to('admin_reserv_list');
}

# 予約取消ボタンが押されたときの挙動
sub _cansel_reserve {
    my $self = shift;

    # キャンセルする予約 id
    my $reserve_id  = $self->param('id');
    my $teng        = $self->model->db->base->teng;
    my $reserve_row = $teng->single( 'reserve', +{ id => $reserve_id } );

    $reserve_row->soft_delete;

    # 削除完了メールの為のパラメーターを作成
    $reserve_row = $teng->single( 'reserve', +{ id => $reserve_id } );
    my $roominfo_row      = $reserve_row->fetch_roominfo;
    my $storeinfo_row     = $roominfo_row->fetch_storeinfo;
    my $profile_admin_row = $reserve_row->fetch_profile_admin;

    # useform を変換
    my $useform
        = ( $reserve_row->useform eq '0' ) ? 'バンド'
        : ( $reserve_row->useform eq '1' ) ? '個人'
        : ( $reserve_row->useform eq '2' ) ? '利用停止'
        :                                    '該当なし';

    # 一般ユーザーが紐づいていない予約もある
    my $fetch_profile_ref = +{};
    if ($reserve_row->general_id) {
        $fetch_profile_ref = $reserve_row->fetch_profile_general->get_columns;
    }

    my $mail_params = +{
        storeinfo_name          => $storeinfo_row->name,
        storeinfo_post          => $storeinfo_row->post,
        storeinfo_state         => $storeinfo_row->state,
        storeinfo_cities        => $storeinfo_row->cities,
        storeinfo_addressbelow  => $storeinfo_row->addressbelow,
        storeinfo_tel           => $storeinfo_row->tel,
        storeinfo_mail          => $storeinfo_row->mail,
        storeinfo_url           => $storeinfo_row->url,
        storeinfo_remarks       => $storeinfo_row->remarks,
        roominfo_name           => $roominfo_row->name,
        reserve_getstarted_on   => $reserve_row->getstarted_on,
        reserve_enduse_on       => $reserve_row->enduse_on,
        reserve_useform         => $useform,
        roominfo_pricescomments => $roominfo_row->pricescomments,
        roominfo_remarks        => $roominfo_row->remarks,
        reserve_message         => $reserve_row->message,
        admin_nick_name         => $profile_admin_row->nick_name,
        admin_full_name         => $profile_admin_row->full_name,
        admin_tel               => $profile_admin_row->tel,
        admin_mail              => $profile_admin_row->mail,
        general_nick_name       => $fetch_profile_ref->{nick_name} || '',
        general_full_name       => $fetch_profile_ref->{full_name} || '',
        general_tel             => $fetch_profile_ref->{tel} || '',
        general_mail            => $fetch_profile_ref->{mail} || '',
    };

    # -----

    # 予約キャンセルメール作成の一連の挙動

    # キャンセル完了画面表示
    return $self->redirect_to('up_admin_r_u_c_comp');
}

# post リスエスト時の挙動
sub _admin_reserv_list_post {
    my $self = shift;

    # ================================================

    # # 予約取消ボタンが押されたときのスクリプト

    #     #mailbox用のステータス
    #     my $mailbox_type_mail = 4;
    #     my $mailbox_status    = 0;

    #     #メール送信の為のデータを保存する=========
    #     my $row = $teng->insert(
    #         'mailbox' => {

    #             #'id'                               =>,
    #             'storeinfo_name'          => $storeinfo_name,
    #             'storeinfo_post'          => $post,
    #             'storeinfo_state'         => $state,
    #             'storeinfo_cities'        => $cities,
    #             'storeinfo_addressbelow'  => $addressbelow,
    #             'storeinfo_tel'           => $storeinfo_tel,
    #             'storeinfo_mail'          => $storeinfo_mail,
    #             'storeinfo_url'           => $url,
    #             'storeinfo_remarks'       => $remarks,
    #             'roominfo_name'           => $name,
    #             'reserve_getstarted_on'   => $getstarted_on,
    #             'reserve_enduse_on'       => $enduse_on,
    #             'reserve_useform'         => $useform,
    #             'roominfo_pricescomments' => $pricescomments,
    #             'roominfo_remarks'        => $roominfo_remarks,
    #             'reserve_message'         => $message,
    #             'admin_nick_name'         => $admin_nick_name,
    #             'admin_full_name'         => $admin_full_name,
    #             'admin_tel'               => $admin_tel,
    #             'admin_mail'              => $admin_mail,
    #             'general_nick_name'       => $general_nick_name,
    #             'general_full_name'       => $general_full_name,
    #             'general_tel'             => $general_tel,
    #             'general_mail'            => $general_mail,

    #             #'before_roominfo_name'             =>,
    #             #'before_reserve_getstarted_on'     =>,
    #             #'before_reserve_enduse_on'         =>,
    #             #'before_reserve_useform'           =>,
    #             #'before_roominfo_pricescomments'   =>,
    #             #'before_roominfo_remarks'          =>,
    #             #'before_reserve_message'           =>,
    #             'type_mail' => $mailbox_type_mail,
    #             'status'    => $mailbox_status,
    #             'create_on' => $create_on,

    #             #'modify_on'                        =>,
    #         }
    #     );

    #     #my $cansel_subject  = '[yoyakku]管理者予約キャンセルのお知らせ【'.$today->datetime(date => '-', T => ' ').'】';
    #     #my $cancel_messages = <<EOD;
    #     #管理者　$admin_nick_name　様
    #     #
    #     #一般ユーザー　$general_nick_name　様
    #     #
    #     #この度は、yoyakkuをご利用頂き、誠にありがとうございます。
    #     #
    #     #管理者により予約のキャンセルが行われました。
    #     #
    #     #キャンセル内容は下記の通りとなります
    #     #
    #     #ご予約店舗情報----------
    #     #【店舗名】$storeinfo_name
    #     #【住所】　$post
    #     #　　　　　$state $cities
    #     #　　　　　$addressbelow
    #     #【電話】　$storeinfo_tel
    #     #【メール】$storeinfo_mail
    #     #【ＵＲＬ】$url
    #     #【備考】　$remarks
    #     #
    #     #ご予約内容----------
    #     #【部屋】$name
    #     #【開始】$getstarted_on
    #     #【終了】$enduse_on
    #     #【利用】$useform
    #     #【料金】$pricescomments
    #     #【伝言】$message
    #     #
    #     #予約者情報【管理者】----------
    #     #【予約名】$admin_nick_name
    #     #【氏名】$admin_full_name
    #     #【電話】$admin_tel
    #     #【メール】$admin_mail
    #     #
    #     #予約者情報【一般ユーザー】----------
    #     #【予約名】$general_nick_name
    #     #【氏名】$general_full_name
    #     #【電話】$general_tel
    #     #【メール】$general_mail
    #     #
    #     #
    #     #この内容をキャンセルいたしました。
    #     #
    #     #EOD
    #     #            my $utf8 = find_encoding('utf8');
    #     #            # メール作成
    #     #            my $subject = $utf8->encode($cansel_subject);
    #     #            my $body    = $utf8->encode($cancel_messages . $footer_message);
    #     #
    #     #            use Email::MIME;
    #     #            my $email = Email::MIME->create(
    #     #                header => [
    #     #                    From    => 'yoyakku@gmail.com', # 送信元
    #     #                    To      => $storeinfo_mail,    # 送信先
    #     #                    To      => $general_mail,    # 送信先
    #     #                    Subject => $subject,           # 件名
    #     #                ],
    #     #                body => $body,                     # 本文
    #     #                attributes => {
    #     #                    content_type => 'text/plain',
    #     #                    charset      => 'UTF-8',
    #     #                    encoding     => '7bit',
    #     #                },
    #     #            );
    #     #
    #     #            # SMTP接続設定
    #     #            #gmail
    #     #            use Email::Sender::Transport::SMTP::TLS;
    #     #            my $transport = Email::Sender::Transport::SMTP::TLS->new(
    #     #                {
    #     #                    host     => 'smtp.gmail.com',
    #     #                    port     => 587,
    #     #                    username => 'yoyakku@gmail.com',
    #     #                    password => 'googleyoyakku',
    #     #                }
    #     #            );
    #     #            # メール送信
    #     #            use Try::Tiny;
    #     #            use Email::Sender::Simple 'sendmail';
    #     #            try {
    #     #                sendmail($email, {'transport' => $transport});
    #     #            } catch {
    #     #                my $e = shift;
    #     #                die "Error: $e";
    #     #            };
    #     # リダイレクト画面遷移、予約削除しました。
    #     return $self->redirect_to('up_admin_r_u_c_comp');
    # }

    #}

    # # 保存ボタンが押された時のスクリプト
    # my $save     = $self->param('save');
    # my $h_botton = $self->param('h_botton');
    # if ( $save or $h_botton ) {

    #     #新規入力も修正もボタン押すとpostで入ってくる、両方バリデード実行
    #     # バリデーション()
    #     my $validator = $self->create_validator;

    #     #バリデーションが複雑になってきたのでもう一度順番に整理する
    #     #予約のダブり確認のバリデ
    #     $validator->field('id')->callback(
    #         sub {
    #             my $value = shift;

    #             my $judg_reserve_id = 0;    #予約既にあり
    #             my $judg_reserve_id = 1;    #問題なし

    #             # 予約のダブりが存在を確認するスクリプトをもう一度考えてみる
    #             #入力した値を取得する=======================================================
    #             # 入力した値を取得する(予約id,部屋情報id,利用開始時刻,利用終了時刻)
    #             my $id          = $self->param('id');
    #             my $roominfo_id = $self->param('roominfo_id');

    #             #入力した予約の希望日付
    #             my $kibou_date    = $self->param('getstarted_on_day');
    #             my $kibou_start   = $self->param('getstarted_on_time');
    #             my $enduse_on_day = $self->param('enduse_on_day');
    #             my $kibou_end     = $self->param('enduse_on_time');

    #             # 一発hボタンを押した時のスクリプト
    #             $kibou_end =
    #                 ( $h_botton eq "1h" ) ? $kibou_start + 1
    #               : ( $h_botton eq "2h" ) ? $kibou_start + 2
    #               : ( $h_botton eq "3h" ) ? $kibou_start + 3
    #               : ( $h_botton eq "4h" ) ? $kibou_start + 4
    #               : ( $h_botton eq "5h" ) ? $kibou_start + 5
    #               :                         $kibou_end;

    #             #既に入力済みのデータをsqlから取り出す========================================
    #             # 予約履歴を抽出する
    #             my @reserves = $teng->search_named(q{select * from reserve;});

    #             #比較したいデータのみを選別する===============================================
    #             # 比較したいデータとは、入力した部屋id(roominfo_id)と同じもの
    #             # 入力した予約id(id)は比較対象外にする
    #             # ステータスが1(キャンセル)は比較対象外
    #             # 予約データを一件づつすべて引き出す
    #             foreach my $reserve_ref (@reserves) {

    #                 #入力したroominfo_idと同じデータのみ
    #                 if ( $reserve_ref->roominfo_id == $roominfo_id ) {

    #                     #入力した予約id以外のもの
    #                     if ( $reserve_ref->id ne $id ) {
    #                         if ( $reserve_ref->status ne 1 ) {

    #                             #比較できるよう値を変換
    #                             #データの利用開始と利用終了のデータを取り出し
    #                             #利用開始日時取り出し
    #                             my $getstarted_on = $reserve_ref->getstarted_on;

    #                             #日付と時刻に分ける(ただしまだ通常の0-5時の形式)
    #                             #日付
    #                             my $getstarted_on_day = substr( $getstarted_on, 0, 10 );

    #                             #時刻
    #                             my $getstarted_on_time = substr( $getstarted_on, 11, 2 );

    #                             #念のために時刻を数字の型にして、最初の0があれば表示しない
    #                             #時刻0-5時の場合は24-29に変換、
    #                             $getstarted_on_time += 0;
    #                             if ( $getstarted_on_time =~ /^[0-5]$/ ) {
    #                                 $getstarted_on_time += 24;

    #                                 #日付を1日もどる
    #                                 $getstarted_on_day = localtime->strptime( $getstarted_on_day, '%Y-%m-%d' );
    #                                 $getstarted_on_day = $getstarted_on_day - ONE_DAY * 1;
    #                                 $getstarted_on_day = $getstarted_on_day->date;
    #                             }

    #                             #利用終了日時取り出し
    #                             my $enduse_on = $reserve_ref->enduse_on;

    #                             #日付と時刻に分ける(ただしまだ通常の0-6時の形式)
    #                             #日付
    #                             my $enduse_on_day = substr( $enduse_on, 0, 10 );

    #                             #時刻
    #                             my $enduse_on_time = substr( $enduse_on, 11, 2 );

    #                             #念のために時刻を数字の型にして、最初の0があれば表示しない
    #                             #時刻0-6時の場合は24-30に変換、
    #                             $enduse_on_time += 0;
    #                             if ( $enduse_on_time =~ /^[0-6]$/ ) {
    #                                 $enduse_on_time += 24;

    #                                 #日付を1日もどる
    #                                 $enduse_on_day = localtime->strptime( $enduse_on_day, '%Y-%m-%d' );
    #                                 $enduse_on_day = $enduse_on_day - ONE_DAY * 1;
    #                                 $enduse_on_day = $enduse_on_day->date;
    #                             }

    #                             #開始時刻から終了時刻一つ前まで、比較してゆく、一致すればdie!ダブり！
    #                             #入力した日付とデータの日付が一致した時比較開始
    #                             if ( $getstarted_on_day eq $kibou_date ) {

    #                                 #今見ているデータの時間軸をだす
    #                                 #比較の計算式を書き直し
    #                                 my $i = $getstarted_on_time;
    #                                 for ( $i ; $i < $enduse_on_time ; ++$i ) {

    #                                     #sqlのデータ
    #                                     #開始から終了一つ前まで１つづつ取り出し
    #                                     my $ii = $kibou_start;

    #                                     #入力データ
    #                                     for ( $ii ; $ii < $kibou_end ; ++$ii ) {
    #                                         if ( $i == $ii ) {
    #                                             $judg_reserve_id = 0;
    #                                         }
    #                                     }
    #                                 }
    #                             }
    #                         }
    #                     }
    #                 }
    #             }

    #             #おしまし
    #             return 1 if $judg_reserve_id;

    #             return ( 0, '既に予約が存在します' );
    #         }
    #     );

    #     # 利用開始日時 getstarted_on->日付と時間
    #     #日付の書式のバリデ
    #     $validator->field('getstarted_on_day')->required(1)->constraint( 'date', split => '-' );

    #     # 抽出した部屋情報の開始時刻より遅く、終了時間より早い事(今の時刻より過去でないこと)
    #     $validator->field('getstarted_on_time')->callback(
    #         sub {
    #             my $value = shift;

    #             #指定の時刻(日)が過去の場合は予約(変更)できない
    #             # データを日付データに変換して比較する

    #             # 入力された日付(時刻)入手
    #             my $select_getstarted_day  = $self->param('getstarted_on_day');
    #             my $select_getstarted_time = $value;

    #             # 今の日付(時刻)入手
    #             my $now_datetime = localtime;

    #             #比較できるように変換
    #             # 今の日付時刻の文字列
    #             my $now_datetime_ymd  = $now_datetime->date;
    #             my $now_datetime_hour = $now_datetime->hour;

    #             # 今の時刻が0-5の場合時刻を24-29にして、日付を一日もどす
    #             if ( $now_datetime_hour =~ m/^[0-5]$/ ) {
    #                 $now_datetime_ymd = $now_datetime - ONE_DAY * 1;
    #                 $now_datetime_ymd = $now_datetime_ymd->date;
    #                 $now_datetime_hour += 24;
    #             }

    #             #今日の予約テーブル時間軸だけを比較
    #             if ( $now_datetime_ymd eq $select_getstarted_day ) {
    #                 if ( $select_getstarted_time <= $now_datetime_hour ) {
    #                     return ( 0, '過ぎた時間です' );
    #                 }
    #             }

    #             # 部屋の利用開始と終了時刻の範囲内かを調べるバリデ
    #             # 指定したスタジオ、部屋情報idを取得
    #             my $roominfo_id = $self->param('roominfo_id');

    #             # 該当する部屋の開始時刻と終了時刻を取得
    #             my $starttime_on;
    #             my @roominfos = $teng->search_named(q{select * from roominfo;});
    #             foreach my $roominfo_ref (@roominfos) {
    #                 if ( $roominfo_ref->id == $roominfo_id ) {

    #                     #開始時刻取得
    #                     $starttime_on = $roominfo_ref->starttime_on;
    #                 }
    #             }

    #             #比較するため24-29の数字に変換
    #             if ($starttime_on) {
    #                 $starttime_on = substr( $starttime_on, 0, 2 );
    #                 $starttime_on += 0;
    #                 if ( $starttime_on =~ /^[0-5]$/ ) {
    #                     $starttime_on += 24;
    #                 }
    #             }

    #             return 1 if $starttime_on <= $value;

    #             return ( 0, '営業時間外です' );
    #         }
    #     );

    #     # 利用終了日時 enduse_on->日付と時間
    #     # 日付の書式バリデ、開始、終了同じ日付にさせる
    #     $validator->field('enduse_on_day')->required(1)->constraint( 'date', split => '-' )->callback(
    #         sub {
    #             my $value             = shift;
    #             my $getstarted_on_day = $self->param('getstarted_on_day');

    #             return 1 if $getstarted_on_day eq $value;

    #             return ( 0, '開始と同じ日付にして下さい' );
    #         }
    #     );

    #     $validator->field('enduse_on_time')->callback(
    #         sub {
    #             #開始より終了が早い場合
    #             my $value              = shift;
    #             my $getstarted_on_time = $self->param('getstarted_on_time');

    #             # 一発hボタンを押した時のスクリプト
    #             $value =
    #                 ( $h_botton eq "1h" ) ? $getstarted_on_time + 1
    #               : ( $h_botton eq "2h" ) ? $getstarted_on_time + 2
    #               : ( $h_botton eq "3h" ) ? $getstarted_on_time + 3
    #               : ( $h_botton eq "4h" ) ? $getstarted_on_time + 4
    #               : ( $h_botton eq "5h" ) ? $getstarted_on_time + 5
    #               :                         $value;
    #             my @roominfos = $teng->search_named(q{select * from roominfo;});

    #             # 指定したスタジオ、部屋情報idを取得
    #             my $roominfo_id = $self->param('roominfo_id');

    #             # 該当する部屋の終了時刻を取得
    #             my $endingtime_on;

    #             # 該当する部屋の貸出単位を取得
    #             my $rentalunit;
    #             foreach my $roominfo_ref (@roominfos) {
    #                 if ( $roominfo_ref->id == $roominfo_id ) {

    #                     #終了時刻取得
    #                     $endingtime_on = $roominfo_ref->endingtime_on;

    #                     #貸出単位
    #                     $rentalunit = $roominfo_ref->rentalunit;
    #                 }
    #             }

    #             #貸出単位設定で2時間指定されたときの、バリデのためrentalunitも取得
    #             # 1が１時間、2が２時間、２が選択されているときだけバリデ
    #             #判定の変数
    #             my $judg_rentalunit;
    #             if ( $rentalunit == 2 ) {
    #                 my $val = $value - $getstarted_on_time;

    #                 #偶数
    #                 if ( $val % 2 == 0 ) {

    #                     #問題なし
    #                     $judg_rentalunit = 0;
    #                 }
    #                 else {
    #                     #奇数、バリデートコメントへ
    #                     $judg_rentalunit = 1;
    #                 }
    #             }

    #             #比較するため24-29の数字に変換
    #             if ($endingtime_on) {
    #                 $endingtime_on = substr( $endingtime_on, 0, 2 );
    #                 $endingtime_on += 0;
    #                 if ( $endingtime_on =~ /^[0-6]$/ ) {
    #                     $endingtime_on += 24;
    #                 }
    #             }
    #             my $roominfo_ref = $teng->single( 'roominfo', { 'id' => $roominfo_id } );
    #             my $room_time_change = $roominfo_ref->time_change;

    #             # テンプレートへ送り、
    #             $self->stash( room_time_change => $room_time_change );

    #             # 翻訳すると、judg_renが１の場合エラー
    #             # 入力の開始時間が入力の終了の時間より同じもしくは大きい場合
    #             # 営業終了時間が入力終了時間より大きい場合、実行
    #             # いずれにも該当しない場合、営業時間外
    #             return
    #                 $judg_rentalunit              ? ( 0, '2時間単位でしか予約できません' )
    #               : $getstarted_on_time >= $value ? ( 0, '開始時刻より遅くして下さい' )
    #               : $endingtime_on >= $value      ? 1
    #               :                                 ( 0, '営業時間外です' );
    #         }
    #     );

    #     # 利用形態名 useform->バンド、個人練習、利用停止、いずれも許可が必要
    #     $validator->field('useform')->callback(
    #         sub {
    #             my $useform = shift;

    #             #判定の変数定義
    #             my $judg_privatepermit;
    #             my $judg_privateconditions;
    #             my $judg_general_id;

    #             # useformのバリデート最初にはいってくる値ごとにifで分ける
    #             # 0バンドの場合、1個人の場合、2利用停止、の場合
    #             if ( $useform == 1 ) {

    #                 #============================
    #                 # 必要な情報をそろえる
    #                 #入力している部屋情報id->roominfo->idを取得する
    #                 my $roominfo_id = $self->param('roominfo_id');
    #                 my @roominfos   = $teng->search_named(q{select * from roominfo;});

    #                 # 個人練習許可設定
    #                 my $privatepermit;

    #                 # 個人練習許可条件
    #                 my $privateconditions;
    #                 foreach my $roominfo_ref (@roominfos) {
    #                     if ( $roominfo_ref->id == $roominfo_id ) {
    #                         $privatepermit     = $roominfo_ref->privatepermit;
    #                         $privateconditions = $roominfo_ref->privateconditions;
    #                     }
    #                 }

    #                 #============================
    #                 #個人練習許可が出てない部屋で個人練習->1選択できない
    #                 #$privatepermit ->0 #許可する #$privatepermit ->1 #許可しない
    #                 #利用出来る
    #                 $judg_privatepermit = 0;

    #                 #$judg_privatepermit = 1;#利用出来ない
    #                 # 判定
    #                 if ($privatepermit) { $judg_privatepermit = 1; }

    #                 #============================
    #                 #個人練習許可条件に一致してない場合、選択できない
    #                 #利用できる
    #                 $judg_privateconditions = 0;

    #                 #入力している希望日時を取得する、
    #                 my $getstarted_on_day = $self->param('getstarted_on_day');

    #                 #今の日付と比較して何日前か計算して出力
    #                 #入力しているデータを日付のデータに変換
    #                 $getstarted_on_day = localtime->strptime( $getstarted_on_day, '%Y-%m-%d' );
    #                 my $today = localtime;

    #                 #日付を切り出し
    #                 my $input_date_day = $today->date;

    #                 #時間を切り出し
    #                 my $input_date_time = $today->time;
    #                 $input_date_time = substr( $input_date_time, 0, 2 );
    #                 $input_date_time += 0;
    #                 if ( $input_date_time =~ /^[0-5]$/ ) {
    #                     $input_date_time += 24;

    #                     #日付を1日もどる
    #                     $input_date_day = localtime->strptime( $input_date_day, '%Y-%m-%d' );
    #                     $input_date_day = $input_date_day - ONE_DAY * 1;
    #                     $input_date_day = $input_date_day->date;
    #                 }
    #                 my $input_date = $input_date_day;

    #                 # 予約指定日を７日さかのぼった数字(日付データ)
    #                 my @reserve_date_data;
    #                 $reserve_date_data[0] = $getstarted_on_day;
    #                 for ( my $i = 1 ; $i < 8 ; ++$i ) {
    #                     $reserve_date_data[$i] = $getstarted_on_day - ONE_DAY * $i;
    #                 }

    #                 #日付データから文字データに変換する
    #                 my @reserve_date;
    #                 for ( my $i = 0 ; $i < 8 ; ++$i ) {
    #                     $reserve_date[$i] = $reserve_date_data[$i]->date;
    #                 }
    #                 $reserve_date[8] = $input_date;

    #                 #利用出来る
    #                 #my $judg_privateconditions = 0;
    #                 #利用できない
    #                 $judg_privateconditions = 1;

    #                 # 判定
    #                 for ( my $i = 0 ; $i <= $privateconditions ; ++$i ) {
    #                     if ( @reserve_date[$i] eq $input_date ) {

    #                         #利用できる
    #                         $judg_privateconditions = 0;
    #                     }
    #                 }

    #             }
    #             elsif ( $useform == 2 ) {

    #                 #============================
    #                 #一般ユーザーが選択されてる時に利用停止->2が選択されてはいけない
    #                 #利用出来る
    #                 $judg_general_id = 0;

    #                 #利用出来ない
    #                 #my $judg_general_id = 1;
    #                 if ( $useform == 2 ) {
    #                     my $general_id = $self->param('general_id');

    #                     # 判定
    #                     if ($general_id) { $judg_general_id = 1; }
    #                 }
    #             }

    #             #バンドの場合
    #             else {
    #                 $judg_privatepermit     = 0;
    #                 $judg_privateconditions = 0;
    #                 $judg_general_id        = 0;
    #             }

    #             #============================
    #             return
    #                 ($judg_privatepermit)     ? ( 0, '個人練習が許可されてない' )
    #               : ($judg_privateconditions) ? ( 0, 'その指定日では個人練習は利用できません' )
    #               : ($judg_general_id)        ? ( 0, '一般ユーザーは利用できない' )
    #               :                             1;
    #         }
    #     );

    #     # 伝言板 message->空白でもいいが文字数の制限をする
    #     $validator->field('message')->required(0)->length( 0, 20 );

    #     # 一般ユーザー、管理、 general_id　admin_id->どちらかを選択、両方はNG
    #     #$validator->field('admin_id')->callback(sub {
    #     #    my $admin_id   = shift;
    #     #    my $general_id = $self->param('general_id');
    #     #    #NG 両方が0　 両方が0以外
    #     #    return   (  $general_id and   $admin_id) ? (0, '両方の選択は不可')
    #     #           : (! $general_id and ! $admin_id) ? (0, '一般、管理どちらかを選択してください')
    #     #           :                                    1
    #     #           ;
    #     #});

    #     # 電話番号、 tel->必須、文字制限
    #     $validator->field('tel')->required(1)->length( 1, 30 );

    #     #mojoのコマンドでパラメーターをハッシュで取得入力した値をFIllin時に使うため、
    #     my $param_hash = $self->req->params->to_hash;
    #     $self->stash( param_hash => $param_hash );

    #     #入力検査合格、の時、値を新規もしくは修正アップロード実行
    #     if ( $self->validate( $validator, $param_hash ) ) {

    #         #ここでいったん入力値を全部受け取っておく 日付データ作成する
    #         #die "hoge";
    #         my $today = localtime;

    #         my $id          = $self->param('id');
    #         my $roominfo_id = $self->param('roominfo_id');

    #         #データ加工
    #         my $getstarted_on_day  = $self->param('getstarted_on_day');
    #         my $getstarted_on_time = $self->param('getstarted_on_time');
    #         my $enduse_on_day      = $self->param('enduse_on_day');
    #         my $enduse_on_time     = $self->param('enduse_on_time');

    #         #my $getstarted_on     = $self->param('getstarted_on');
    #         #my $enduse_on         = $self->param('enduse_on');
    #         my $useform    = $self->param('useform');
    #         my $message    = $self->param('message');
    #         my $general_id = $self->param('general_id');

    #         #my $admin_id           = $self->param('admin_id');
    #         my $admin_id = $login_id;
    #         my $tel      = $self->param('tel');

    #         #my $status             = $self->param('status');
    #         my $status    = 0;
    #         my $create_on = $today->datetime( date => '-', T => ' ' );
    #         my $modify_on = $today->datetime( date => '-', T => ' ' );

    #         # 一発hボタンを押した時のスクリプト
    #         $enduse_on_time =
    #             ( $h_botton eq "1h" ) ? $getstarted_on_time + 1
    #           : ( $h_botton eq "2h" ) ? $getstarted_on_time + 2
    #           : ( $h_botton eq "3h" ) ? $getstarted_on_time + 3
    #           : ( $h_botton eq "4h" ) ? $getstarted_on_time + 4
    #           : ( $h_botton eq "5h" ) ? $getstarted_on_time + 5
    #           :                         $enduse_on_time;

    #         #(分：３０)になっているかチェック値を切替
    #         my $roominfo_ref = $teng->single( 'roominfo', { 'id' => $roominfo_id } );
    #         my $time_change = $roominfo_ref->time_change;

    #         #sql書き込む前に開始、終了時刻変換,日付も考慮
    #         if ( $getstarted_on_time =~ /^[2][4-9]$/ ) {
    #             $getstarted_on_time -= 24;
    #             if ($time_change) {
    #                 $getstarted_on_time .= ":30";
    #             }
    #             else {
    #                 $getstarted_on_time .= ":00";
    #             }

    #             #日付を1日進める
    #             $getstarted_on_day = localtime->strptime( $getstarted_on_day, '%Y-%m-%d' );
    #             $getstarted_on_day = $getstarted_on_day + ONE_DAY * 1;
    #             $getstarted_on_day = $getstarted_on_day->date;
    #         }
    #         else {
    #             if ($time_change) {
    #                 $getstarted_on_time .= ":30";
    #             }
    #             else {
    #                 $getstarted_on_time .= ":00";
    #             }
    #         }
    #         if ( $enduse_on_time =~ /^[2][4-9]$|^[3][0]$/ ) {
    #             $enduse_on_time -= 24;
    #             if ($time_change) {
    #                 $enduse_on_time .= ":30";
    #             }
    #             else {
    #                 $enduse_on_time .= ":00";
    #             }

    #             #日付を1日進める
    #             $enduse_on_day = localtime->strptime( $enduse_on_day, '%Y-%m-%d' );
    #             $enduse_on_day = $enduse_on_day + ONE_DAY * 1;
    #             $enduse_on_day = $enduse_on_day->date;
    #         }
    #         else {
    #             if ($time_change) {
    #                 $enduse_on_time .= ":30";
    #             }
    #             else {
    #                 $enduse_on_time .= ":00";
    #             }
    #         }

    #         #日付、時間データもどし
    #         my $getstarted_on = $getstarted_on_day . " " . $getstarted_on_time;
    #         my $enduse_on     = $enduse_on_day . " " . $enduse_on_time;

    #         #idがある時、修正データの場合sql実行
    #         if ( $id eq "AUTO_NUMBER" ) {
    #             $id = undef;
    #         }
    #         if ($id) {

    #             #変更前の内容を抽出before_
    #             #sqlのデータを抽出する
    #             #reserveデータ
    #             my $before_reserve_ref = $teng->single( 'reserve', +{ 'id' => $id } );

    #             my $before_roominfo_id   = $before_reserve_ref->roominfo_id;
    #             my $before_getstarted_on = $before_reserve_ref->getstarted_on;
    #             my $before_enduse_on     = $before_reserve_ref->enduse_on;
    #             my $before_useform       = $before_reserve_ref->useform;
    #             my $before_message       = $before_reserve_ref->message;
    #             my $before_general_id    = $before_reserve_ref->general_id;
    #             my $before_admin_id      = $before_reserve_ref->admin_id;
    #             my $before_tel           = $before_reserve_ref->tel;

    #             # $useformを変換
    #             $before_useform =
    #                 ( $before_useform eq '0' ) ? $USEFORM_0
    #               : ( $before_useform eq '1' ) ? $USEFORM_1
    #               : ( $before_useform eq '2' ) ? $USEFORM_2
    #               :                              '該当なし';

    #             #roominfoデータ
    #             my $before_roominfo_ref = $teng->single( 'roominfo', +{ 'id' => $before_roominfo_id } );

    #             #my $before_storeinfo_id    = $before_roominfo_ref->storeinfo_id;
    #             my $before_name             = $before_roominfo_ref->name;
    #             my $before_pricescomments   = $before_roominfo_ref->pricescomments;
    #             my $before_roominfo_remarks = $before_roominfo_ref->remarks;

    #             #storeinfoデータ
    #             #my $before_storeinfo_ref   = $teng->single('storeinfo', +{'id' => $before_storeinfo_id});
    #             #
    #             #my $before_storeinfo_name  = $before_storeinfo_ref->name;
    #             #my $before_post            = $before_storeinfo_ref->post;
    #             #my $before_state           = $before_storeinfo_ref->state;
    #             #my $before_cities          = $before_storeinfo_ref->cities;
    #             #my $before_addressbelow    = $before_storeinfo_ref->addressbelow;
    #             #my $before_storeinfo_tel   = $before_storeinfo_ref->tel;
    #             #my $before_storeinfo_mail  = $before_storeinfo_ref->mail;
    #             #my $before_remarks         = $before_storeinfo_ref->remarks;
    #             #my $before_url             = $before_storeinfo_ref->url;
    #             #修正データをsqlへ送り込む
    #             my $count = $teng->update(
    #                 'reserve' => {
    #                     'roominfo_id'   => $roominfo_id,
    #                     'getstarted_on' => $getstarted_on,
    #                     'enduse_on'     => $enduse_on,
    #                     'useform'       => $useform,
    #                     'message'       => $message,

    #                     #'general_id'    => $general_id,
    #                     'admin_id' => $admin_id,
    #                     'tel'      => $tel,
    #                     'status'   => $status,

    #                     #'create_on'     => $create_on,
    #                     'modify_on' => $modify_on,
    #                 },
    #                 { 'id' => $id, }
    #             );
    #             $self->flash( henkou => '修正完了' );

    #             #sqlのデータを抽出する
    #             #reserveデータ
    #             my $reserve_ref = $teng->single( 'reserve', +{ 'id' => $id } );

    #             my $roominfo_id   = $reserve_ref->roominfo_id;
    #             my $getstarted_on = $reserve_ref->getstarted_on;
    #             my $enduse_on     = $reserve_ref->enduse_on;
    #             my $useform       = $reserve_ref->useform;
    #             my $message       = $reserve_ref->message;
    #             my $general_id    = $reserve_ref->general_id;
    #             my $admin_id      = $reserve_ref->admin_id;
    #             my $tel           = $reserve_ref->tel;

    #             # $useformを変換
    #             $useform =
    #                 ( $useform eq '0' ) ? $USEFORM_0
    #               : ( $useform eq '1' ) ? $USEFORM_1
    #               : ( $useform eq '2' ) ? $USEFORM_2
    #               :                       '該当なし';

    #             #roominfoデータ
    #             my $roominfo_ref = $teng->single( 'roominfo', +{ 'id' => $roominfo_id } );

    #             my $storeinfo_id     = $roominfo_ref->storeinfo_id;
    #             my $name             = $roominfo_ref->name;
    #             my $pricescomments   = $roominfo_ref->pricescomments;
    #             my $roominfo_remarks = $roominfo_ref->remarks;

    #             #storeinfoデータ
    #             my $storeinfo_ref = $teng->single( 'storeinfo', +{ 'id' => $storeinfo_id } );

    #             my $storeinfo_name = $storeinfo_ref->name;
    #             my $post           = $storeinfo_ref->post;
    #             my $state          = $storeinfo_ref->state;
    #             my $cities         = $storeinfo_ref->cities;
    #             my $addressbelow   = $storeinfo_ref->addressbelow;
    #             my $storeinfo_tel  = $storeinfo_ref->tel;
    #             my $storeinfo_mail = $storeinfo_ref->mail;
    #             my $remarks        = $storeinfo_ref->remarks;
    #             my $url            = $storeinfo_ref->url;

    #             #profileデータ
    #             my $general_profile_ref;
    #             my $admin_profile_ref;

    #             my $general_nick_name;
    #             my $general_full_name;
    #             my $general_mail;
    #             my $general_tel;

    #             my $admin_nick_name;
    #             my $admin_full_name;
    #             my $admin_mail;
    #             my $admin_tel;

    #             if ($general_id) {
    #                 $general_profile_ref = $teng->single( 'profile', +{ 'general_id' => $general_id } );

    #                 $general_nick_name = $general_profile_ref->nick_name;
    #                 $general_full_name = $general_profile_ref->full_name;
    #                 $general_mail      = $general_profile_ref->mail;
    #                 $general_tel       = $general_profile_ref->tel;

    #             }
    #             $admin_profile_ref = $teng->single( 'profile', +{ 'admin_id' => $admin_id } );

    #             $admin_nick_name = $admin_profile_ref->nick_name;
    #             $admin_full_name = $admin_profile_ref->full_name;
    #             $admin_mail      = $admin_profile_ref->mail;
    #             $admin_tel       = $admin_profile_ref->tel;

    #             #mailbox用のステータス
    #             my $mailbox_type_mail = 5;
    #             my $mailbox_status    = 0;

    #             #メール送信の為のデータを保存する=========
    #             my $row = $teng->insert(
    #                 'mailbox' => {

    #                     #'id'                               =>,
    #                     'storeinfo_name'                 => $storeinfo_name,
    #                     'storeinfo_post'                 => $post,
    #                     'storeinfo_state'                => $state,
    #                     'storeinfo_cities'               => $cities,
    #                     'storeinfo_addressbelow'         => $addressbelow,
    #                     'storeinfo_tel'                  => $storeinfo_tel,
    #                     'storeinfo_mail'                 => $storeinfo_mail,
    #                     'storeinfo_url'                  => $url,
    #                     'storeinfo_remarks'              => $remarks,
    #                     'roominfo_name'                  => $name,
    #                     'reserve_getstarted_on'          => $getstarted_on,
    #                     'reserve_enduse_on'              => $enduse_on,
    #                     'reserve_useform'                => $useform,
    #                     'roominfo_pricescomments'        => $pricescomments,
    #                     'roominfo_remarks'               => $roominfo_remarks,
    #                     'reserve_message'                => $message,
    #                     'admin_nick_name'                => $admin_nick_name,
    #                     'admin_full_name'                => $admin_full_name,
    #                     'admin_tel'                      => $admin_tel,
    #                     'admin_mail'                     => $admin_mail,
    #                     'general_nick_name'              => $general_nick_name,
    #                     'general_full_name'              => $general_full_name,
    #                     'general_tel'                    => $general_tel,
    #                     'general_mail'                   => $general_mail,
    #                     'before_roominfo_name'           => $before_name,
    #                     'before_reserve_getstarted_on'   => $before_getstarted_on,
    #                     'before_reserve_enduse_on'       => $before_enduse_on,
    #                     'before_reserve_useform'         => $before_useform,
    #                     'before_roominfo_pricescomments' => $before_pricescomments,
    #                     'before_roominfo_remarks'        => $before_roominfo_remarks,
    #                     'before_reserve_message'         => $before_message,
    #                     'type_mail'                      => $mailbox_type_mail,
    #                     'status'                         => $mailbox_status,
    #                     'create_on'                      => $create_on,

    #                     #'modify_on'                        =>,
    #                 }
    #             );

    #             # my $reserve_subject  = '[yoyakku]管理者予約変更のお知らせ【'.$today->datetime(date => '-', T => ' ').'】';
    #             # my $reserve_messages = <<EOD;
    #             # 管理者　$admin_nick_name　様

    #             # 一般ユーザー　$general_nick_name　様

    #             # この度は、yoyakkuをご利用頂き、誠にありがとうございます。

    #             # 管理者により予約の変更が行われました。

    #             # ご予約変更は下記の通りとなります
    #             #変更後予約==========
    #             #
    #             #ご予約店舗情報----------
    #             #【店舗名】$storeinfo_name
    #             #【住所】　$post
    #             #　　　　　$state $cities
    #             #　　　　　$addressbelow
    #             #【電話】　$storeinfo_tel
    #             #【メール】$storeinfo_mail
    #             #【ＵＲＬ】$url
    #             #【備考】　$remarks
    #             #
    #             #ご予約内容----------
    #             #【部屋】$name
    #             #【開始】$getstarted_on
    #             #【終了】$enduse_on
    #             #【利用】$useform
    #             #【料金】$pricescomments
    #             #【伝言】$message
    #             #
    #             #予約者情報【管理者】----------
    #             #【予約名】$admin_nick_name
    #             #【氏名】$admin_full_name
    #             #【電話】$admin_tel
    #             #【メール】$admin_mail
    #             #
    #             #予約者情報【一般ユーザー】----------
    #             #【予約名】$general_nick_name
    #             #【氏名】$general_full_name
    #             #【電話】$general_tel
    #             #【メール】$general_mail
    #             #
    #             #
    #             #
    #             #変更前予約==========
    #             #
    #             #
    #             #ご予約内容----------
    #             #【部屋】$before_name
    #             #【開始】$before_getstarted_on
    #             #【終了】$before_enduse_on
    #             #【利用】$before_useform
    #             #【料金】$before_pricescomments
    #             #【伝言】$before_message
    #             #
    #             #EOD
    #             #            my $utf8 = find_encoding('utf8');
    #             #            # メール作成
    #             #            my $subject = $utf8->encode($reserve_subject);
    #             #            my $body    = $utf8->encode($reserve_messages . $footer_message);
    #             #
    #             #            use Email::MIME;
    #             #            my $email = Email::MIME->create(
    #             #                header => [
    #             #                    From    => 'yoyakku@gmail.com', # 送信元
    #             #                    To      => $storeinfo_mail,    # 送信先
    #             #                    To      => $general_mail,    # 送信先
    #             #                    Subject => $subject,           # 件名
    #             #                ],
    #             #                body => $body,                     # 本文
    #             #                attributes => {
    #             #                    content_type => 'text/plain',
    #             #                    charset      => 'UTF-8',
    #             #                    encoding     => '7bit',
    #             #                },
    #             #            );
    #             #
    #             #            # SMTP接続設定
    #             #            #gmail
    #             #            use Email::Sender::Transport::SMTP::TLS;
    #             #            my $transport = Email::Sender::Transport::SMTP::TLS->new(
    #             #                {
    #             #                    host     => 'smtp.gmail.com',
    #             #                    port     => 587,
    #             #                    username => 'yoyakku@gmail.com',
    #             #                    password => 'googleyoyakku',
    #             #                }
    #             #            );
    #             #            # メール送信
    #             #            use Try::Tiny;
    #             #            use Email::Sender::Simple 'sendmail';
    #             #            try {
    #             #                sendmail($email, {'transport' => $transport});
    #             #            } catch {
    #             #                my $e = shift;
    #             #                die "Error: $e";
    #             #            };
    #         }
    #         else {
    #             #idが無い場合、新規登録sql実行 新規登録データをsqlへ送り込む
    #             my $row = $teng->insert(
    #                 'reserve' => {

    #                     #'id'            => $id,
    #                     'roominfo_id'   => $roominfo_id,
    #                     'getstarted_on' => $getstarted_on,
    #                     'enduse_on'     => $enduse_on,
    #                     'useform'       => $useform,
    #                     'message'       => $message,
    #                     'general_id'    => $general_id,
    #                     'admin_id'      => $admin_id,
    #                     'tel'           => $tel,
    #                     'status'        => $status,
    #                     'create_on'     => $create_on,

    #                     #'modify_on'     => $modify_on,
    #                 }
    #             );
    #             $self->flash( touroku => '登録完了' );

    #             #sqlのデータを抽出する
    #             #reserveデータ
    #             my $reserve_ref = $teng->single(
    #                 'reserve',
    #                 +{
    #                     'admin_id'  => $admin_id,
    #                     'create_on' => $create_on
    #                 }
    #             );

    #             my $roominfo_id   = $reserve_ref->roominfo_id;
    #             my $getstarted_on = $reserve_ref->getstarted_on;
    #             my $enduse_on     = $reserve_ref->enduse_on;
    #             my $useform       = $reserve_ref->useform;
    #             my $message       = $reserve_ref->message;
    #             my $general_id    = $reserve_ref->general_id;
    #             my $tel           = $reserve_ref->tel;

    #             # $useformを変換
    #             $useform =
    #                 ( $useform eq '0' ) ? $USEFORM_0
    #               : ( $useform eq '1' ) ? $USEFORM_1
    #               : ( $useform eq '2' ) ? $USEFORM_2
    #               :                       '該当なし';

    #             #roominfoデータ
    #             my $roominfo_ref = $teng->single( 'roominfo', +{ 'id' => $roominfo_id } );

    #             my $storeinfo_id     = $roominfo_ref->storeinfo_id;
    #             my $name             = $roominfo_ref->name;
    #             my $pricescomments   = $roominfo_ref->pricescomments;
    #             my $roominfo_remarks = $roominfo_ref->remarks;

    #             #storeinfoデータ
    #             my $storeinfo_ref = $teng->single( 'storeinfo', +{ 'id' => $storeinfo_id } );

    #             my $storeinfo_name = $storeinfo_ref->name;
    #             my $post           = $storeinfo_ref->post;
    #             my $state          = $storeinfo_ref->state;
    #             my $cities         = $storeinfo_ref->cities;
    #             my $addressbelow   = $storeinfo_ref->addressbelow;
    #             my $storeinfo_tel  = $storeinfo_ref->tel;
    #             my $storeinfo_mail = $storeinfo_ref->mail;
    #             my $remarks        = $storeinfo_ref->remarks;
    #             my $url            = $storeinfo_ref->url;

    #             #profileデータ
    #             my $general_profile_ref;
    #             my $admin_profile_ref;

    #             my $general_nick_name;
    #             my $general_full_name;
    #             my $general_mail;
    #             my $general_tel;

    #             my $admin_nick_name;
    #             my $admin_full_name;
    #             my $admin_mail;
    #             my $admin_tel;

    #             if ($general_id) {
    #                 $general_profile_ref = $teng->single( 'profile', +{ 'general_id' => $general_id } );

    #                 $general_nick_name = $general_profile_ref->nick_name;
    #                 $general_full_name = $general_profile_ref->full_name;
    #                 $general_mail      = $general_profile_ref->mail;
    #                 $general_tel       = $general_profile_ref->tel;

    #             }
    #             $admin_profile_ref = $teng->single( 'profile', +{ 'admin_id' => $admin_id } );

    #             $admin_nick_name = $admin_profile_ref->nick_name;
    #             $admin_full_name = $admin_profile_ref->full_name;
    #             $admin_mail      = $admin_profile_ref->mail;
    #             $admin_tel       = $admin_profile_ref->tel;

    #             #mailbox用のステータス
    #             my $mailbox_type_mail = 3;
    #             my $mailbox_status    = 0;

    #             #メール送信の為のデータを保存する=========
    #             my $row = $teng->insert(
    #                 'mailbox' => {

    #                     #'id'                               =>,
    #                     'storeinfo_name'          => $storeinfo_name,
    #                     'storeinfo_post'          => $post,
    #                     'storeinfo_state'         => $state,
    #                     'storeinfo_cities'        => $cities,
    #                     'storeinfo_addressbelow'  => $addressbelow,
    #                     'storeinfo_tel'           => $storeinfo_tel,
    #                     'storeinfo_mail'          => $storeinfo_mail,
    #                     'storeinfo_url'           => $url,
    #                     'storeinfo_remarks'       => $remarks,
    #                     'roominfo_name'           => $name,
    #                     'reserve_getstarted_on'   => $getstarted_on,
    #                     'reserve_enduse_on'       => $enduse_on,
    #                     'reserve_useform'         => $useform,
    #                     'roominfo_pricescomments' => $pricescomments,
    #                     'roominfo_remarks'        => $roominfo_remarks,
    #                     'reserve_message'         => $message,
    #                     'admin_nick_name'         => $admin_nick_name,
    #                     'admin_full_name'         => $admin_full_name,
    #                     'admin_tel'               => $admin_tel,
    #                     'admin_mail'              => $admin_mail,
    #                     'general_nick_name'       => $general_nick_name,
    #                     'general_full_name'       => $general_full_name,
    #                     'general_tel'             => $general_tel,
    #                     'general_mail'            => $general_mail,

    #                     #'before_roominfo_name'             =>$before_name,
    #                     #'before_reserve_getstarted_on'     =>$before_getstarted_on,
    #                     #'before_reserve_enduse_on'         =>$before_enduse_on,
    #                     #'before_reserve_useform'           =>$before_useform,
    #                     #'before_roominfo_pricescomments'   =>$before_pricescomments,
    #                     #'before_roominfo_remarks'          =>$before_roominfo_remarks,
    #                     #'before_reserve_message'           =>$before_message,
    #                     'type_mail' => $mailbox_type_mail,
    #                     'status'    => $mailbox_status,
    #                     'create_on' => $create_on,

    #                     #'modify_on'                        =>,
    #                 }
    #             );

    #             #my $reserve_subject  = '[yoyakku]管理者予約完了のお知らせ【'.$today->datetime(date => '-', T => ' ').'】';
    #             #my $reserve_messages = <<EOD;
    #             #管理者　$admin_nick_name　様
    #             #
    #             #一般ユーザー　$general_nick_name　様
    #             #
    #             #この度は、yoyakkuをご利用頂き、誠にありがとうございます。
    #             #
    #             #管理者により予約の確定が行われました。
    #             #
    #             #ご予約内容は下記の通りとなります
    #             #
    #             #ご予約店舗情報----------
    #             #【店舗名】$storeinfo_name
    #             #【住所】　$post
    #             #　　　　　$state $cities
    #             #　　　　　$addressbelow
    #             #【電話】　$storeinfo_tel
    #             #【メール】$storeinfo_mail
    #             #【ＵＲＬ】$url
    #             #【備考】　$remarks
    #             #
    #             #ご予約内容----------
    #             #【部屋】$name
    #             #【開始】$getstarted_on
    #             #【終了】$enduse_on
    #             #【利用】$useform
    #             #【料金】$pricescomments
    #             #【伝言】$message
    #             #
    #             #予約者情報【管理者】----------
    #             #【予約名】$admin_nick_name
    #             #【氏名】$admin_full_name
    #             #【電話】$admin_tel
    #             #【メール】$admin_mail
    #             #
    #             #予約者情報【一般ユーザー】----------
    #             #【予約名】$general_nick_name
    #             #【氏名】$general_full_name
    #             #【電話】$general_tel
    #             #【メール】$general_mail
    #             #
    #             #EOD
    #             #            my $utf8 = find_encoding('utf8');
    #             #            # メール作成
    #             #            my $subject = $utf8->encode($reserve_subject);
    #             #            my $body    = $utf8->encode($reserve_messages . $footer_message);
    #             #
    #             #            use Email::MIME;
    #             #            my $email = Email::MIME->create(
    #             #                header => [
    #             #                    From    => 'yoyakku@gmail.com', # 送信元
    #             #                    To      => $storeinfo_mail,    # 送信先
    #             #                    To      => $general_mail,    # 送信先
    #             #                    Subject => $subject,           # 件名
    #             #                ],
    #             #                body => $body,                     # 本文
    #             #                attributes => {
    #             #                    content_type => 'text/plain',
    #             #                    charset      => 'UTF-8',
    #             #                    encoding     => '7bit',
    #             #                },
    #             #            );
    #             #
    #             #            # SMTP接続設定
    #             #            #gmail
    #             #            use Email::Sender::Transport::SMTP::TLS;
    #             #            my $transport = Email::Sender::Transport::SMTP::TLS->new(
    #             #                {
    #             #                    host     => 'smtp.gmail.com',
    #             #                    port     => 587,
    #             #                    username => 'yoyakku@gmail.com',
    #             #                    password => 'googleyoyakku',
    #             #                }
    #             #            );
    #             #            # メール送信
    #             #            use Try::Tiny;
    #             #            use Email::Sender::Simple 'sendmail';
    #             #            try {
    #             #                sendmail($email, {'transport' => $transport});
    #             #            } catch {
    #             #                my $e = shift;
    #             #                die "Error: $e";
    #             #            };
    #         }

    #         #sqlにデータ入力したのでlist画面にリダイレクト
    #         return $self->redirect_to('admin_reserv_list');

    #         #リターンなのでここでおしまい。
    #     }

    #     #入力検査合格しなかった場合、もう一度入力フォーム表示Fillinにて
    #     my $html = $self->render_partial()->to_string;
    #     $html = HTML::FillInForm->fill( \$html, $self->req->params, );
    #     return $self->render_text( $html, format => 'html' );

    #     #リターンなのでここでおしまい。
    # }


    # ================================================

    return;
}

1;

__END__

#admin_reserv_list.html.ep
#予約部屋、公開設定確認コントロール-----------------------------
any '/admin_reserv_list' => sub {

    #=======================================================
    # 予約テーブルスクリプト

    # roominfoから開始時間と終了時間を引き出して、営業してない時間のハッシュを作る
    my %close_store;
    my $close_store_val = "close_store";

    my %outside;
    my $outside_val = "outside";

    my %timeout;
    my $timeout_val = "timeout";

    my ( @id, @name, );

    for my $roominfo_ref (@roominfos) {
        push( @id,   $roominfo_ref->id );
        push( @name, $roominfo_ref->name );

        # 開始時間をしていする変数
        my $start_time_key = substr( $roominfo_ref->starttime_on, 0, 2 );

        # 時間軸を0:00->24:00にそろえる
        my $time_adj = 24;

        # 0:00-5:00の場合24:00-29:00にする24をたす、日付を前日にする
        if ( $start_time_key =~ /^[0][0-5]/ ) {
            $start_time_key = $start_time_key + $time_adj;
        }

        # 終了時間を指定する変数をつくる# 時間軸を0:00->24:00にそろえる
        my $end_time_key = substr( $roominfo_ref->endingtime_on, 0, 2 );

        # 0:00-6:00の場合24:00-30:00にする24をたす
        if ( $end_time_key =~ /^[0][0-6]/ ) {
            $end_time_key = $end_time_key + $time_adj;
        }

        # 終了時間から開始時間を引いて、利用時間をはじき出す
        # 開始時刻からカレンダーの開始時刻を引いて、営業してない開店前をはじき出す。

        my $before_opening = $start_time_key - 7;
        my $time_key       = 6;

        # 開始時間から終了時間まで時間枠ごとのハッシュ名をつけた
        # 配列をつくってみる。
        # 配列の数だけ配列の中身を繰り返しハッシュに追加する
        for my $before_open ( 0 .. $before_opening ) {
            my $room_id_key     = $roominfo_ref->id;
            my $close_store_key = "close_store" . "_" . $room_id_key . "_" . $time_key;
            $close_store{$close_store_key} = $close_store_val;
            ++$time_key;
        }

        my $after_closing = 30 - $end_time_key;
        my $time_key      = $end_time_key;

        # 開始時間から終了時間まで時間枠ごとのハッシュ名をつけた
        # 配列をつくってみる。
        # 配列の数だけ配列の中身を繰り返しハッシュに追加する
        for my $after_clos ( 0 .. $after_closing ) {
            my $room_id_key     = $roominfo_ref->id;
            my $close_store_key = "close_store" . "_" . $room_id_key . "_" . $time_key;
            $close_store{$close_store_key} = $close_store_val;
            ++$time_key;
        }

        # 利用停止になっている部屋はすべての時間をステータスoutside
        if ( $roominfo_ref->status == 0 ) {
            for my $outside_time ( 6 .. 29 ) {
                my $room_id_key = $roominfo_ref->id;
                my $outside_key = "outside" . "_" . $room_id_key . "_" . $outside_time;
                $outside{$outside_key} = $outside_val;
            }
        }

        # 現在時刻が予約の時間枠をすぎたときのtimeoverタグの付け方
        # ただし、本日の場合のみ起動する
        my $time_now = localtime;

        #日付変更線が6時になる
        my $chang_date_ref = chang_date_6($time_now);

        $time_now = $chang_date_ref->{now_date};

        if ( $select_date->date eq $time_now->date ) {
            my $time_over = $time_now->hour;

            # 時間時を24-30に変換
            if ( $time_over =~ m/^[0-5]$/ ) {
                $time_over += 24;
            }
            for my $time_limit ( 6 .. 29 ) {
                if ( $time_limit <= $time_over ) {
                    my $room_id_key = $roominfo_ref->id;
                    my $timeout_key = "timeout" . "_" . $room_id_key . "_" . $time_limit;
                    $timeout{$timeout_key} = $timeout_val;
                }
            }
        }

    }

    #値おくりこみ,ハッシュにするのが大事
    $self->stash(
        id_ref          => \@id,
        name_ref        => \@name,
        close_store_ref => \%close_store,
        outside_ref     => \%outside,
        timeout_ref     => \%timeout,
    );    # テンプレートへ送り、

    #----------

    # ================================================
    # 4/15　予約情報の取り出しのロジックを過去のコードを参考に書き直し
    # スタジオ予約内容取り出しのsql
    # sqlを取り出す時点で、(指定の日付6:00-翌朝6:00取り出し)
    # 絞り込み、今指定している、店舗idから部屋idまで絞り込みforで
    # 絞り込んだ予約情報の時間軸を変更する00->24表示に
    # 終了時間から開始時間を引いて利用時間をつくる

    # 取り出し条件の為の変数定義
    # calnaviで選択した日付をうけとる

    #テストなので日付べたうち
    my $start_time = $select_date->date . " 06:00:00";
    my $end_time;
    $end_time = localtime->strptime( $select_date->date, '%Y-%m-%d' );
    $end_time = $end_time + ONE_DAY * 1;
    $end_time = $end_time->date;
    $end_time = $end_time . " 06:00:00";

    #表示するための、予約情報データ
    my @display_res_rows = $teng->search_named( q{select * from reserve where getstarted_on >= :start_time and getstarted_on < :end_time ; }, { start_time => $start_time, end_time => $end_time } );

    # データ作る為の、部屋情報roominfo sql
    # スタジオ部屋設定条件を読み込み
    my @roominfo_rows = $teng->search_named(q{select * from roominfo order by id asc; });

    # 0:00-6:00までの時間差を修正したスクリプト->24-30に変更する
    # 指定されている日付の朝6:00-翌朝6:00未満を絞り込んだsqlをさらに絞り込み
    my %select_res;
    my $select_res_val = "conf_res";

    # 予約済みの情報の中に、識別の為の値を加える
    # 管理者が予約したもの
    # 利用停止 conf_ref_stop_admin
    # 個人練習利用 conf_ref_individual_admin
    # バンド利用 conf_ref_individual_admin
    # 一般ユーザーが予約したもの
    # 個人練習利用 conf_ref_individual_general
    # バンド利用 conf_ref_individual_general
    # 予約内容の情報をおくるスクリプト
    my %select_detail_res;
    my $select_detail_res_val;

    for my $display_res_row_ref (@display_res_rows) {

        # ステータス0予約中のみを取り出し
        if ( $display_res_row_ref->status == 0 ) {

            # 今見ている店舗の部屋情報idをすべて取り出す。
            for my $roominfo_row_ref (@roominfo_rows) {

                # 今見ている店舗に該当する部屋情報idのみに絞り込み
                if ( $storeinfo_id == $roominfo_row_ref->storeinfo_id ) {

                    # 絞り込んだ部屋情報idすべてに該当する予約内容を取り出す
                    if ( $display_res_row_ref->roominfo_id == $roominfo_row_ref->id ) {

                        # 開始時間をしていする変数をつくる
                        my $start_time_key = substr( $display_res_row_ref->getstarted_on, 11, 2 );

                        # 時間軸を0:00->24:00にそろえる

                        my $time_adj = 24;

                        # 0:00-5:00の場合24:00-29:00にする24をたす、日付を前日にする
                        if ( $start_time_key =~ /^[0][0-5]/ ) {
                            $start_time_key = $start_time_key + $time_adj;
                        }

                        # 終了時間を指定する変数をつくる# 時間軸を0:00->24:00にそろえる
                        my $end_time_key = substr( $display_res_row_ref->enduse_on, 11, 2 );

                        # 0:00-5:00の場合24:00-29:00にする24をたす
                        if ( $end_time_key =~ /^[0][0-6]/ ) {
                            $end_time_key = $end_time_key + $time_adj;
                        }

                        # 終了時間から開始時間を引いて、利用時間をはじき出す
                        my $use_t_k  = $end_time_key - $start_time_key;
                        my $time_key = $start_time_key;

                        # 数字に変換しておく(7/7)
                        $time_key += 0;

                        # 開始時間から終了時間まで時間枠ごとのハッシュ名をつけた
                        # 配列をつくってみる。
                        # 配列の数だけ配列の中身を繰り返しハッシュに追加する
                        for ( my $i = 0 ; $i < $use_t_k ; ++$i ) {

                            #my %select_detail_res;
                            #my $select_detail_res_val;
                            # スタジオ部idを取得して変数定義(スタジオナンバー)
                            #my $name_key = $roominfo_row_ref->name;
                            my $name_key = $roominfo_row_ref->id;

                            #key名数字だけはまずいので変更
                            my $select_res_key = "conf_res" . "_" . $name_key . "_" . $time_key;

                            # detail用のkey作成
                            my $select_detail_res_key = "detail_res" . "_" . $name_key . "_" . $time_key;

                            #ハッシュの値の作り込み
                            # 管理者が予約したもの
                            if ( $display_res_row_ref->admin_id ) {

                                # 予約済みの情報の中に、識別の為の値を加える
                                $select_res_val =
                                    ( $display_res_row_ref->useform == 0 ) ? "conf_res_band_admin"
                                  : ( $display_res_row_ref->useform == 1 ) ? "conf_res_individual_admin"
                                  : ( $display_res_row_ref->useform == 2 ) ? "conf_res_stop_admin"
                                  :                                          $select_res_val;

                                #admin_idからログイン名を抽出
                                #my $admin_ref = $teng->single('admin', +{id => $display_res_row_ref->admin_id});
                                #$select_detail_res_val = $admin_ref->login;
                                $select_detail_res_val = $display_res_row_ref->message;
                            }

                            # 一般ユーザーが予約したもの
                            if ( $display_res_row_ref->general_id ) {

                                # 予約済みの情報の中に、識別の為の値を加える
                                $select_res_val =
                                    ( $display_res_row_ref->useform == 0 ) ? "conf_res_band_general"
                                  : ( $display_res_row_ref->useform == 1 ) ? "conf_res_individual_general"
                                  :                                          $select_res_val;

                                #profileからログイン名を抽出
                                #my $general_ref = $teng->single('general', +{id => $display_res_row_ref->general_id});
                                my $profile_ref = $teng->single( 'profile', +{ general_id => $display_res_row_ref->general_id } );
                                $select_detail_res_val = $profile_ref->nick_name;

                            }
                            $select_res{$select_res_key} = $display_res_row_ref->id . "_" . $select_res_val;

                            $select_detail_res{$select_detail_res_key} = $select_detail_res_val;

                            ++$time_key;
                        }
                    }
                }
            }
        }
    }

    #値おくりこみ,ハッシュにするのが大事
    # テンプレートへ送り、
    $self->stash( select_res_ref => \%select_res );

    # テンプレートへ送り、
    $self->stash( select_detail_res_ref => \%select_detail_res );

    # ================================================
    if ( uc $self->req->method eq 'POST' ) {

        # 予約内容を修正したりする部分はpost,submitボタン判定をする
        my $back = $self->param('back');
        if ($back) {
            return $self->redirect_to('admin_reserv_list');
        }

        # 予約取消ボタンが押されたときのスクリプト
        my $exe_cansel = $self->param('exe_cansel');
        if ($exe_cansel) {
            my $today     = localtime;
            my $modify_on = $today->datetime( date => '-', T => ' ' );
            my $create_on = $today->datetime( date => '-', T => ' ' );

            # 予約idを受け取る
            my $id = $self->param('id');

            # 該当するsqlの予約idをアップデート
            my $count = $teng->update(
                'reserve' => {
                    'admin_id'  => $login_id,
                    'status'    => 1,
                    'modify_on' => $modify_on,
                },
                { 'id' => $id, }
            );

            # ステータスを1（キャンセル）に書き込み
            #sqlのデータを抽出する
            #reserveデータ
            my $reserve_ref = $teng->single( 'reserve', +{ 'id' => $id } );

            my $roominfo_id   = $reserve_ref->roominfo_id;
            my $getstarted_on = $reserve_ref->getstarted_on;
            my $enduse_on     = $reserve_ref->enduse_on;
            my $useform       = $reserve_ref->useform;
            my $message       = $reserve_ref->message;
            my $general_id    = $reserve_ref->general_id;
            my $admin_id      = $reserve_ref->admin_id;
            my $tel           = $reserve_ref->tel;

            # $useformを変換
            $useform =
                ( $useform eq '0' ) ? $USEFORM_0
              : ( $useform eq '1' ) ? $USEFORM_1
              : ( $useform eq '2' ) ? $USEFORM_2
              :                       '該当なし';

            #roominfoデータ
            my $roominfo_ref = $teng->single( 'roominfo', +{ 'id' => $roominfo_id } );

            my $storeinfo_id     = $roominfo_ref->storeinfo_id;
            my $name             = $roominfo_ref->name;
            my $pricescomments   = $roominfo_ref->pricescomments;
            my $roominfo_remarks = $roominfo_ref->remarks;

            #storeinfoデータ
            my $storeinfo_ref = $teng->single( 'storeinfo', +{ 'id' => $storeinfo_id } );

            my $storeinfo_name = $storeinfo_ref->name;
            my $post           = $storeinfo_ref->post;
            my $state          = $storeinfo_ref->state;
            my $cities         = $storeinfo_ref->cities;
            my $addressbelow   = $storeinfo_ref->addressbelow;
            my $storeinfo_tel  = $storeinfo_ref->tel;
            my $storeinfo_mail = $storeinfo_ref->mail;
            my $remarks        = $storeinfo_ref->remarks;
            my $url            = $storeinfo_ref->url;

            #profileデータ
            my $general_profile_ref;
            my $admin_profile_ref;

            my $general_nick_name;
            my $general_full_name;
            my $general_mail;
            my $general_tel;

            my $admin_nick_name;
            my $admin_full_name;
            my $admin_mail;
            my $admin_tel;

            if ($general_id) {
                $general_profile_ref = $teng->single( 'profile', +{ 'general_id' => $general_id } );

                $general_nick_name = $general_profile_ref->nick_name;
                $general_full_name = $general_profile_ref->full_name;
                $general_mail      = $general_profile_ref->mail;
                $general_tel       = $general_profile_ref->tel;

            }
            $admin_profile_ref = $teng->single( 'profile', +{ 'admin_id' => $admin_id } );

            $admin_nick_name = $admin_profile_ref->nick_name;
            $admin_full_name = $admin_profile_ref->full_name;
            $admin_mail      = $admin_profile_ref->mail;
            $admin_tel       = $admin_profile_ref->tel;

            #mailbox用のステータス
            my $mailbox_type_mail = 4;
            my $mailbox_status    = 0;

            #メール送信の為のデータを保存する=========
            my $row = $teng->insert(
                'mailbox' => {

                    #'id'                               =>,
                    'storeinfo_name'          => $storeinfo_name,
                    'storeinfo_post'          => $post,
                    'storeinfo_state'         => $state,
                    'storeinfo_cities'        => $cities,
                    'storeinfo_addressbelow'  => $addressbelow,
                    'storeinfo_tel'           => $storeinfo_tel,
                    'storeinfo_mail'          => $storeinfo_mail,
                    'storeinfo_url'           => $url,
                    'storeinfo_remarks'       => $remarks,
                    'roominfo_name'           => $name,
                    'reserve_getstarted_on'   => $getstarted_on,
                    'reserve_enduse_on'       => $enduse_on,
                    'reserve_useform'         => $useform,
                    'roominfo_pricescomments' => $pricescomments,
                    'roominfo_remarks'        => $roominfo_remarks,
                    'reserve_message'         => $message,
                    'admin_nick_name'         => $admin_nick_name,
                    'admin_full_name'         => $admin_full_name,
                    'admin_tel'               => $admin_tel,
                    'admin_mail'              => $admin_mail,
                    'general_nick_name'       => $general_nick_name,
                    'general_full_name'       => $general_full_name,
                    'general_tel'             => $general_tel,
                    'general_mail'            => $general_mail,

                    #'before_roominfo_name'             =>,
                    #'before_reserve_getstarted_on'     =>,
                    #'before_reserve_enduse_on'         =>,
                    #'before_reserve_useform'           =>,
                    #'before_roominfo_pricescomments'   =>,
                    #'before_roominfo_remarks'          =>,
                    #'before_reserve_message'           =>,
                    'type_mail' => $mailbox_type_mail,
                    'status'    => $mailbox_status,
                    'create_on' => $create_on,

                    #'modify_on'                        =>,
                }
            );

            #my $cansel_subject  = '[yoyakku]管理者予約キャンセルのお知らせ【'.$today->datetime(date => '-', T => ' ').'】';
            #my $cancel_messages = <<EOD;
            #管理者　$admin_nick_name　様
            #
            #一般ユーザー　$general_nick_name　様
            #
            #この度は、yoyakkuをご利用頂き、誠にありがとうございます。
            #
            #管理者により予約のキャンセルが行われました。
            #
            #キャンセル内容は下記の通りとなります
            #
            #ご予約店舗情報----------
            #【店舗名】$storeinfo_name
            #【住所】　$post
            #　　　　　$state $cities
            #　　　　　$addressbelow
            #【電話】　$storeinfo_tel
            #【メール】$storeinfo_mail
            #【ＵＲＬ】$url
            #【備考】　$remarks
            #
            #ご予約内容----------
            #【部屋】$name
            #【開始】$getstarted_on
            #【終了】$enduse_on
            #【利用】$useform
            #【料金】$pricescomments
            #【伝言】$message
            #
            #予約者情報【管理者】----------
            #【予約名】$admin_nick_name
            #【氏名】$admin_full_name
            #【電話】$admin_tel
            #【メール】$admin_mail
            #
            #予約者情報【一般ユーザー】----------
            #【予約名】$general_nick_name
            #【氏名】$general_full_name
            #【電話】$general_tel
            #【メール】$general_mail
            #
            #
            #この内容をキャンセルいたしました。
            #
            #EOD
            #            my $utf8 = find_encoding('utf8');
            #            # メール作成
            #            my $subject = $utf8->encode($cansel_subject);
            #            my $body    = $utf8->encode($cancel_messages . $footer_message);
            #
            #            use Email::MIME;
            #            my $email = Email::MIME->create(
            #                header => [
            #                    From    => 'yoyakku@gmail.com', # 送信元
            #                    To      => $storeinfo_mail,    # 送信先
            #                    To      => $general_mail,    # 送信先
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
            # リダイレクト画面遷移、予約削除しました。
            return $self->redirect_to('up_admin_r_u_c_comp');
        }

        #}

        # 保存ボタンが押された時のスクリプト
        my $save     = $self->param('save');
        my $h_botton = $self->param('h_botton');
        if ( $save or $h_botton ) {

            #新規入力も修正もボタン押すとpostで入ってくる、両方バリデード実行
            # バリデーション()
            my $validator = $self->create_validator;

            #バリデーションが複雑になってきたのでもう一度順番に整理する
            #予約のダブり確認のバリデ
            $validator->field('id')->callback(
                sub {
                    my $value = shift;

                    my $judg_reserve_id = 0;    #予約既にあり
                    my $judg_reserve_id = 1;    #問題なし

                    # 予約のダブりが存在を確認するスクリプトをもう一度考えてみる
                    #入力した値を取得する=======================================================
                    # 入力した値を取得する(予約id,部屋情報id,利用開始時刻,利用終了時刻)
                    my $id          = $self->param('id');
                    my $roominfo_id = $self->param('roominfo_id');

                    #入力した予約の希望日付
                    my $kibou_date    = $self->param('getstarted_on_day');
                    my $kibou_start   = $self->param('getstarted_on_time');
                    my $enduse_on_day = $self->param('enduse_on_day');
                    my $kibou_end     = $self->param('enduse_on_time');

                    # 一発hボタンを押した時のスクリプト
                    $kibou_end =
                        ( $h_botton eq "1h" ) ? $kibou_start + 1
                      : ( $h_botton eq "2h" ) ? $kibou_start + 2
                      : ( $h_botton eq "3h" ) ? $kibou_start + 3
                      : ( $h_botton eq "4h" ) ? $kibou_start + 4
                      : ( $h_botton eq "5h" ) ? $kibou_start + 5
                      :                         $kibou_end;

                    #既に入力済みのデータをsqlから取り出す========================================
                    # 予約履歴を抽出する
                    my @reserves = $teng->search_named(q{select * from reserve;});

                    #比較したいデータのみを選別する===============================================
                    # 比較したいデータとは、入力した部屋id(roominfo_id)と同じもの
                    # 入力した予約id(id)は比較対象外にする
                    # ステータスが1(キャンセル)は比較対象外
                    # 予約データを一件づつすべて引き出す
                    foreach my $reserve_ref (@reserves) {

                        #入力したroominfo_idと同じデータのみ
                        if ( $reserve_ref->roominfo_id == $roominfo_id ) {

                            #入力した予約id以外のもの
                            if ( $reserve_ref->id ne $id ) {
                                if ( $reserve_ref->status ne 1 ) {

                                    #比較できるよう値を変換
                                    #データの利用開始と利用終了のデータを取り出し
                                    #利用開始日時取り出し
                                    my $getstarted_on = $reserve_ref->getstarted_on;

                                    #日付と時刻に分ける(ただしまだ通常の0-5時の形式)
                                    #日付
                                    my $getstarted_on_day = substr( $getstarted_on, 0, 10 );

                                    #時刻
                                    my $getstarted_on_time = substr( $getstarted_on, 11, 2 );

                                    #念のために時刻を数字の型にして、最初の0があれば表示しない
                                    #時刻0-5時の場合は24-29に変換、
                                    $getstarted_on_time += 0;
                                    if ( $getstarted_on_time =~ /^[0-5]$/ ) {
                                        $getstarted_on_time += 24;

                                        #日付を1日もどる
                                        $getstarted_on_day = localtime->strptime( $getstarted_on_day, '%Y-%m-%d' );
                                        $getstarted_on_day = $getstarted_on_day - ONE_DAY * 1;
                                        $getstarted_on_day = $getstarted_on_day->date;
                                    }

                                    #利用終了日時取り出し
                                    my $enduse_on = $reserve_ref->enduse_on;

                                    #日付と時刻に分ける(ただしまだ通常の0-6時の形式)
                                    #日付
                                    my $enduse_on_day = substr( $enduse_on, 0, 10 );

                                    #時刻
                                    my $enduse_on_time = substr( $enduse_on, 11, 2 );

                                    #念のために時刻を数字の型にして、最初の0があれば表示しない
                                    #時刻0-6時の場合は24-30に変換、
                                    $enduse_on_time += 0;
                                    if ( $enduse_on_time =~ /^[0-6]$/ ) {
                                        $enduse_on_time += 24;

                                        #日付を1日もどる
                                        $enduse_on_day = localtime->strptime( $enduse_on_day, '%Y-%m-%d' );
                                        $enduse_on_day = $enduse_on_day - ONE_DAY * 1;
                                        $enduse_on_day = $enduse_on_day->date;
                                    }

                                    #開始時刻から終了時刻一つ前まで、比較してゆく、一致すればdie!ダブり！
                                    #入力した日付とデータの日付が一致した時比較開始
                                    if ( $getstarted_on_day eq $kibou_date ) {

                                        #今見ているデータの時間軸をだす
                                        #比較の計算式を書き直し
                                        my $i = $getstarted_on_time;
                                        for ( $i ; $i < $enduse_on_time ; ++$i ) {

                                            #sqlのデータ
                                            #開始から終了一つ前まで１つづつ取り出し
                                            my $ii = $kibou_start;

                                            #入力データ
                                            for ( $ii ; $ii < $kibou_end ; ++$ii ) {
                                                if ( $i == $ii ) {
                                                    $judg_reserve_id = 0;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    #おしまし
                    return 1 if $judg_reserve_id;

                    return ( 0, '既に予約が存在します' );
                }
            );

            # 利用開始日時 getstarted_on->日付と時間
            #日付の書式のバリデ
            $validator->field('getstarted_on_day')->required(1)->constraint( 'date', split => '-' );

            # 抽出した部屋情報の開始時刻より遅く、終了時間より早い事(今の時刻より過去でないこと)
            $validator->field('getstarted_on_time')->callback(
                sub {
                    my $value = shift;

                    #指定の時刻(日)が過去の場合は予約(変更)できない
                    # データを日付データに変換して比較する

                    # 入力された日付(時刻)入手
                    my $select_getstarted_day  = $self->param('getstarted_on_day');
                    my $select_getstarted_time = $value;

                    # 今の日付(時刻)入手
                    my $now_datetime = localtime;

                    #比較できるように変換
                    # 今の日付時刻の文字列
                    my $now_datetime_ymd  = $now_datetime->date;
                    my $now_datetime_hour = $now_datetime->hour;

                    # 今の時刻が0-5の場合時刻を24-29にして、日付を一日もどす
                    if ( $now_datetime_hour =~ m/^[0-5]$/ ) {
                        $now_datetime_ymd = $now_datetime - ONE_DAY * 1;
                        $now_datetime_ymd = $now_datetime_ymd->date;
                        $now_datetime_hour += 24;
                    }

                    #今日の予約テーブル時間軸だけを比較
                    if ( $now_datetime_ymd eq $select_getstarted_day ) {
                        if ( $select_getstarted_time <= $now_datetime_hour ) {
                            return ( 0, '過ぎた時間です' );
                        }
                    }

                    # 部屋の利用開始と終了時刻の範囲内かを調べるバリデ
                    # 指定したスタジオ、部屋情報idを取得
                    my $roominfo_id = $self->param('roominfo_id');

                    # 該当する部屋の開始時刻と終了時刻を取得
                    my $starttime_on;
                    my @roominfos = $teng->search_named(q{select * from roominfo;});
                    foreach my $roominfo_ref (@roominfos) {
                        if ( $roominfo_ref->id == $roominfo_id ) {

                            #開始時刻取得
                            $starttime_on = $roominfo_ref->starttime_on;
                        }
                    }

                    #比較するため24-29の数字に変換
                    if ($starttime_on) {
                        $starttime_on = substr( $starttime_on, 0, 2 );
                        $starttime_on += 0;
                        if ( $starttime_on =~ /^[0-5]$/ ) {
                            $starttime_on += 24;
                        }
                    }

                    return 1 if $starttime_on <= $value;

                    return ( 0, '営業時間外です' );
                }
            );

            # 利用終了日時 enduse_on->日付と時間
            # 日付の書式バリデ、開始、終了同じ日付にさせる
            $validator->field('enduse_on_day')->required(1)->constraint( 'date', split => '-' )->callback(
                sub {
                    my $value             = shift;
                    my $getstarted_on_day = $self->param('getstarted_on_day');

                    return 1 if $getstarted_on_day eq $value;

                    return ( 0, '開始と同じ日付にして下さい' );
                }
            );

            $validator->field('enduse_on_time')->callback(
                sub {
                    #開始より終了が早い場合
                    my $value              = shift;
                    my $getstarted_on_time = $self->param('getstarted_on_time');

                    # 一発hボタンを押した時のスクリプト
                    $value =
                        ( $h_botton eq "1h" ) ? $getstarted_on_time + 1
                      : ( $h_botton eq "2h" ) ? $getstarted_on_time + 2
                      : ( $h_botton eq "3h" ) ? $getstarted_on_time + 3
                      : ( $h_botton eq "4h" ) ? $getstarted_on_time + 4
                      : ( $h_botton eq "5h" ) ? $getstarted_on_time + 5
                      :                         $value;
                    my @roominfos = $teng->search_named(q{select * from roominfo;});

                    # 指定したスタジオ、部屋情報idを取得
                    my $roominfo_id = $self->param('roominfo_id');

                    # 該当する部屋の終了時刻を取得
                    my $endingtime_on;

                    # 該当する部屋の貸出単位を取得
                    my $rentalunit;
                    foreach my $roominfo_ref (@roominfos) {
                        if ( $roominfo_ref->id == $roominfo_id ) {

                            #終了時刻取得
                            $endingtime_on = $roominfo_ref->endingtime_on;

                            #貸出単位
                            $rentalunit = $roominfo_ref->rentalunit;
                        }
                    }

                    #貸出単位設定で2時間指定されたときの、バリデのためrentalunitも取得
                    # 1が１時間、2が２時間、２が選択されているときだけバリデ
                    #判定の変数
                    my $judg_rentalunit;
                    if ( $rentalunit == 2 ) {
                        my $val = $value - $getstarted_on_time;

                        #偶数
                        if ( $val % 2 == 0 ) {

                            #問題なし
                            $judg_rentalunit = 0;
                        }
                        else {
                            #奇数、バリデートコメントへ
                            $judg_rentalunit = 1;
                        }
                    }

                    #比較するため24-29の数字に変換
                    if ($endingtime_on) {
                        $endingtime_on = substr( $endingtime_on, 0, 2 );
                        $endingtime_on += 0;
                        if ( $endingtime_on =~ /^[0-6]$/ ) {
                            $endingtime_on += 24;
                        }
                    }
                    my $roominfo_ref = $teng->single( 'roominfo', { 'id' => $roominfo_id } );
                    my $room_time_change = $roominfo_ref->time_change;

                    # テンプレートへ送り、
                    $self->stash( room_time_change => $room_time_change );

                    # 翻訳すると、judg_renが１の場合エラー
                    # 入力の開始時間が入力の終了の時間より同じもしくは大きい場合
                    # 営業終了時間が入力終了時間より大きい場合、実行
                    # いずれにも該当しない場合、営業時間外
                    return
                        $judg_rentalunit              ? ( 0, '2時間単位でしか予約できません' )
                      : $getstarted_on_time >= $value ? ( 0, '開始時刻より遅くして下さい' )
                      : $endingtime_on >= $value      ? 1
                      :                                 ( 0, '営業時間外です' );
                }
            );

            # 利用形態名 useform->バンド、個人練習、利用停止、いずれも許可が必要
            $validator->field('useform')->callback(
                sub {
                    my $useform = shift;

                    #判定の変数定義
                    my $judg_privatepermit;
                    my $judg_privateconditions;
                    my $judg_general_id;

                    # useformのバリデート最初にはいってくる値ごとにifで分ける
                    # 0バンドの場合、1個人の場合、2利用停止、の場合
                    if ( $useform == 1 ) {

                        #============================
                        # 必要な情報をそろえる
                        #入力している部屋情報id->roominfo->idを取得する
                        my $roominfo_id = $self->param('roominfo_id');
                        my @roominfos   = $teng->search_named(q{select * from roominfo;});

                        # 個人練習許可設定
                        my $privatepermit;

                        # 個人練習許可条件
                        my $privateconditions;
                        foreach my $roominfo_ref (@roominfos) {
                            if ( $roominfo_ref->id == $roominfo_id ) {
                                $privatepermit     = $roominfo_ref->privatepermit;
                                $privateconditions = $roominfo_ref->privateconditions;
                            }
                        }

                        #============================
                        #個人練習許可が出てない部屋で個人練習->1選択できない
                        #$privatepermit ->0 #許可する #$privatepermit ->1 #許可しない
                        #利用出来る
                        $judg_privatepermit = 0;

                        #$judg_privatepermit = 1;#利用出来ない
                        # 判定
                        if ($privatepermit) { $judg_privatepermit = 1; }

                        #============================
                        #個人練習許可条件に一致してない場合、選択できない
                        #利用できる
                        $judg_privateconditions = 0;

                        #入力している希望日時を取得する、
                        my $getstarted_on_day = $self->param('getstarted_on_day');

                        #今の日付と比較して何日前か計算して出力
                        #入力しているデータを日付のデータに変換
                        $getstarted_on_day = localtime->strptime( $getstarted_on_day, '%Y-%m-%d' );
                        my $today = localtime;

                        #日付を切り出し
                        my $input_date_day = $today->date;

                        #時間を切り出し
                        my $input_date_time = $today->time;
                        $input_date_time = substr( $input_date_time, 0, 2 );
                        $input_date_time += 0;
                        if ( $input_date_time =~ /^[0-5]$/ ) {
                            $input_date_time += 24;

                            #日付を1日もどる
                            $input_date_day = localtime->strptime( $input_date_day, '%Y-%m-%d' );
                            $input_date_day = $input_date_day - ONE_DAY * 1;
                            $input_date_day = $input_date_day->date;
                        }
                        my $input_date = $input_date_day;

                        # 予約指定日を７日さかのぼった数字(日付データ)
                        my @reserve_date_data;
                        $reserve_date_data[0] = $getstarted_on_day;
                        for ( my $i = 1 ; $i < 8 ; ++$i ) {
                            $reserve_date_data[$i] = $getstarted_on_day - ONE_DAY * $i;
                        }

                        #日付データから文字データに変換する
                        my @reserve_date;
                        for ( my $i = 0 ; $i < 8 ; ++$i ) {
                            $reserve_date[$i] = $reserve_date_data[$i]->date;
                        }
                        $reserve_date[8] = $input_date;

                        #利用出来る
                        #my $judg_privateconditions = 0;
                        #利用できない
                        $judg_privateconditions = 1;

                        # 判定
                        for ( my $i = 0 ; $i <= $privateconditions ; ++$i ) {
                            if ( @reserve_date[$i] eq $input_date ) {

                                #利用できる
                                $judg_privateconditions = 0;
                            }
                        }

                    }
                    elsif ( $useform == 2 ) {

                        #============================
                        #一般ユーザーが選択されてる時に利用停止->2が選択されてはいけない
                        #利用出来る
                        $judg_general_id = 0;

                        #利用出来ない
                        #my $judg_general_id = 1;
                        if ( $useform == 2 ) {
                            my $general_id = $self->param('general_id');

                            # 判定
                            if ($general_id) { $judg_general_id = 1; }
                        }
                    }

                    #バンドの場合
                    else {
                        $judg_privatepermit     = 0;
                        $judg_privateconditions = 0;
                        $judg_general_id        = 0;
                    }

                    #============================
                    return
                        ($judg_privatepermit)     ? ( 0, '個人練習が許可されてない' )
                      : ($judg_privateconditions) ? ( 0, 'その指定日では個人練習は利用できません' )
                      : ($judg_general_id)        ? ( 0, '一般ユーザーは利用できない' )
                      :                             1;
                }
            );

            # 伝言板 message->空白でもいいが文字数の制限をする
            $validator->field('message')->required(0)->length( 0, 20 );

            # 一般ユーザー、管理、 general_id　admin_id->どちらかを選択、両方はNG
            #$validator->field('admin_id')->callback(sub {
            #    my $admin_id   = shift;
            #    my $general_id = $self->param('general_id');
            #    #NG 両方が0　 両方が0以外
            #    return   (  $general_id and   $admin_id) ? (0, '両方の選択は不可')
            #           : (! $general_id and ! $admin_id) ? (0, '一般、管理どちらかを選択してください')
            #           :                                    1
            #           ;
            #});

            # 電話番号、 tel->必須、文字制限
            $validator->field('tel')->required(1)->length( 1, 30 );

            #mojoのコマンドでパラメーターをハッシュで取得入力した値をFIllin時に使うため、
            my $param_hash = $self->req->params->to_hash;
            $self->stash( param_hash => $param_hash );

            #入力検査合格、の時、値を新規もしくは修正アップロード実行
            if ( $self->validate( $validator, $param_hash ) ) {

                #ここでいったん入力値を全部受け取っておく 日付データ作成する
                #die "hoge";
                my $today = localtime;

                my $id          = $self->param('id');
                my $roominfo_id = $self->param('roominfo_id');

                #データ加工
                my $getstarted_on_day  = $self->param('getstarted_on_day');
                my $getstarted_on_time = $self->param('getstarted_on_time');
                my $enduse_on_day      = $self->param('enduse_on_day');
                my $enduse_on_time     = $self->param('enduse_on_time');

                #my $getstarted_on     = $self->param('getstarted_on');
                #my $enduse_on         = $self->param('enduse_on');
                my $useform    = $self->param('useform');
                my $message    = $self->param('message');
                my $general_id = $self->param('general_id');

                #my $admin_id           = $self->param('admin_id');
                my $admin_id = $login_id;
                my $tel      = $self->param('tel');

                #my $status             = $self->param('status');
                my $status    = 0;
                my $create_on = $today->datetime( date => '-', T => ' ' );
                my $modify_on = $today->datetime( date => '-', T => ' ' );

                # 一発hボタンを押した時のスクリプト
                $enduse_on_time =
                    ( $h_botton eq "1h" ) ? $getstarted_on_time + 1
                  : ( $h_botton eq "2h" ) ? $getstarted_on_time + 2
                  : ( $h_botton eq "3h" ) ? $getstarted_on_time + 3
                  : ( $h_botton eq "4h" ) ? $getstarted_on_time + 4
                  : ( $h_botton eq "5h" ) ? $getstarted_on_time + 5
                  :                         $enduse_on_time;

                #(分：３０)になっているかチェック値を切替
                my $roominfo_ref = $teng->single( 'roominfo', { 'id' => $roominfo_id } );
                my $time_change = $roominfo_ref->time_change;

                #sql書き込む前に開始、終了時刻変換,日付も考慮
                if ( $getstarted_on_time =~ /^[2][4-9]$/ ) {
                    $getstarted_on_time -= 24;
                    if ($time_change) {
                        $getstarted_on_time .= ":30";
                    }
                    else {
                        $getstarted_on_time .= ":00";
                    }

                    #日付を1日進める
                    $getstarted_on_day = localtime->strptime( $getstarted_on_day, '%Y-%m-%d' );
                    $getstarted_on_day = $getstarted_on_day + ONE_DAY * 1;
                    $getstarted_on_day = $getstarted_on_day->date;
                }
                else {
                    if ($time_change) {
                        $getstarted_on_time .= ":30";
                    }
                    else {
                        $getstarted_on_time .= ":00";
                    }
                }
                if ( $enduse_on_time =~ /^[2][4-9]$|^[3][0]$/ ) {
                    $enduse_on_time -= 24;
                    if ($time_change) {
                        $enduse_on_time .= ":30";
                    }
                    else {
                        $enduse_on_time .= ":00";
                    }

                    #日付を1日進める
                    $enduse_on_day = localtime->strptime( $enduse_on_day, '%Y-%m-%d' );
                    $enduse_on_day = $enduse_on_day + ONE_DAY * 1;
                    $enduse_on_day = $enduse_on_day->date;
                }
                else {
                    if ($time_change) {
                        $enduse_on_time .= ":30";
                    }
                    else {
                        $enduse_on_time .= ":00";
                    }
                }

                #日付、時間データもどし
                my $getstarted_on = $getstarted_on_day . " " . $getstarted_on_time;
                my $enduse_on     = $enduse_on_day . " " . $enduse_on_time;

                #idがある時、修正データの場合sql実行
                if ( $id eq "AUTO_NUMBER" ) {
                    $id = undef;
                }
                if ($id) {

                    #変更前の内容を抽出before_
                    #sqlのデータを抽出する
                    #reserveデータ
                    my $before_reserve_ref = $teng->single( 'reserve', +{ 'id' => $id } );

                    my $before_roominfo_id   = $before_reserve_ref->roominfo_id;
                    my $before_getstarted_on = $before_reserve_ref->getstarted_on;
                    my $before_enduse_on     = $before_reserve_ref->enduse_on;
                    my $before_useform       = $before_reserve_ref->useform;
                    my $before_message       = $before_reserve_ref->message;
                    my $before_general_id    = $before_reserve_ref->general_id;
                    my $before_admin_id      = $before_reserve_ref->admin_id;
                    my $before_tel           = $before_reserve_ref->tel;

                    # $useformを変換
                    $before_useform =
                        ( $before_useform eq '0' ) ? $USEFORM_0
                      : ( $before_useform eq '1' ) ? $USEFORM_1
                      : ( $before_useform eq '2' ) ? $USEFORM_2
                      :                              '該当なし';

                    #roominfoデータ
                    my $before_roominfo_ref = $teng->single( 'roominfo', +{ 'id' => $before_roominfo_id } );

                    #my $before_storeinfo_id    = $before_roominfo_ref->storeinfo_id;
                    my $before_name             = $before_roominfo_ref->name;
                    my $before_pricescomments   = $before_roominfo_ref->pricescomments;
                    my $before_roominfo_remarks = $before_roominfo_ref->remarks;

                    #storeinfoデータ
                    #my $before_storeinfo_ref   = $teng->single('storeinfo', +{'id' => $before_storeinfo_id});
                    #
                    #my $before_storeinfo_name  = $before_storeinfo_ref->name;
                    #my $before_post            = $before_storeinfo_ref->post;
                    #my $before_state           = $before_storeinfo_ref->state;
                    #my $before_cities          = $before_storeinfo_ref->cities;
                    #my $before_addressbelow    = $before_storeinfo_ref->addressbelow;
                    #my $before_storeinfo_tel   = $before_storeinfo_ref->tel;
                    #my $before_storeinfo_mail  = $before_storeinfo_ref->mail;
                    #my $before_remarks         = $before_storeinfo_ref->remarks;
                    #my $before_url             = $before_storeinfo_ref->url;
                    #修正データをsqlへ送り込む
                    my $count = $teng->update(
                        'reserve' => {
                            'roominfo_id'   => $roominfo_id,
                            'getstarted_on' => $getstarted_on,
                            'enduse_on'     => $enduse_on,
                            'useform'       => $useform,
                            'message'       => $message,

                            #'general_id'    => $general_id,
                            'admin_id' => $admin_id,
                            'tel'      => $tel,
                            'status'   => $status,

                            #'create_on'     => $create_on,
                            'modify_on' => $modify_on,
                        },
                        { 'id' => $id, }
                    );
                    $self->flash( henkou => '修正完了' );

                    #sqlのデータを抽出する
                    #reserveデータ
                    my $reserve_ref = $teng->single( 'reserve', +{ 'id' => $id } );

                    my $roominfo_id   = $reserve_ref->roominfo_id;
                    my $getstarted_on = $reserve_ref->getstarted_on;
                    my $enduse_on     = $reserve_ref->enduse_on;
                    my $useform       = $reserve_ref->useform;
                    my $message       = $reserve_ref->message;
                    my $general_id    = $reserve_ref->general_id;
                    my $admin_id      = $reserve_ref->admin_id;
                    my $tel           = $reserve_ref->tel;

                    # $useformを変換
                    $useform =
                        ( $useform eq '0' ) ? $USEFORM_0
                      : ( $useform eq '1' ) ? $USEFORM_1
                      : ( $useform eq '2' ) ? $USEFORM_2
                      :                       '該当なし';

                    #roominfoデータ
                    my $roominfo_ref = $teng->single( 'roominfo', +{ 'id' => $roominfo_id } );

                    my $storeinfo_id     = $roominfo_ref->storeinfo_id;
                    my $name             = $roominfo_ref->name;
                    my $pricescomments   = $roominfo_ref->pricescomments;
                    my $roominfo_remarks = $roominfo_ref->remarks;

                    #storeinfoデータ
                    my $storeinfo_ref = $teng->single( 'storeinfo', +{ 'id' => $storeinfo_id } );

                    my $storeinfo_name = $storeinfo_ref->name;
                    my $post           = $storeinfo_ref->post;
                    my $state          = $storeinfo_ref->state;
                    my $cities         = $storeinfo_ref->cities;
                    my $addressbelow   = $storeinfo_ref->addressbelow;
                    my $storeinfo_tel  = $storeinfo_ref->tel;
                    my $storeinfo_mail = $storeinfo_ref->mail;
                    my $remarks        = $storeinfo_ref->remarks;
                    my $url            = $storeinfo_ref->url;

                    #profileデータ
                    my $general_profile_ref;
                    my $admin_profile_ref;

                    my $general_nick_name;
                    my $general_full_name;
                    my $general_mail;
                    my $general_tel;

                    my $admin_nick_name;
                    my $admin_full_name;
                    my $admin_mail;
                    my $admin_tel;

                    if ($general_id) {
                        $general_profile_ref = $teng->single( 'profile', +{ 'general_id' => $general_id } );

                        $general_nick_name = $general_profile_ref->nick_name;
                        $general_full_name = $general_profile_ref->full_name;
                        $general_mail      = $general_profile_ref->mail;
                        $general_tel       = $general_profile_ref->tel;

                    }
                    $admin_profile_ref = $teng->single( 'profile', +{ 'admin_id' => $admin_id } );

                    $admin_nick_name = $admin_profile_ref->nick_name;
                    $admin_full_name = $admin_profile_ref->full_name;
                    $admin_mail      = $admin_profile_ref->mail;
                    $admin_tel       = $admin_profile_ref->tel;

                    #mailbox用のステータス
                    my $mailbox_type_mail = 5;
                    my $mailbox_status    = 0;

                    #メール送信の為のデータを保存する=========
                    my $row = $teng->insert(
                        'mailbox' => {

                            #'id'                               =>,
                            'storeinfo_name'                 => $storeinfo_name,
                            'storeinfo_post'                 => $post,
                            'storeinfo_state'                => $state,
                            'storeinfo_cities'               => $cities,
                            'storeinfo_addressbelow'         => $addressbelow,
                            'storeinfo_tel'                  => $storeinfo_tel,
                            'storeinfo_mail'                 => $storeinfo_mail,
                            'storeinfo_url'                  => $url,
                            'storeinfo_remarks'              => $remarks,
                            'roominfo_name'                  => $name,
                            'reserve_getstarted_on'          => $getstarted_on,
                            'reserve_enduse_on'              => $enduse_on,
                            'reserve_useform'                => $useform,
                            'roominfo_pricescomments'        => $pricescomments,
                            'roominfo_remarks'               => $roominfo_remarks,
                            'reserve_message'                => $message,
                            'admin_nick_name'                => $admin_nick_name,
                            'admin_full_name'                => $admin_full_name,
                            'admin_tel'                      => $admin_tel,
                            'admin_mail'                     => $admin_mail,
                            'general_nick_name'              => $general_nick_name,
                            'general_full_name'              => $general_full_name,
                            'general_tel'                    => $general_tel,
                            'general_mail'                   => $general_mail,
                            'before_roominfo_name'           => $before_name,
                            'before_reserve_getstarted_on'   => $before_getstarted_on,
                            'before_reserve_enduse_on'       => $before_enduse_on,
                            'before_reserve_useform'         => $before_useform,
                            'before_roominfo_pricescomments' => $before_pricescomments,
                            'before_roominfo_remarks'        => $before_roominfo_remarks,
                            'before_reserve_message'         => $before_message,
                            'type_mail'                      => $mailbox_type_mail,
                            'status'                         => $mailbox_status,
                            'create_on'                      => $create_on,

                            #'modify_on'                        =>,
                        }
                    );

                    # my $reserve_subject  = '[yoyakku]管理者予約変更のお知らせ【'.$today->datetime(date => '-', T => ' ').'】';
                    # my $reserve_messages = <<EOD;
                    # 管理者　$admin_nick_name　様

                    # 一般ユーザー　$general_nick_name　様

                    # この度は、yoyakkuをご利用頂き、誠にありがとうございます。

                    # 管理者により予約の変更が行われました。

                    # ご予約変更は下記の通りとなります
                    #変更後予約==========
                    #
                    #ご予約店舗情報----------
                    #【店舗名】$storeinfo_name
                    #【住所】　$post
                    #　　　　　$state $cities
                    #　　　　　$addressbelow
                    #【電話】　$storeinfo_tel
                    #【メール】$storeinfo_mail
                    #【ＵＲＬ】$url
                    #【備考】　$remarks
                    #
                    #ご予約内容----------
                    #【部屋】$name
                    #【開始】$getstarted_on
                    #【終了】$enduse_on
                    #【利用】$useform
                    #【料金】$pricescomments
                    #【伝言】$message
                    #
                    #予約者情報【管理者】----------
                    #【予約名】$admin_nick_name
                    #【氏名】$admin_full_name
                    #【電話】$admin_tel
                    #【メール】$admin_mail
                    #
                    #予約者情報【一般ユーザー】----------
                    #【予約名】$general_nick_name
                    #【氏名】$general_full_name
                    #【電話】$general_tel
                    #【メール】$general_mail
                    #
                    #
                    #
                    #変更前予約==========
                    #
                    #
                    #ご予約内容----------
                    #【部屋】$before_name
                    #【開始】$before_getstarted_on
                    #【終了】$before_enduse_on
                    #【利用】$before_useform
                    #【料金】$before_pricescomments
                    #【伝言】$before_message
                    #
                    #EOD
                    #            my $utf8 = find_encoding('utf8');
                    #            # メール作成
                    #            my $subject = $utf8->encode($reserve_subject);
                    #            my $body    = $utf8->encode($reserve_messages . $footer_message);
                    #
                    #            use Email::MIME;
                    #            my $email = Email::MIME->create(
                    #                header => [
                    #                    From    => 'yoyakku@gmail.com', # 送信元
                    #                    To      => $storeinfo_mail,    # 送信先
                    #                    To      => $general_mail,    # 送信先
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
                else {
                    #idが無い場合、新規登録sql実行 新規登録データをsqlへ送り込む
                    my $row = $teng->insert(
                        'reserve' => {

                            #'id'            => $id,
                            'roominfo_id'   => $roominfo_id,
                            'getstarted_on' => $getstarted_on,
                            'enduse_on'     => $enduse_on,
                            'useform'       => $useform,
                            'message'       => $message,
                            'general_id'    => $general_id,
                            'admin_id'      => $admin_id,
                            'tel'           => $tel,
                            'status'        => $status,
                            'create_on'     => $create_on,

                            #'modify_on'     => $modify_on,
                        }
                    );
                    $self->flash( touroku => '登録完了' );

                    #sqlのデータを抽出する
                    #reserveデータ
                    my $reserve_ref = $teng->single(
                        'reserve',
                        +{
                            'admin_id'  => $admin_id,
                            'create_on' => $create_on
                        }
                    );

                    my $roominfo_id   = $reserve_ref->roominfo_id;
                    my $getstarted_on = $reserve_ref->getstarted_on;
                    my $enduse_on     = $reserve_ref->enduse_on;
                    my $useform       = $reserve_ref->useform;
                    my $message       = $reserve_ref->message;
                    my $general_id    = $reserve_ref->general_id;
                    my $tel           = $reserve_ref->tel;

                    # $useformを変換
                    $useform =
                        ( $useform eq '0' ) ? $USEFORM_0
                      : ( $useform eq '1' ) ? $USEFORM_1
                      : ( $useform eq '2' ) ? $USEFORM_2
                      :                       '該当なし';

                    #roominfoデータ
                    my $roominfo_ref = $teng->single( 'roominfo', +{ 'id' => $roominfo_id } );

                    my $storeinfo_id     = $roominfo_ref->storeinfo_id;
                    my $name             = $roominfo_ref->name;
                    my $pricescomments   = $roominfo_ref->pricescomments;
                    my $roominfo_remarks = $roominfo_ref->remarks;

                    #storeinfoデータ
                    my $storeinfo_ref = $teng->single( 'storeinfo', +{ 'id' => $storeinfo_id } );

                    my $storeinfo_name = $storeinfo_ref->name;
                    my $post           = $storeinfo_ref->post;
                    my $state          = $storeinfo_ref->state;
                    my $cities         = $storeinfo_ref->cities;
                    my $addressbelow   = $storeinfo_ref->addressbelow;
                    my $storeinfo_tel  = $storeinfo_ref->tel;
                    my $storeinfo_mail = $storeinfo_ref->mail;
                    my $remarks        = $storeinfo_ref->remarks;
                    my $url            = $storeinfo_ref->url;

                    #profileデータ
                    my $general_profile_ref;
                    my $admin_profile_ref;

                    my $general_nick_name;
                    my $general_full_name;
                    my $general_mail;
                    my $general_tel;

                    my $admin_nick_name;
                    my $admin_full_name;
                    my $admin_mail;
                    my $admin_tel;

                    if ($general_id) {
                        $general_profile_ref = $teng->single( 'profile', +{ 'general_id' => $general_id } );

                        $general_nick_name = $general_profile_ref->nick_name;
                        $general_full_name = $general_profile_ref->full_name;
                        $general_mail      = $general_profile_ref->mail;
                        $general_tel       = $general_profile_ref->tel;

                    }
                    $admin_profile_ref = $teng->single( 'profile', +{ 'admin_id' => $admin_id } );

                    $admin_nick_name = $admin_profile_ref->nick_name;
                    $admin_full_name = $admin_profile_ref->full_name;
                    $admin_mail      = $admin_profile_ref->mail;
                    $admin_tel       = $admin_profile_ref->tel;

                    #mailbox用のステータス
                    my $mailbox_type_mail = 3;
                    my $mailbox_status    = 0;

                    #メール送信の為のデータを保存する=========
                    my $row = $teng->insert(
                        'mailbox' => {

                            #'id'                               =>,
                            'storeinfo_name'          => $storeinfo_name,
                            'storeinfo_post'          => $post,
                            'storeinfo_state'         => $state,
                            'storeinfo_cities'        => $cities,
                            'storeinfo_addressbelow'  => $addressbelow,
                            'storeinfo_tel'           => $storeinfo_tel,
                            'storeinfo_mail'          => $storeinfo_mail,
                            'storeinfo_url'           => $url,
                            'storeinfo_remarks'       => $remarks,
                            'roominfo_name'           => $name,
                            'reserve_getstarted_on'   => $getstarted_on,
                            'reserve_enduse_on'       => $enduse_on,
                            'reserve_useform'         => $useform,
                            'roominfo_pricescomments' => $pricescomments,
                            'roominfo_remarks'        => $roominfo_remarks,
                            'reserve_message'         => $message,
                            'admin_nick_name'         => $admin_nick_name,
                            'admin_full_name'         => $admin_full_name,
                            'admin_tel'               => $admin_tel,
                            'admin_mail'              => $admin_mail,
                            'general_nick_name'       => $general_nick_name,
                            'general_full_name'       => $general_full_name,
                            'general_tel'             => $general_tel,
                            'general_mail'            => $general_mail,

                            #'before_roominfo_name'             =>$before_name,
                            #'before_reserve_getstarted_on'     =>$before_getstarted_on,
                            #'before_reserve_enduse_on'         =>$before_enduse_on,
                            #'before_reserve_useform'           =>$before_useform,
                            #'before_roominfo_pricescomments'   =>$before_pricescomments,
                            #'before_roominfo_remarks'          =>$before_roominfo_remarks,
                            #'before_reserve_message'           =>$before_message,
                            'type_mail' => $mailbox_type_mail,
                            'status'    => $mailbox_status,
                            'create_on' => $create_on,

                            #'modify_on'                        =>,
                        }
                    );

                    #my $reserve_subject  = '[yoyakku]管理者予約完了のお知らせ【'.$today->datetime(date => '-', T => ' ').'】';
                    #my $reserve_messages = <<EOD;
                    #管理者　$admin_nick_name　様
                    #
                    #一般ユーザー　$general_nick_name　様
                    #
                    #この度は、yoyakkuをご利用頂き、誠にありがとうございます。
                    #
                    #管理者により予約の確定が行われました。
                    #
                    #ご予約内容は下記の通りとなります
                    #
                    #ご予約店舗情報----------
                    #【店舗名】$storeinfo_name
                    #【住所】　$post
                    #　　　　　$state $cities
                    #　　　　　$addressbelow
                    #【電話】　$storeinfo_tel
                    #【メール】$storeinfo_mail
                    #【ＵＲＬ】$url
                    #【備考】　$remarks
                    #
                    #ご予約内容----------
                    #【部屋】$name
                    #【開始】$getstarted_on
                    #【終了】$enduse_on
                    #【利用】$useform
                    #【料金】$pricescomments
                    #【伝言】$message
                    #
                    #予約者情報【管理者】----------
                    #【予約名】$admin_nick_name
                    #【氏名】$admin_full_name
                    #【電話】$admin_tel
                    #【メール】$admin_mail
                    #
                    #予約者情報【一般ユーザー】----------
                    #【予約名】$general_nick_name
                    #【氏名】$general_full_name
                    #【電話】$general_tel
                    #【メール】$general_mail
                    #
                    #EOD
                    #            my $utf8 = find_encoding('utf8');
                    #            # メール作成
                    #            my $subject = $utf8->encode($reserve_subject);
                    #            my $body    = $utf8->encode($reserve_messages . $footer_message);
                    #
                    #            use Email::MIME;
                    #            my $email = Email::MIME->create(
                    #                header => [
                    #                    From    => 'yoyakku@gmail.com', # 送信元
                    #                    To      => $storeinfo_mail,    # 送信先
                    #                    To      => $general_mail,    # 送信先
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

                #sqlにデータ入力したのでlist画面にリダイレクト
                return $self->redirect_to('admin_reserv_list');

                #リターンなのでここでおしまい。
            }

            #入力検査合格しなかった場合、もう一度入力フォーム表示Fillinにて
            my $html = $self->render_partial()->to_string;
            $html = HTML::FillInForm->fill( \$html, $self->req->params, );
            return $self->render_text( $html, format => 'html' );

            #リターンなのでここでおしまい。
        }

    }

    # ================================================
    # 新規予約をクリックすると必要な情報を表示するスクリプト
    # 新規予約の所に、roomidを埋め込んでおく、
    # 表示したい情報
    # メモを入れる枠がいる、電話予約を代理予約するときの覚え書き
    # テンプレートからgetのnew_reserv_idをキャッチする
    my $new_res_room_id = $self->param('new_res_room_id');

    # 受け取る値はroomidを受け取る
    # idキャッチしたときのみ、下記のフィルインを実行
    my $room_time_change;
    if ($new_res_room_id) {

        #変数定義
        my ( $id, $roominfo_id, $getstarted_on, $enduse_on, $useform, $message, $general_id, $admin_id, $tel, $status, $create_on, $modify_on, );

        # 部屋の名前を出力するスクリプト,# (分)切替の情報を送る
        my $room_name;
        if ($new_res_room_id) {
            my @rows = $teng->single( 'roominfo', { 'id' => $new_res_room_id } );
            foreach my $row (@rows) {
                $room_name        = $row->name;
                $room_time_change = $row->time_change;
            }
        }

        # テンプレートへ送り、
        $self->stash( room_time_change => $room_time_change );

        # 部屋idを出力
        my $roominfo_id = $new_res_room_id;

        # 開示日付を出力するスクリプト
        my $select_time        = $self->param('select_time');
        my $getstarted_on_day  = $select_date->date;
        my $getstarted_on_time = $select_time;

        # 終了日付を出力するスクリプト
        my $enduse_on_day  = $select_date->date;
        my $enduse_on_time = $select_time + 1;

        # 予約者を出力するスクリプト
        #my $subscriber = $login;
        my $profile_ref = $teng->single( 'profile', { 'admin_id' => $login_id } );
        my $subscriber = $profile_ref->nick_name;

        # 電話番号を出力するスクリプト
        my $tel;
        if ($new_res_room_id) {
            my @rows = $teng->single( 'storeinfo', { 'admin_id' => $login_id } );
            foreach my $row (@rows) {
                $tel = $row->tel;
            }
        }
        my $html = $self->render_partial()->to_string;
        $html = HTML::FillInForm->fill(
            \$html,
            {
                #select_date        => "2013-04-17" ,
                #id                 => $id ,
                roominfo_id        => $roominfo_id,
                room_name          => $room_name,
                room_time_change   => $room_time_change,
                getstarted_on_day  => $getstarted_on_day,    #データ加工
                getstarted_on_time => $getstarted_on_time,
                enduse_on_day      => $enduse_on_day,
                enduse_on_time     => $enduse_on_time,

                #getstarted_on     => $getstarted_on,
                #enduse_on         => $enduse_on,
                #useform            => $useform,
                #message            => $message,
                #general_id         => $general_id,
                #admin_id           => $admin_id,
                subscriber => $subscriber,
                tel        => $tel,

                #status             => $status,
                #create_on          => $create_on,
                #modify_on          => $modify_on
            },
        );

        #Fillin画面表示実行returnなのでここでおしまい。
        return $self->render_text( $html, format => 'html' );
    }

    # ================================================
    # 予約済みの所をクリックすると詳細がでるスクリプト
    # 予約済み表示の所に、予約idを埋め込んでおく、
    # 予約済みの所をクリックすると、submitし、予約idをつかって
    # テンプレートに送り込む
    my $reserve_id = $self->param('reserve_id');

    # sqlにアクセスし、該当の予約情報を抽出し、データを
    # fillinフォームで送り込む準備する
    if ($reserve_id) {

        # id検索、sql実行
        #die "test";
        #変数定義
        my ( $id, $roominfo_id, $getstarted_on, $enduse_on, $useform, $message, $general_id, $admin_id, $tel, $status, $create_on, $modify_on, );

        my @rows = $teng->single( 'reserve', { 'id' => $reserve_id } );
        foreach my $row (@rows) {
            $id            = $row->id;
            $roominfo_id   = $row->roominfo_id;
            $getstarted_on = $row->getstarted_on;
            $enduse_on     = $row->enduse_on;
            $useform       = $row->useform;
            $message       = $row->message;
            $general_id    = $row->general_id;
            $admin_id      = $row->admin_id;
            $tel           = $row->tel;
            $status        = $row->status;
            $create_on     = $row->create_on;
            $modify_on     = $row->modify_on;
        }

        # 部屋の名前を出力するスクリプト(分も始まりも)
        my $room_name;
        if ($id) {
            my @rows = $teng->single( 'roominfo', { 'id' => $roominfo_id } );
            foreach my $row (@rows) {
                $room_name        = $row->name;
                $room_time_change = $row->time_change;
            }
        }

        # テンプレートへ送り、
        $self->stash( room_time_change => $room_time_change );

        # 予約者のログイン名(ニックネーム)を表示する為のスクリプト
        my $subscriber;
        if ($admin_id) {
            my $profile_ref = $teng->single( 'profile', { 'admin_id' => $admin_id } );
            $subscriber = $profile_ref->nick_name;
        }
        else {
            my $profile_ref = $teng->single( 'profile', { 'general_id' => $general_id } );
            $subscriber = $profile_ref->nick_name;
        }

        #fillinで送る前にデータを加工する#日付と30時間表記に分解,日付も考慮
        #$getstarted_on
        #日付を切り出し
        my $getstarted_on_day;

        #時間を切り出し
        my $getstarted_on_time;
        if ($getstarted_on) {
            $getstarted_on_day  = substr( $getstarted_on, 0,  10 );
            $getstarted_on_time = substr( $getstarted_on, 11, 2 );
            $getstarted_on_time += 0;
            if ( $getstarted_on_time =~ /^[0-5]$/ ) {
                $getstarted_on_time += 24;

                #日付を1日もどる
                $getstarted_on_day = localtime->strptime( $getstarted_on_day, '%Y-%m-%d' );
                $getstarted_on_day = $getstarted_on_day - ONE_DAY * 1;
                $getstarted_on_day = $getstarted_on_day->date;
            }
        }

        #$enduse_on
        #日付を切り出し
        my $enduse_on_day;

        #時間を切り出し
        my $enduse_on_time;
        if ($enduse_on) {
            $enduse_on_day  = substr( $enduse_on, 0,  10 );
            $enduse_on_time = substr( $enduse_on, 11, 2 );
            $enduse_on_time += 0;
            if ( $enduse_on_time =~ /^[0-6]$/ ) {
                $enduse_on_time += 24;

                #日付を1日もどる
                $enduse_on_day = localtime->strptime( $enduse_on_day, '%Y-%m-%d' );
                $enduse_on_day = $enduse_on_day - ONE_DAY * 1;
                $enduse_on_day = $enduse_on_day->date;
            }
        }

        #$select_date = $select_date->date;

        #修正用フォーム、Fillinつかって表示
        #値はsqlより該当idのデータをつかう
        my $html = $self->render_partial()->to_string;
        $html = HTML::FillInForm->fill(
            \$html,
            {
                #select_date        => "2013-04-17" ,
                id                 => $id,
                roominfo_id        => $roominfo_id,
                room_name          => $room_name,
                getstarted_on_day  => $getstarted_on_day,    #データ加工
                getstarted_on_time => $getstarted_on_time,
                enduse_on_day      => $enduse_on_day,
                enduse_on_time     => $enduse_on_time,

                #getstarted_on     => $getstarted_on,
                #enduse_on         => $enduse_on,
                useform => $useform,
                message => $message,

                #general_id         => $general_id,
                #admin_id           => $admin_id,
                subscriber => $subscriber,
                tel        => $tel,

                #status             => $status,
                #create_on          => $create_on,
                #modify_on          => $modify_on
            },
        );

        #Fillin画面表示実行returnなのでここでおしまい。
        return $self->render_text( $html, format => 'html' );
    }

    # ================================================
    $self->render('admin_reserv_list');
};

