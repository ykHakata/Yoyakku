package Yoyakku::Controller::Calendar;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Calendar;

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Calendar->new();
    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session );
    return $model;
}




1;

__END__


#今月トップのコントロール-----------------------------
get '/index' => sub {
my $self = shift;
# テンプレート用bodyのクラス名
my $class = "index_this_m";
$self->stash(class => $class);
#die "test!!stop!!";
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
#日付変更線を６時に変更
my $now_date    = localtime;

my $chang_date_ref = chang_date_6($now_date);

my $now_date    = $chang_date_ref->{now_date};
my $next1m_date = $chang_date_ref->{next1m_date};
my $next2m_date = $chang_date_ref->{next2m_date};
my $next3m_date = $chang_date_ref->{next3m_date};
#====================================================
#新しい日付情報取得のスクリプト======================
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
my @cal_now    = calendar($now_date->mon,$now_date->year);
#my @cal_next1m = calendar($next1m_date->mon,$next1m_date->year);
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
    cal_now => \@cal_now,
    caps    => \@caps
);

#====================================================
#条件検索のため、今月の情報取得
my $like_now_data = $now_date->strftime('%Y-%m');
# 今月のイベント広告データ取得 # 3/14修正後
my @ads_rows = $teng->search_named(q{
    select * from ads where
    kind=1 and displaystart_on
    like :like_now_data order by displaystart_on asc;
}, { like_now_data => $like_now_data."%" });
$self->stash(ads_rows => \@ads_rows);# テンプレートへ送り、
$self->render('index');
};

