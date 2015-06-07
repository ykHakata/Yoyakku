package Yoyakku::Controller::Mainte::Reserve;
use Mojo::Base 'Mojolicious::Controller';
# use FormValidator::Lite;
# use HTML::FillInForm;
use Yoyakku::Controller::Mainte qw{check_login_mainte switch_stash};
use Yoyakku::Model::Mainte::Reserve qw{
    search_reserve_id_rows
};

# 予約情報 一覧 検索
sub mainte_reserve_serch {
    my $self = shift;

    # ログイン確認する
    return $self->redirect_to('/index') if $self->check_login_mainte();

     # テンプレートbodyのクラス名を定義
    my $class = 'mainte_reserve_serch';
    $self->stash( class => $class );

    # id検索時のアクション (該当の店舗を検索)
    my $reserve_id = $self->param('reserve_id');

    # id 検索時は指定のid検索して出力
    my $reserve_rows = $self->search_reserve_id_rows($reserve_id);

    $self->stash( reserve_rows => $reserve_rows );

    return $self->render(
        template => 'mainte/mainte_reserve_serch',
        format   => 'html',
    );
}

1;


# # mainte_reserve_new.html.ep
# #予約履歴の新規作成、修正、sql入力コントロール-----------------------------
# any '/mainte_reserve_new' => sub {
# my $self = shift;
# my $class = "mainte_reserve_new"; # テンプレートbodyのクラス名を定義
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
# #===
# # 30毎の予約をするめための切り替え
# my $time_change = 1;
# $self->stash(time_change => $time_change);


# #===
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

# #部屋情報設定を取得する(入力につかう)->利用開始のみ抽出
# my @roominfos = $teng->search_named(q{select * from roominfo;});
# $self->stash(roominfos_ref => \@roominfos);

# #店舗情報を取得する(入力につかう)
# my @storeinfos = $teng->search_named(q{select * from storeinfo;});
# $self->stash(storeinfos_ref => \@storeinfos);

# #一般ユーザー情報を取得する(入力につかう)
# my @generals = $teng->search_named(q{select * from general;});
# $self->stash(generals_ref => \@generals);

# #管理ユーザー情報を取得する(入力につかう)
# my @admins = $teng->search_named(q{select * from admin;});
# $self->stash(admins_ref => \@admins);

# #書いてないけど、新規作成一発目はテンプレートの入力フォームレンダリング
# #---------
# #post判定する
# if (uc $self->req->method eq 'POST') {
#     #新規入力も修正もボタン押すとpostで入ってくる、両方バリデード実行
#     # バリデーション()
#     my $validator = $self->create_validator;
#     #バリデーションが複雑になってきたのでもう一度順番に整理する
#     #予約のダブり確認のバリデ
#     $validator->field('id')->callback(sub {
#         my $value = shift;

#         my $judg_reserve_id = 0;#予約既にあり
#         my $judg_reserve_id = 1;#問題なし


#     # 予約のダブりが存在を確認するスクリプトをもう一度考えてみる
#     #入力した値を取得する=======================================================
#     # 入力した値を取得する(予約id,部屋情報id,利用開始時刻,利用終了時刻)
#     my $id                 = $self->param('id');
#     my $roominfo_id        = $self->param('roominfo_id');
#     my $kibou_date         = $self->param('getstarted_on_day');#入力した予約の希望日付
#     my $kibou_start        = $self->param('getstarted_on_time');
#     my $enduse_on_day      = $self->param('enduse_on_day');
#     my $kibou_end          = $self->param('enduse_on_time');

#     #既に入力済みのデータをsqlから取り出す========================================
#     # 予約履歴を抽出する
#     my @reserves = $teng->search_named(q{select * from reserve;});

#     #比較したいデータのみを選別する===============================================
#         # 比較したいデータとは、入力した部屋id(roominfo_id)と同じもの
#         # 入力した予約id(id)は比較対象外にする
#     foreach my $reserve_ref (@reserves) {# 予約データを一件づつすべて引き出す
#         if ($reserve_ref->roominfo_id == $roominfo_id) { #入力したroominfo_idと同じデータのみ
#             if ($reserve_ref->id ne $id ) { #入力した予約id以外のもの
#                 #比較できるよう値を変換
#                 #データの利用開始と利用終了のデータを取り出し
#                 #利用開始日時取り出し
#                 my $getstarted_on = $reserve_ref->getstarted_on;
#                 #日付と時刻に分ける(ただしまだ通常の0-5時の形式)
#                 my $getstarted_on_day   = substr($getstarted_on,0,10);#日付
#                 my $getstarted_on_time  = substr($getstarted_on,11,2);#時刻
#                 $getstarted_on_time    += 0;#念のために時刻を数字の型にして、最初の0があれば表示しない
#                 #時刻0-5時の場合は24-29に変換、
#                 if ($getstarted_on_time =~ /^[0-5]$/) {
#                     $getstarted_on_time += 24;
#                     #日付を1日もどる
#                     $getstarted_on_day = localtime->strptime($getstarted_on_day,'%Y-%m-%d');
#                     $getstarted_on_day = $getstarted_on_day - ONE_DAY * 1;
#                     $getstarted_on_day = $getstarted_on_day->date;
#                 }
#                 #利用終了日時取り出し
#                 my $enduse_on = $reserve_ref->enduse_on;
#                 #日付と時刻に分ける(ただしまだ通常の0-6時の形式)
#                 my $enduse_on_day   = substr($enduse_on,0,10);#日付
#                 my $enduse_on_time  = substr($enduse_on,11,2);#時刻
#                 $enduse_on_time += 0;#念のために時刻を数字の型にして、最初の0があれば表示しない
#                 #時刻0-6時の場合は24-30に変換、
#                 if ($enduse_on_time =~ /^[0-6]$/) {
#                     $enduse_on_time += 24;
#                     #日付を1日もどる
#                     $enduse_on_day = localtime->strptime($enduse_on_day,'%Y-%m-%d');
#                     $enduse_on_day = $enduse_on_day - ONE_DAY * 1;
#                     $enduse_on_day = $enduse_on_day->date;
#                 }

#                 #開始時刻から終了時刻一つ前まで、比較してゆく、一致すればdie!ダブり！
#                 #入力した日付とデータの日付が一致した時比較開始
#                 if ($getstarted_on_day eq $kibou_date) {
#                     #今見ているデータの時間軸をだす
#                     #比較の計算式を書き直し
#                 my $i = $getstarted_on_time;
#                 for ($i; $i < $enduse_on_time; ++$i) {#sqlのデータ
#                     #開始から終了一つ前まで１つづつ取り出し
#                     my $ii = $kibou_start;
#                     for ($ii; $ii < $kibou_end; ++$ii) {#入力データ
#                         if ($i == $ii) {$judg_reserve_id = 0;}
#                     }
#                 }
#                 }
#             }
#         }
#     }


# #    #おしまし





#         return 1 if $judg_reserve_id ;

#         return (0, '既に予約が存在します');
#     });


#     # 利用開始日時 getstarted_on->日付と時間
#     #日付の書式のバリデ
#     $validator->field('getstarted_on_day')->required(1)->constraint('date', split => '-');
#     # 抽出した部屋情報の開始時刻より遅く、終了時間より早い事
#     $validator->field('getstarted_on_time')->callback(sub {
#         my $value = shift;

#         # 部屋の利用開始と終了時刻の範囲内かを調べるバリデ
#         # 指定したスタジオ、部屋情報idを取得
#         my $roominfo_id = $self->param('roominfo_id');
#         my $starttime_on; # 該当する部屋の開始時刻と終了時刻を取得
#         my @roominfos = $teng->search_named(q{select * from roominfo;});
#         foreach my $roominfo_ref (@roominfos) {
#             if ($roominfo_ref->id == $roominfo_id) {
#                 $starttime_on  = $roominfo_ref->starttime_on;#開始時刻取得
#             }
#         }
#         #比較するため24-29の数字に変換
#         if ($starttime_on) {
#             $starttime_on  = substr($starttime_on,0,2);
#             $starttime_on += 0;
#             if ($starttime_on =~ /^[0-5]$/) {
#                 $starttime_on += 24;
#             }
#         }

#         return 1 if $starttime_on <= $value;

#         return (0, '営業時間外です');
#     });


#     # 利用終了日時 enduse_on->日付と時間
#     # 日付の書式バリデ、開始、終了同じ日付にさせる
#     $validator->field('enduse_on_day')->required(1)->
#         constraint('date', split => '-')->callback(sub {
#         my $value = shift;
#         my $getstarted_on_day = $self->param('getstarted_on_day');

#         return 1 if $getstarted_on_day eq $value ;

#         return (0, '開始と同じ日付にして下さい') ;
#     });

#     $validator->field('enduse_on_time')->callback(sub {
#         my $value = shift; #開始より終了が早い場合
#         my $getstarted_on_time = $self->param('getstarted_on_time');

#         my @roominfos = $teng->search_named(q{select * from roominfo;});
#         # 指定したスタジオ、部屋情報idを取得
#         my $roominfo_id = $self->param('roominfo_id');
#         my $endingtime_on;# 該当する部屋の終了時刻を取得
#         my $rentalunit;# 該当する部屋の貸出単位を取得
#         foreach my $roominfo_ref (@roominfos) {
#             if ($roominfo_ref->id == $roominfo_id) {
#                 $endingtime_on = $roominfo_ref->endingtime_on;#終了時刻取得
#                 $rentalunit    = $roominfo_ref->rentalunit;#貸出単位
#             }
#         }
#         #貸出単位設定で2時間指定されたときの、バリデのためrentalunitも取得
#         # 1が１時間、2が２時間、２が選択されているときだけバリデ
#         #判定の変数
#         my $judg_rentalunit;
#         if ($rentalunit == 2) {
#             my $val = $value - $getstarted_on_time ;
#             if ($val % 2 == 0) { #偶数
#                 $judg_rentalunit = 0 ;#問題なし
#             }
#             else {
#                 $judg_rentalunit = 1 ;#奇数、バリデートコメントへ
#             }
#         }
#         #比較するため24-29の数字に変換
#         if ($endingtime_on) {
#             $endingtime_on   = substr($endingtime_on,0,2);
#             $endingtime_on += 0;
#             if ($endingtime_on =~ /^[0-6]$/) {
#                 $endingtime_on += 24;
#             }
#         }

#         return (0, '2時間単位でしか予約できません') if $judg_rentalunit ;

#         return (0, '開始時刻より遅くして下さい') if $getstarted_on_time >= $value ;

#         return 1 if $endingtime_on >= $value ;

#         return (0, '営業時間外です');
#     });

#     # 利用形態名 useform->バンド、個人練習、利用停止、いずれも許可が必要
#     $validator->field('useform')->callback(sub {
#         my $useform   = shift;

#         #判定の変数定義
#         my $judg_privatepermit;
#         my $judg_privateconditions;
#         my $judg_general_id;


#         # useformのバリデート最初にはいってくる値ごとにifで分ける
#         # 0バンドの場合、1個人の場合、2利用停止、の場合
#         if ($useform == 1) {
#             #============================
#             # 必要な情報をそろえる
#             #入力している部屋情報id->roominfo->idを取得する
#             my $roominfo_id = $self->param('roominfo_id');
#             my @roominfos = $teng->search_named(q{select * from roominfo;});
#             my $privatepermit;# 個人練習許可設定
#             my $privateconditions; # 個人練習許可条件
#             foreach my $roominfo_ref (@roominfos) {
#                 if ($roominfo_ref->id == $roominfo_id) {
#                     $privatepermit     = $roominfo_ref->privatepermit;
#                     $privateconditions = $roominfo_ref->privateconditions;
#                 }
#             }
#             #============================
#             #個人練習許可が出てない部屋で個人練習->1選択できない
#             #$privatepermit ->0 #許可する #$privatepermit ->1 #許可しない
#             $judg_privatepermit = 0;#利用出来る
#             #$judg_privatepermit = 1;#利用出来ない
#             # 判定
#             if ($privatepermit) {$judg_privatepermit = 1;}
#             #============================
#             #個人練習許可条件に一致してない場合、選択できない
#             $judg_privateconditions = 0;#利用できる
#             #入力している希望日時を取得する、
#             my $getstarted_on_day = $self->param('getstarted_on_day');
#             #今の日付と比較して何日前か計算して出力
#             #入力しているデータを日付のデータに変換
#             $getstarted_on_day = localtime->strptime($getstarted_on_day,'%Y-%m-%d');
#             my $today = localtime;

#             my $input_date_day = $today->date;#日付を切り出し
#             my $input_date_time = $today->time;#時間を切り出し
#             $input_date_time  = substr($input_date_time,0,2);
#             $input_date_time += 0;
#             if ($input_date_time =~ /^[0-5]$/) {
#             $input_date_time += 24;
#             #日付を1日もどる
#             $input_date_day = localtime->strptime($input_date_day,'%Y-%m-%d');
#             $input_date_day = $input_date_day - ONE_DAY * 1;
#             $input_date_day = $input_date_day->date;
#         }
#             my $input_date = $input_date_day;

#             my @reserve_date_data;# 予約指定日を７日さかのぼった数字(日付データ)
#             $reserve_date_data[0] = $getstarted_on_day;
#             for (my $i=1;$i < 8;++$i) {
#             $reserve_date_data[$i] = $getstarted_on_day - ONE_DAY * $i ;
#         }
#             #日付データから文字データに変換する
#             my @reserve_date;
#             for (my $i=0;$i < 8;++$i) {
#             $reserve_date[$i] = $reserve_date_data[$i]->date;
#         }
#             $reserve_date[8] = $input_date;
#             #my $judg_privateconditions = 0;#利用出来る
#             $judg_privateconditions = 1;#利用できない
#             # 判定
#                 for (my $i=0;$i <= $privateconditions;++$i) {
#                 if (@reserve_date[$i] eq $input_date) {
#                     $judg_privateconditions = 0;#利用できる
#                 }
#             }

#         }
#         elsif ($useform == 2) {
#             #============================
#             #一般ユーザーが選択されてる時に利用停止->2が選択されてはいけない
#             $judg_general_id = 0;#利用出来る
#             #my $judg_general_id = 1;#利用出来ない
#             if ($useform == 2) {
#                 my $general_id = $self->param('general_id');
#                 # 判定
#                 if ($general_id) {$judg_general_id = 1;}
#             }
#         }
#         #バンドの場合
#         else {
#             $judg_privatepermit = 0;
#             $judg_privateconditions = 0;
#             $judg_general_id = 0;
#         }
#         #============================
#         return   ($judg_privatepermit     ) ? (0, '個人練習が許可されてない'              )
#                : ($judg_privateconditions ) ? (0, 'その指定日では個人練習は利用できません')
#                : ($judg_general_id        ) ? (0, '一般ユーザーは利用できない'            )
#                :                               1
#                ;
#     });
#     # 伝言板 message->空白でもいいが文字数の制限をする
#     $validator->field('message')->required(0)->length(0,20);
#     # 一般ユーザー、管理、 general_id　admin_id->どちらかを選択、両方はNG
#     $validator->field('admin_id')->callback(sub {
#         my $admin_id   = shift;
#         my $general_id = $self->param('general_id');
#         #NG 両方が0　 両方が0以外
#         return   (  $general_id and   $admin_id) ? (0, '両方の選択は不可')
#                : (! $general_id and ! $admin_id) ? (0, '一般、管理どちらかを選択してください')
#                :                                    1
#                ;
#     });
#     # 電話番号、 tel->必須、文字制限
#     $validator->field('tel')->required(1)->length(1,30);

#     # 利用開始時間のバリデートについてもう少し考えてみる

#     #mojoのコマンドでパラメーターをハッシュで取得入力した値をFIllin時に使うため、
#     my $param_hash = $self->req->params->to_hash;
#     $self->stash(param_hash => $param_hash);
#     #入力検査合格、の時、値を新規もしくは修正アップロード実行
#     if ( $self->validate($validator,$param_hash) ) {
#         #ここでいったん入力値を全部受け取っておく 日付データ作成する
#         my $today = localtime;

#         my $id                 = $self->param('id');
#         my $roominfo_id        = $self->param('roominfo_id');
#         my $getstarted_on_day  = $self->param('getstarted_on_day');#データ加工
#         my $getstarted_on_time = $self->param('getstarted_on_time');
#         my $enduse_on_day      = $self->param('enduse_on_day');
#         my $enduse_on_time     = $self->param('enduse_on_time');
#         #my $getstarted_on     = $self->param('getstarted_on');
#         #my $enduse_on         = $self->param('enduse_on');
#         my $useform            = $self->param('useform');
#         my $message            = $self->param('message');
#         my $general_id         = $self->param('general_id');
#         my $admin_id           = $self->param('admin_id');
#         my $tel                = $self->param('tel');
#         my $status             = $self->param('status');
#         my $create_on          = $today->datetime(date => '-', T => ' ');
#         my $modify_on          = $today->datetime(date => '-', T => ' ');
#         #sql書き込む前に開始、終了時刻変換,日付も考慮
#         if ($getstarted_on_time =~ /^[2][4-9]$/) {
#             $getstarted_on_time -= 24;
#             if ($time_change) {
#                 $getstarted_on_time .= ":30";
#             }
#             else {
#                 $getstarted_on_time .= ":00";
#             }

#             #日付を1日進める
#             $getstarted_on_day = localtime->strptime($getstarted_on_day,'%Y-%m-%d');
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
#         if ($enduse_on_time =~ /^[2][4-9]$|^[3][0]$/) {
#             $enduse_on_time -= 24;
#             if ($time_change) {
#                 $enduse_on_time .= ":30";
#             }
#             else {
#                 $enduse_on_time .= ":00";
#             }
#             #日付を1日進める
#             $enduse_on_day = localtime->strptime($enduse_on_day,'%Y-%m-%d');
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
#         my $enduse_on     = $enduse_on_day     . " " . $enduse_on_time;
#         #idがある時、修正データの場合sql実行
#         if ($id eq "AUTO_NUMBER") {
#             $id = undef;
#         }
#         if ($id) {
#             #修正データをsqlへ送り込む
#             my $count = $teng->update(
#                 'reserve' => {
#                     'roominfo_id'   => $roominfo_id,
#                     'getstarted_on' => $getstarted_on,
#                     'enduse_on'     => $enduse_on,
#                     'useform'       => $useform,
#                     'message'       => $message,
#                     'general_id'    => $general_id,
#                     'admin_id'      => $admin_id,
#                     'tel'           => $tel,
#                     'status'        => $status,
#                    #'create_on'     => $create_on,
#                     'modify_on'     => $modify_on,
#                 }, {
#                     'id'            => $id,
#                 }
#             );
#             $self->flash(henkou => '修正完了');
#         }
#         else {
#         #idが無い場合、新規登録sql実行 新規登録データをsqlへ送り込む
#         my $row = $teng->insert('reserve' => {
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
#                    #'modify_on'     => $modify_on,
#             });
#             $self->flash(touroku => '登録完了');
#         }
#         #sqlにデータ入力したのでlist画面にリダイレクト
#         return $self->redirect_to('mainte_reserve_serch');
#         #リターンなのでここでおしまい。
#     }
#     #入力検査合格しなかった場合、もう一度入力フォーム表示Fillinにて
#     my $html = $self->render_partial()->to_string;
#     $html = HTML::FillInForm->fill(\$html, $self->req->params,);
#     return $self->render_text($html, format => 'html');
#     #リターンなのでここでおしまい。
# #post以外(getの時)list画面から修正で移動してきた時
# }
# else {
#     #idがある時、修正なのでsqlより該当のデータ抽出
#     my $id = $self->param('id');   #ID
#     #変数定義
#     my ($roominfo_id,$getstarted_on,$enduse_on,
#         $useform,$message,$general_id,$admin_id,$tel,
#         $status,$create_on,$modify_on
#     );
#     if ($id) {
#         # id検索、sql実行
#         #die "test";
#         my @rows = $teng->single('reserve', {'id' => $id });
#         foreach my $row (@rows) {
#             $id            = $row->id ;
#             $roominfo_id   = $row->roominfo_id;
#             $getstarted_on = $row->getstarted_on;
#             $enduse_on     = $row->enduse_on;
#             $useform       = $row->useform;
#             $message       = $row->message;
#             $general_id    = $row->general_id;
#             $admin_id      = $row->admin_id;
#             $tel           = $row->tel;
#             $status        = $row->status;
#             $create_on     = $row->create_on;
#             $modify_on     = $row->modify_on;
#         }
#     }
#     else {
#             $id            = "AUTO_NUMBER" ;
#     }
#     #fillinで送る前にデータを加工する#日付と30時間表記に分解,日付も考慮
#     #$getstarted_on
#     my $getstarted_on_day;#日付を切り出し
#     my $getstarted_on_time;#時間を切り出し
#     if ($getstarted_on) {
#         $getstarted_on_day   = substr($getstarted_on,0,10);
#         $getstarted_on_time  = substr($getstarted_on,11,2);
#         $getstarted_on_time += 0;
#         if ($getstarted_on_time =~ /^[0-5]$/) {
#             $getstarted_on_time += 24;
#             #日付を1日もどる
#             $getstarted_on_day = localtime->strptime($getstarted_on_day,'%Y-%m-%d');
#             $getstarted_on_day = $getstarted_on_day - ONE_DAY * 1;
#             $getstarted_on_day = $getstarted_on_day->date;
#         }
#     }
#     #$enduse_on
#     my $enduse_on_day;#日付を切り出し
#     my $enduse_on_time;#時間を切り出し
#     if ($enduse_on) {
#         $enduse_on_day   = substr($enduse_on,0,10);
#         $enduse_on_time  = substr($enduse_on,11,2);
#         $enduse_on_time += 0;
#         if ($enduse_on_time =~ /^[0-6]$/) {
#             $enduse_on_time += 24;
#             #日付を1日もどる
#             $enduse_on_day = localtime->strptime($enduse_on_day,'%Y-%m-%d');
#             $enduse_on_day = $enduse_on_day - ONE_DAY * 1;
#             $enduse_on_day = $enduse_on_day->date;
#         }
#     }
#     #修正用フォーム、Fillinつかって表示
#     #値はsqlより該当idのデータをつかう
#     my $html = $self->render_partial()->to_string;
#     $html = HTML::FillInForm->fill(
#         \$html,{
#             id                 => $id ,
#             roominfo_id        => $roominfo_id,
#             getstarted_on_day  => $getstarted_on_day,#データ加工
#             getstarted_on_time => $getstarted_on_time,
#             enduse_on_day      => $enduse_on_day,
#             enduse_on_time     => $enduse_on_time,
#             #getstarted_on     => $getstarted_on,
#             #enduse_on         => $enduse_on,
#             useform            => $useform,
#             message            => $message,
#             general_id         => $general_id,
#             admin_id           => $admin_id,
#             tel                => $tel,
#             status             => $status,
#             create_on          => $create_on,
#             modify_on          => $modify_on
#         },
#     );
#     #Fillin画面表示実行returnなのでここでおしまい。
#     return $self->render_text($html, format => 'html');
# }
# };



__END__
# mainte_reserve_serch.html.ep
#予約履歴のデータ検索コントロール-----------------------------
get '/mainte_reserve_serch' => sub {
    my $self = shift;
    my $class = "mainte_reserve_serch"; # テンプレートbodyのクラス名を定義
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
        my @rows = $teng->single('reserve', {'id' => $id });
        $self->stash(rows_ref => \@rows);
    }else{ # sqlすべてのデータ出力
        my @rows = $teng->search_named(q{select * from reserve;});
        $self->stash(rows_ref => \@rows);
    }
    $self->render('mainte_reserve_serch');
};


# mainte_reserve_new.html.ep
#予約履歴の新規作成、修正、sql入力コントロール-----------------------------
any '/mainte_reserve_new' => sub {
my $self = shift;
my $class = "mainte_reserve_new"; # テンプレートbodyのクラス名を定義
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
#===
# 30毎の予約をするめための切り替え
my $time_change = 1;
$self->stash(time_change => $time_change);


#===
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

#部屋情報設定を取得する(入力につかう)->利用開始のみ抽出
my @roominfos = $teng->search_named(q{select * from roominfo;});
$self->stash(roominfos_ref => \@roominfos);

#店舗情報を取得する(入力につかう)
my @storeinfos = $teng->search_named(q{select * from storeinfo;});
$self->stash(storeinfos_ref => \@storeinfos);

#一般ユーザー情報を取得する(入力につかう)
my @generals = $teng->search_named(q{select * from general;});
$self->stash(generals_ref => \@generals);

#管理ユーザー情報を取得する(入力につかう)
my @admins = $teng->search_named(q{select * from admin;});
$self->stash(admins_ref => \@admins);

#書いてないけど、新規作成一発目はテンプレートの入力フォームレンダリング
#---------
#post判定する
if (uc $self->req->method eq 'POST') {
    #新規入力も修正もボタン押すとpostで入ってくる、両方バリデード実行
    # バリデーション()
    my $validator = $self->create_validator;
    #バリデーションが複雑になってきたのでもう一度順番に整理する
    #予約のダブり確認のバリデ
    $validator->field('id')->callback(sub {
        my $value = shift;

        my $judg_reserve_id = 0;#予約既にあり
        my $judg_reserve_id = 1;#問題なし


    # 予約のダブりが存在を確認するスクリプトをもう一度考えてみる
    #入力した値を取得する=======================================================
    # 入力した値を取得する(予約id,部屋情報id,利用開始時刻,利用終了時刻)
    my $id                 = $self->param('id');
    my $roominfo_id        = $self->param('roominfo_id');
    my $kibou_date         = $self->param('getstarted_on_day');#入力した予約の希望日付
    my $kibou_start        = $self->param('getstarted_on_time');
    my $enduse_on_day      = $self->param('enduse_on_day');
    my $kibou_end          = $self->param('enduse_on_time');

    #既に入力済みのデータをsqlから取り出す========================================
    # 予約履歴を抽出する
    my @reserves = $teng->search_named(q{select * from reserve;});

    #比較したいデータのみを選別する===============================================
        # 比較したいデータとは、入力した部屋id(roominfo_id)と同じもの
        # 入力した予約id(id)は比較対象外にする
    foreach my $reserve_ref (@reserves) {# 予約データを一件づつすべて引き出す
        if ($reserve_ref->roominfo_id == $roominfo_id) { #入力したroominfo_idと同じデータのみ
            if ($reserve_ref->id ne $id ) { #入力した予約id以外のもの
                #比較できるよう値を変換
                #データの利用開始と利用終了のデータを取り出し
                #利用開始日時取り出し
                my $getstarted_on = $reserve_ref->getstarted_on;
                #日付と時刻に分ける(ただしまだ通常の0-5時の形式)
                my $getstarted_on_day   = substr($getstarted_on,0,10);#日付
                my $getstarted_on_time  = substr($getstarted_on,11,2);#時刻
                $getstarted_on_time    += 0;#念のために時刻を数字の型にして、最初の0があれば表示しない
                #時刻0-5時の場合は24-29に変換、
                if ($getstarted_on_time =~ /^[0-5]$/) {
                    $getstarted_on_time += 24;
                    #日付を1日もどる
                    $getstarted_on_day = localtime->strptime($getstarted_on_day,'%Y-%m-%d');
                    $getstarted_on_day = $getstarted_on_day - ONE_DAY * 1;
                    $getstarted_on_day = $getstarted_on_day->date;
                }
                #利用終了日時取り出し
                my $enduse_on = $reserve_ref->enduse_on;
                #日付と時刻に分ける(ただしまだ通常の0-6時の形式)
                my $enduse_on_day   = substr($enduse_on,0,10);#日付
                my $enduse_on_time  = substr($enduse_on,11,2);#時刻
                $enduse_on_time += 0;#念のために時刻を数字の型にして、最初の0があれば表示しない
                #時刻0-6時の場合は24-30に変換、
                if ($enduse_on_time =~ /^[0-6]$/) {
                    $enduse_on_time += 24;
                    #日付を1日もどる
                    $enduse_on_day = localtime->strptime($enduse_on_day,'%Y-%m-%d');
                    $enduse_on_day = $enduse_on_day - ONE_DAY * 1;
                    $enduse_on_day = $enduse_on_day->date;
                }

                #開始時刻から終了時刻一つ前まで、比較してゆく、一致すればdie!ダブり！
                #入力した日付とデータの日付が一致した時比較開始
                if ($getstarted_on_day eq $kibou_date) {
                    #今見ているデータの時間軸をだす
                    #比較の計算式を書き直し
                my $i = $getstarted_on_time;
                for ($i; $i < $enduse_on_time; ++$i) {#sqlのデータ
                    #開始から終了一つ前まで１つづつ取り出し
                    my $ii = $kibou_start;
                    for ($ii; $ii < $kibou_end; ++$ii) {#入力データ
                        if ($i == $ii) {$judg_reserve_id = 0;}
                    }
                }
                }
            }
        }
    }


#    #おしまし





        return 1 if $judg_reserve_id ;

        return (0, '既に予約が存在します');
    });


    # 利用開始日時 getstarted_on->日付と時間
    #日付の書式のバリデ
    $validator->field('getstarted_on_day')->required(1)->constraint('date', split => '-');
    # 抽出した部屋情報の開始時刻より遅く、終了時間より早い事
    $validator->field('getstarted_on_time')->callback(sub {
        my $value = shift;

        # 部屋の利用開始と終了時刻の範囲内かを調べるバリデ
        # 指定したスタジオ、部屋情報idを取得
        my $roominfo_id = $self->param('roominfo_id');
        my $starttime_on; # 該当する部屋の開始時刻と終了時刻を取得
        my @roominfos = $teng->search_named(q{select * from roominfo;});
        foreach my $roominfo_ref (@roominfos) {
            if ($roominfo_ref->id == $roominfo_id) {
                $starttime_on  = $roominfo_ref->starttime_on;#開始時刻取得
            }
        }
        #比較するため24-29の数字に変換
        if ($starttime_on) {
            $starttime_on  = substr($starttime_on,0,2);
            $starttime_on += 0;
            if ($starttime_on =~ /^[0-5]$/) {
                $starttime_on += 24;
            }
        }

        return 1 if $starttime_on <= $value;

        return (0, '営業時間外です');
    });


    # 利用終了日時 enduse_on->日付と時間
    # 日付の書式バリデ、開始、終了同じ日付にさせる
    $validator->field('enduse_on_day')->required(1)->
        constraint('date', split => '-')->callback(sub {
        my $value = shift;
        my $getstarted_on_day = $self->param('getstarted_on_day');

        return 1 if $getstarted_on_day eq $value ;

        return (0, '開始と同じ日付にして下さい') ;
    });

    $validator->field('enduse_on_time')->callback(sub {
        my $value = shift; #開始より終了が早い場合
        my $getstarted_on_time = $self->param('getstarted_on_time');

        my @roominfos = $teng->search_named(q{select * from roominfo;});
        # 指定したスタジオ、部屋情報idを取得
        my $roominfo_id = $self->param('roominfo_id');
        my $endingtime_on;# 該当する部屋の終了時刻を取得
        my $rentalunit;# 該当する部屋の貸出単位を取得
        foreach my $roominfo_ref (@roominfos) {
            if ($roominfo_ref->id == $roominfo_id) {
                $endingtime_on = $roominfo_ref->endingtime_on;#終了時刻取得
                $rentalunit    = $roominfo_ref->rentalunit;#貸出単位
            }
        }
        #貸出単位設定で2時間指定されたときの、バリデのためrentalunitも取得
        # 1が１時間、2が２時間、２が選択されているときだけバリデ
        #判定の変数
        my $judg_rentalunit;
        if ($rentalunit == 2) {
            my $val = $value - $getstarted_on_time ;
            if ($val % 2 == 0) { #偶数
                $judg_rentalunit = 0 ;#問題なし
            }
            else {
                $judg_rentalunit = 1 ;#奇数、バリデートコメントへ
            }
        }
        #比較するため24-29の数字に変換
        if ($endingtime_on) {
            $endingtime_on   = substr($endingtime_on,0,2);
            $endingtime_on += 0;
            if ($endingtime_on =~ /^[0-6]$/) {
                $endingtime_on += 24;
            }
        }

        return (0, '2時間単位でしか予約できません') if $judg_rentalunit ;

        return (0, '開始時刻より遅くして下さい') if $getstarted_on_time >= $value ;

        return 1 if $endingtime_on >= $value ;

        return (0, '営業時間外です');
    });

    # 利用形態名 useform->バンド、個人練習、利用停止、いずれも許可が必要
    $validator->field('useform')->callback(sub {
        my $useform   = shift;

        #判定の変数定義
        my $judg_privatepermit;
        my $judg_privateconditions;
        my $judg_general_id;


        # useformのバリデート最初にはいってくる値ごとにifで分ける
        # 0バンドの場合、1個人の場合、2利用停止、の場合
        if ($useform == 1) {
            #============================
            # 必要な情報をそろえる
            #入力している部屋情報id->roominfo->idを取得する
            my $roominfo_id = $self->param('roominfo_id');
            my @roominfos = $teng->search_named(q{select * from roominfo;});
            my $privatepermit;# 個人練習許可設定
            my $privateconditions; # 個人練習許可条件
            foreach my $roominfo_ref (@roominfos) {
                if ($roominfo_ref->id == $roominfo_id) {
                    $privatepermit     = $roominfo_ref->privatepermit;
                    $privateconditions = $roominfo_ref->privateconditions;
                }
            }
            #============================
            #個人練習許可が出てない部屋で個人練習->1選択できない
            #$privatepermit ->0 #許可する #$privatepermit ->1 #許可しない
            $judg_privatepermit = 0;#利用出来る
            #$judg_privatepermit = 1;#利用出来ない
            # 判定
            if ($privatepermit) {$judg_privatepermit = 1;}
            #============================
            #個人練習許可条件に一致してない場合、選択できない
            $judg_privateconditions = 0;#利用できる
            #入力している希望日時を取得する、
            my $getstarted_on_day = $self->param('getstarted_on_day');
            #今の日付と比較して何日前か計算して出力
            #入力しているデータを日付のデータに変換
            $getstarted_on_day = localtime->strptime($getstarted_on_day,'%Y-%m-%d');
            my $today = localtime;

            my $input_date_day = $today->date;#日付を切り出し
            my $input_date_time = $today->time;#時間を切り出し
            $input_date_time  = substr($input_date_time,0,2);
            $input_date_time += 0;
            if ($input_date_time =~ /^[0-5]$/) {
            $input_date_time += 24;
            #日付を1日もどる
            $input_date_day = localtime->strptime($input_date_day,'%Y-%m-%d');
            $input_date_day = $input_date_day - ONE_DAY * 1;
            $input_date_day = $input_date_day->date;
        }
            my $input_date = $input_date_day;

            my @reserve_date_data;# 予約指定日を７日さかのぼった数字(日付データ)
            $reserve_date_data[0] = $getstarted_on_day;
            for (my $i=1;$i < 8;++$i) {
            $reserve_date_data[$i] = $getstarted_on_day - ONE_DAY * $i ;
        }
            #日付データから文字データに変換する
            my @reserve_date;
            for (my $i=0;$i < 8;++$i) {
            $reserve_date[$i] = $reserve_date_data[$i]->date;
        }
            $reserve_date[8] = $input_date;
            #my $judg_privateconditions = 0;#利用出来る
            $judg_privateconditions = 1;#利用できない
            # 判定
                for (my $i=0;$i <= $privateconditions;++$i) {
                if (@reserve_date[$i] eq $input_date) {
                    $judg_privateconditions = 0;#利用できる
                }
            }

        }
        elsif ($useform == 2) {
            #============================
            #一般ユーザーが選択されてる時に利用停止->2が選択されてはいけない
            $judg_general_id = 0;#利用出来る
            #my $judg_general_id = 1;#利用出来ない
            if ($useform == 2) {
                my $general_id = $self->param('general_id');
                # 判定
                if ($general_id) {$judg_general_id = 1;}
            }
        }
        #バンドの場合
        else {
            $judg_privatepermit = 0;
            $judg_privateconditions = 0;
            $judg_general_id = 0;
        }
        #============================
        return   ($judg_privatepermit     ) ? (0, '個人練習が許可されてない'              )
               : ($judg_privateconditions ) ? (0, 'その指定日では個人練習は利用できません')
               : ($judg_general_id        ) ? (0, '一般ユーザーは利用できない'            )
               :                               1
               ;
    });
    # 伝言板 message->空白でもいいが文字数の制限をする
    $validator->field('message')->required(0)->length(0,20);
    # 一般ユーザー、管理、 general_id　admin_id->どちらかを選択、両方はNG
    $validator->field('admin_id')->callback(sub {
        my $admin_id   = shift;
        my $general_id = $self->param('general_id');
        #NG 両方が0　 両方が0以外
        return   (  $general_id and   $admin_id) ? (0, '両方の選択は不可')
               : (! $general_id and ! $admin_id) ? (0, '一般、管理どちらかを選択してください')
               :                                    1
               ;
    });
    # 電話番号、 tel->必須、文字制限
    $validator->field('tel')->required(1)->length(1,30);

    # 利用開始時間のバリデートについてもう少し考えてみる

    #mojoのコマンドでパラメーターをハッシュで取得入力した値をFIllin時に使うため、
    my $param_hash = $self->req->params->to_hash;
    $self->stash(param_hash => $param_hash);
    #入力検査合格、の時、値を新規もしくは修正アップロード実行
    if ( $self->validate($validator,$param_hash) ) {
        #ここでいったん入力値を全部受け取っておく 日付データ作成する
        my $today = localtime;

        my $id                 = $self->param('id');
        my $roominfo_id        = $self->param('roominfo_id');
        my $getstarted_on_day  = $self->param('getstarted_on_day');#データ加工
        my $getstarted_on_time = $self->param('getstarted_on_time');
        my $enduse_on_day      = $self->param('enduse_on_day');
        my $enduse_on_time     = $self->param('enduse_on_time');
        #my $getstarted_on     = $self->param('getstarted_on');
        #my $enduse_on         = $self->param('enduse_on');
        my $useform            = $self->param('useform');
        my $message            = $self->param('message');
        my $general_id         = $self->param('general_id');
        my $admin_id           = $self->param('admin_id');
        my $tel                = $self->param('tel');
        my $status             = $self->param('status');
        my $create_on          = $today->datetime(date => '-', T => ' ');
        my $modify_on          = $today->datetime(date => '-', T => ' ');
        #sql書き込む前に開始、終了時刻変換,日付も考慮
        if ($getstarted_on_time =~ /^[2][4-9]$/) {
            $getstarted_on_time -= 24;
            if ($time_change) {
                $getstarted_on_time .= ":30";
            }
            else {
                $getstarted_on_time .= ":00";
            }

            #日付を1日進める
            $getstarted_on_day = localtime->strptime($getstarted_on_day,'%Y-%m-%d');
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
        if ($enduse_on_time =~ /^[2][4-9]$|^[3][0]$/) {
            $enduse_on_time -= 24;
            if ($time_change) {
                $enduse_on_time .= ":30";
            }
            else {
                $enduse_on_time .= ":00";
            }
            #日付を1日進める
            $enduse_on_day = localtime->strptime($enduse_on_day,'%Y-%m-%d');
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
        my $enduse_on     = $enduse_on_day     . " " . $enduse_on_time;
        #idがある時、修正データの場合sql実行
        if ($id eq "AUTO_NUMBER") {
            $id = undef;
        }
        if ($id) {
            #修正データをsqlへ送り込む
            my $count = $teng->update(
                'reserve' => {
                    'roominfo_id'   => $roominfo_id,
                    'getstarted_on' => $getstarted_on,
                    'enduse_on'     => $enduse_on,
                    'useform'       => $useform,
                    'message'       => $message,
                    'general_id'    => $general_id,
                    'admin_id'      => $admin_id,
                    'tel'           => $tel,
                    'status'        => $status,
                   #'create_on'     => $create_on,
                    'modify_on'     => $modify_on,
                }, {
                    'id'            => $id,
                }
            );
            $self->flash(henkou => '修正完了');
        }
        else {
        #idが無い場合、新規登録sql実行 新規登録データをsqlへ送り込む
        my $row = $teng->insert('reserve' => {
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
            });
            $self->flash(touroku => '登録完了');
        }
        #sqlにデータ入力したのでlist画面にリダイレクト
        return $self->redirect_to('mainte_reserve_serch');
        #リターンなのでここでおしまい。
    }
    #入力検査合格しなかった場合、もう一度入力フォーム表示Fillinにて
    my $html = $self->render_partial()->to_string;
    $html = HTML::FillInForm->fill(\$html, $self->req->params,);
    return $self->render_text($html, format => 'html');
    #リターンなのでここでおしまい。
#post以外(getの時)list画面から修正で移動してきた時
}
else {
    #idがある時、修正なのでsqlより該当のデータ抽出
    my $id = $self->param('id');   #ID
    #変数定義
    my ($roominfo_id,$getstarted_on,$enduse_on,
        $useform,$message,$general_id,$admin_id,$tel,
        $status,$create_on,$modify_on
    );
    if ($id) {
        # id検索、sql実行
        #die "test";
        my @rows = $teng->single('reserve', {'id' => $id });
        foreach my $row (@rows) {
            $id            = $row->id ;
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
    }
    else {
            $id            = "AUTO_NUMBER" ;
    }
    #fillinで送る前にデータを加工する#日付と30時間表記に分解,日付も考慮
    #$getstarted_on
    my $getstarted_on_day;#日付を切り出し
    my $getstarted_on_time;#時間を切り出し
    if ($getstarted_on) {
        $getstarted_on_day   = substr($getstarted_on,0,10);
        $getstarted_on_time  = substr($getstarted_on,11,2);
        $getstarted_on_time += 0;
        if ($getstarted_on_time =~ /^[0-5]$/) {
            $getstarted_on_time += 24;
            #日付を1日もどる
            $getstarted_on_day = localtime->strptime($getstarted_on_day,'%Y-%m-%d');
            $getstarted_on_day = $getstarted_on_day - ONE_DAY * 1;
            $getstarted_on_day = $getstarted_on_day->date;
        }
    }
    #$enduse_on
    my $enduse_on_day;#日付を切り出し
    my $enduse_on_time;#時間を切り出し
    if ($enduse_on) {
        $enduse_on_day   = substr($enduse_on,0,10);
        $enduse_on_time  = substr($enduse_on,11,2);
        $enduse_on_time += 0;
        if ($enduse_on_time =~ /^[0-6]$/) {
            $enduse_on_time += 24;
            #日付を1日もどる
            $enduse_on_day = localtime->strptime($enduse_on_day,'%Y-%m-%d');
            $enduse_on_day = $enduse_on_day - ONE_DAY * 1;
            $enduse_on_day = $enduse_on_day->date;
        }
    }
    #修正用フォーム、Fillinつかって表示
    #値はsqlより該当idのデータをつかう
    my $html = $self->render_partial()->to_string;
    $html = HTML::FillInForm->fill(
        \$html,{
            id                 => $id ,
            roominfo_id        => $roominfo_id,
            getstarted_on_day  => $getstarted_on_day,#データ加工
            getstarted_on_time => $getstarted_on_time,
            enduse_on_day      => $enduse_on_day,
            enduse_on_time     => $enduse_on_time,
            #getstarted_on     => $getstarted_on,
            #enduse_on         => $enduse_on,
            useform            => $useform,
            message            => $message,
            general_id         => $general_id,
            admin_id           => $admin_id,
            tel                => $tel,
            status             => $status,
            create_on          => $create_on,
            modify_on          => $modify_on
        },
    );
    #Fillin画面表示実行returnなのでここでおしまい。
    return $self->render_text($html, format => 'html');
}
};

