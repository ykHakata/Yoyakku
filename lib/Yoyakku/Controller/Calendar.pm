package Yoyakku::Controller::Calendar;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Calendar;
use Data::Dumper;
sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Calendar->new();
    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session );
    $model->check_auth_db_yoyakku();
    my $header_stash = $model->get_header_stash_index();
    $self->stash($header_stash);
    return $model;
}

sub index {
    my $self  = shift;
    my $model = $self->_init();

    my $now_date = $model->get_date_info('now_date');
    my $caps     = $model->get_calender_caps();
    my $cal_now  = $model->get_calendar_info($now_date);
    my $ads_rows = $model->get_cal_info_ads_rows($now_date);

    $self->stash(
        class    => 'index_this_m',
        now_date => $now_date,
        cal_now  => $cal_now,
        caps     => $caps,
        ads_rows => $ads_rows,
    );

    return $self->render( template => 'index', format => 'html', );
}

sub index_next_m {
    my $self  = shift;
    my $model = $self->_init();

    my $cal_next1m = $model->get_date_info('cal_next1m');
    my $caps       = $model->get_calender_caps();
    my $cal_next1m = $model->get_calendar_info($cal_next1m);
    my $ads_rows   = $model->get_cal_info_ads_rows($cal_next1m);

    $self->stash(
        class      => 'index_next_m',
        cal_next1m => $cal_next1m,
        caps       => $caps,
        ads_rows   => $ads_rows,
    );

    return $self->render( template => 'index_next_m', format => 'html', );
}

1;

__END__

#1ヶ月後トップのコントロール-----------------------------
get '/index_next_m' => sub {
my $self = shift;
# テンプレートbodyのクラス名を定義
my $class = "index_next_m";
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
        else {
            $switch_header = 4;
        }
    }
    else {
        #$switch_header = 8;
        return $self->redirect_to('profile');
    }
}
elsif ($general_id) {
    my $general_ref  = $teng->single('general', +{id => $general_id});
    #$login         = $general_ref->login;
    my $profile_ref = $teng->single('profile', +{general_id => $general_id});
    $login          = $profile_ref->nick_name;

    my $status = $general_ref->status;
    if ($status) {
        $switch_header = 3;
    }
    else {
        #$switch_header = 8;
        return $self->redirect_to('profile');
    }
}
else {
    $switch_header = 2;
    #return $self->redirect_to('index');
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

#曜日の配列を作る
my @caps = ("日","月","火","水","木","金","土");
#カレンダー情報、今月、1,2,3ヶ月後
#my @cal_now    = calendar($now_date->mon,$now_date->year);
my @cal_next1m = calendar($next1m_date->mon,$next1m_date->year);
#my @cal_next2m = calendar($next2m_date->mon,$next2m_date->year);
#my @cal_next3m = calendar($next3m_date->mon,$next3m_date->year);
# 時刻(日付)取得、現在、1,2,3ヶ月後(ヘッダー用)
$self->stash(
    now_data    => $now_date,
    next1m_data => $next1m_date,
    next2m_data => $next2m_date,
    next3m_data => $next3m_date
);

#今月のカレンダーと曜日の配列
$self->stash(
    cal_next1m => \@cal_next1m,
    caps       => \@caps
);

#====================================================
#条件検索のため、一ヶ月後の情報取得
my $like_next1m_data = $next1m_date->strftime('%Y-%m');
# 一ヶ月後のイベント広告データ取得
my @ads_rows = $teng->search_named(q{
    select * from ads where
    displaystart_on
    like :like_next1m_data order by displaystart_on asc;
}, { like_next1m_data => $like_next1m_data."%" });
$self->stash(ads_rows => \@ads_rows);# テンプレートへ送り、

$self->render('index_next_m');
};
