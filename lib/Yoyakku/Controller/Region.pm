package Yoyakku::Controller::Region;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Region;

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Controller::Region - 予約のコントローラー

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Controller::Region version 0.0.1

=head1 SYNOPSIS (概要)

    予約、関連機能のリクエストをコントロール

=cut

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Region->new();
    return $model;
}

=head2 region_state

    予約の為のスタジオ検索(地域)

=cut

sub region_state {
    my $self = shift;


    return $self->render( template => 'region/region_state', format => 'html', );
}

1;

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Region>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut

__END__

#予約の為のスタジオ検索コントロール-----------------------------
get '/region_state' => sub {
my $self = shift;

# テンプレートbodyのクラス名を定義
my $class = "state";
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
    my $general_ref  = $teng->single('general', +{id => $general_id});
    my $profile_ref  = $teng->single('profile', +{general_id => $general_id});
    $login           = $profile_ref->nick_name;

    my $status = $general_ref->status;
    if ($status) {
        $switch_header = 6;
    }
    else {
        #$switch_header = 8;
        return $self->redirect_to('profile');
    }
    #return $self->redirect_to('index');
}
else {
    $switch_header = 5;
    #return $self->redirect_to('index');
}

$self->stash(login => $login);# #ログイン名をヘッダーの右に表示させる
# headerの切替
$self->stash(switch_header => $switch_header);
#====================================================

#=======================================================
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


# カレンダーナビにstoreidを埋め込む為の切替
my $switch_calnavi = 0;
$self->stash(switch_calnavi => $switch_calnavi);


# 地域ナビため、店舗登録をすべて抽出(web公開許可分だけ)
my @storeinfo_rows = $teng->search_named(q{
select * from storeinfo where status=0 order by region_id asc;
});
$self->stash(storeinfo_rows_ref => \@storeinfo_rows);# テンプレートへ送り、


# 地域ナビため、検索結果店舗id受け取り
my $store_id = $self->param('store_id');
$self->stash(store_id => $store_id);

# 地域ナビため、地域IDをすべて抽出
my @region_rows = $teng->search_named(q{
select * from region order by id asc;
});
$self->stash(region_rows_ref => \@region_rows); # テンプレートへ送り、



#=======================================================
#カレンダーナビスクリプト
#====================================================
#日付変更線を６時に変更
my $now_date    = localtime;

my $chang_date_ref = chang_date_6($now_date);

my $now_date    = $chang_date_ref->{now_date};
my $next1m_date = $chang_date_ref->{next1m_date};
my $next2m_date = $chang_date_ref->{next2m_date};
my $next3m_date = $chang_date_ref->{next3m_date};
#====================================================

#my $now_date = localtime;
##翌月の計算をやり直す
#my $next1m_date = localtime->strptime(
#    $now_date->strftime(
#        '%Y-%m-' . $now_date->month_last_day
#        ),'%Y-%m-%d'
#    ) + 86400;
#
#my $next2m_date = localtime->strptime(
#    $next1m_date->strftime(
#        '%Y-%m-' . $next1m_date->month_last_day
#    ),'%Y-%m-%d'
#) + 86400;
#
#my $next3m_date = localtime->strptime(
#    $next2m_date->strftime(
#        '%Y-%m-' . $next2m_date->month_last_day
#    ),'%Y-%m-%d'
#) + 86400;


my @cal;
my $select_date_ym;
my $border_date_day;
my $select_date_day;

my $select_cal = 0;

# 選択した日付の文字列を受け取る
my $select_date = $self->param('select_date');

# 進むのボタンを押した時の値をつくる
my $back_mon = $self->param('back_mon');
my $back_mon_val;
if ($back_mon) {
    $back_mon_val = $self->param('back_mon_val');

    $select_cal = ($back_mon_val == 0) ? 0
                : ($back_mon_val == 1) ? 1
                : ($back_mon_val == 2) ? 2
                :                        0
                ;

    if ($select_cal == 0) {
        $select_date_day = ($now_date->mday) + 0 ;
    }
    else {
        $select_date_day = 1 ;
    }
    # select_dateの値を作る（文字列で）
    $select_date = ($back_mon_val == 0) ? $now_date->date
                 : ($back_mon_val == 1) ? $next1m_date->date
                 : ($back_mon_val == 2) ? $next2m_date->date
                 :                        $now_date->date
                 ;

}
# 戻るのボタンを押した時の値をつくる
my $next_mon = $self->param('next_mon');
my $next_mon_val;
if ($next_mon) {
    $next_mon_val = $self->param('next_mon_val');

        $select_cal = ($next_mon_val == 0) ? 0
                    : ($next_mon_val == 1) ? 1
                    : ($next_mon_val == 2) ? 2
                    : ($next_mon_val == 3) ? 3
                    :                        0
                    ;
    if ($select_cal == 0) {
        $select_date_day = ($now_date->mday) + 0 ;
    }
    else {
        $select_date_day = 1 ;
    }
    # select_dateの値を作る（文字列で）
    $select_date = ($next_mon_val == 0) ? $now_date->date
                 : ($next_mon_val == 1) ? $next1m_date->date
                 : ($next_mon_val == 2) ? $next2m_date->date
                 : ($next_mon_val == 3) ? $next3m_date->date
                 :                        $now_date->date
                 ;
}

# 受け取った日付文字列から、出力するカレンダーを選択
if ($select_date) {
    $select_date = localtime->strptime($select_date,'%Y-%m-%d');

    $select_cal = ( $select_date->strftime('%Y-%m') eq $now_date->strftime('%Y-%m'   ) ) ? 0
                : ( $select_date->strftime('%Y-%m') eq $next1m_date->strftime('%Y-%m') ) ? 1
                : ( $select_date->strftime('%Y-%m') eq $next2m_date->strftime('%Y-%m') ) ? 2
                : ( $select_date->strftime('%Y-%m') eq $next3m_date->strftime('%Y-%m') ) ? 3
                :                                                                          0
                ;

    $select_date_day = ($select_date->mday) + 0 ;
}
else {
    $select_date = localtime->strptime($now_date->date,'%Y-%m-%d');
    if ($select_cal == 0) {
        $select_date_day = ($now_date->mday) + 0 ;
    }
    else {
        $select_date_day = 1 ;
    }
}

my $select_date_res = $select_date->date;
if ($select_cal == 0) {
#今月のカレンダー情報==================================================
#border_dateは今日の日付（日だけ）指定なし
@cal             = calendar($now_date->mon,$now_date->year);
$select_date_ym  = $now_date->strftime('%Y-%m');
$border_date_day = ($now_date->mday) + 0;
$back_mon_val    = 0;
$next_mon_val    = 1;
#０−５時までは前の日付に変換する処理をしておく事
#=====================================================================
}
elsif ($select_cal == 1) {
#１ヶ月後のカレンダー情報==================================================
#border_dateは今日の日付（日だけ）指定なし
@cal             = calendar($next1m_date->mon,$next1m_date->year);
$select_date_ym  = $next1m_date->strftime('%Y-%m');
$border_date_day = 1;
$back_mon_val    = 0;
$next_mon_val    = 2;
#$select_date = $next1m_date;
#０−５時までは前の日付に変換する処理をしておく事
#=====================================================================
}
elsif ($select_cal == 2) {
#２ヶ月後のカレンダー情報==================================================
#border_dateは今日の日付（日だけ）指定なし
@cal             = calendar($next2m_date->mon,$next2m_date->year);
$select_date_ym  = $next2m_date->strftime('%Y-%m');
$border_date_day = 1;
$back_mon_val    = 1;
$next_mon_val    = 3;
#０−５時までは前の日付に変換する処理をしておく事
#=====================================================================
}
else {
#３ヶ月後のカレンダー情報==================================================
#border_dateは今日の日付（日だけ）指定なし
@cal             = calendar($next3m_date->mon,$next3m_date->year);
$select_date_ym  = $next3m_date->strftime('%Y-%m');
$border_date_day = 1;
$back_mon_val    = 2;
$next_mon_val    = 3;
#０−５時までは前の日付に変換する処理をしておく事
#=====================================================================
}
#送り込む値
$self->stash(
    border_date_day => $border_date_day,
    select_date_ym  => $select_date_ym,
    select_date_day => $select_date_day,
    select_cal      => $select_cal,
    cal             => \@cal,
    caps            => \@caps,
    back_mon_val    => $back_mon_val,
    next_mon_val    => $next_mon_val,
    #select_date     => $select_date,
    select_date_res    => $select_date_res,
);
#=======================================================

#パンくずリスト用日付データ
#カレンダ日付取得
my $sub_date = $self->param('sub_date');
#$self->stash(sub_date => $sub_date);
$self->stash(select_date => $select_date->date);


# ナビ広告データ取得
my @adsNavi_rows = $teng->search_named(q{
select * from ads where kind=3 order by displaystart_on asc;
});
$self->stash(adsNavi_rows => \@adsNavi_rows);# テンプレートへ送り、

# おすすめスタジオ広告データ取得
my @adsReco_rows = $teng->search_named(q{
    select ads.id , ads.kind , ads.region_id,
    ads.name, ads.url,ads.content,region.name
    as region_name from ads left join region on
    ads.region_id = region.id where kind=4;
});
$self->stash(adsReco_rows => \@adsReco_rows);# テンプレートへ送り、

# 一行広告データ取得
my @adsOne_rows = $teng->search_named(q{
select * from ads where kind=2 order by displaystart_on asc;
});
$self->stash(adsOne_rows => \@adsOne_rows);# テンプレートへ送り、

#イベントスケジュールの為sqlより情報取得、本日以降、1,2,3ヶ月後末まで登録分抽出
#３ヶ月後末日の変数の作成
#3ヶ月後の日
my $next3m_last_day = $next3m_date->month_last_day;
my $next3Y_date = $next3m_date->year;
my $next3M_date = $next3m_date->mon;
#0000-00-00で表示
#my $next3m_last_ymd = $next3Y_data . "-" . $next3M_data . "-" . $next3m_last_day ;
my $next3m_last_ymd = $next3Y_date . "-" . $next3M_date . "-" . $next3m_last_day ;
#sql値取得
#今日の日付取得
my $now_data_ymd = $now_date->ymd;
#my $now_data_ymd = $now_data->ymd;
#$self->stash(now_data_ymd => $now_data_ymd);

my @ads_rows = $teng->search_named(q{
    select * from ads where
    kind=1 and displaystart_on >= :now_data_ymd and
    displaystart_on <= :next3m_last_ymd
    order by displaystart_on asc;
}, { now_data_ymd => $now_data_ymd , next3m_last_ymd => $next3m_last_ymd });
$self->stash(ads_rows => \@ads_rows);# テンプレートへ送り、

$self->render('region_state');
};
