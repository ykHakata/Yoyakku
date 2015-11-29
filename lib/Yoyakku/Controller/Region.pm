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
    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session );
    $model->check_auth_db_yoyakku();
    my $header_stash = $model->get_header_stash_region();
    return if !$header_stash;
    $self->stash($header_stash);
    return $model;
}

=head2 region_state

    予約の為のスタジオ検索(地域)

=cut
use Data::Dumper;
sub region_state {
    my $self  = shift;
    my $model = $self->_init();
    return $self->redirect_to('profile') if !$model;
    my $ads_navi_rows = $model->get_ads_navi_rows();
    my $ads_one_rows  = $model->get_ads_one_rows();
    my $ads_reco_rows = $model->get_ads_reco_rows();
    my $select_date   = $model->get_select_date();
    my $ads_rows      = $model->get_ads_rows();

    # 表示させる為のダミーの値
    $self->stash(
        class        => 'state',
        select_date  => $select_date,
        adsReco_rows => $ads_reco_rows,
        adsOne_rows  => $ads_one_rows,
        ads_rows     => $ads_rows,
        adsNavi_rows => $ads_navi_rows,
    );

    my $switch_calnavi = $model->get_switch_calnavi();
    my $back_mon_val   = $model->get_back_mon_val();
    my $next_mon_val   = $model->get_next_mon_val();
    my $select_date_ym = $model->get_select_date_ym();

    # navi_calnavi_new の為のダミーの値
    $self->stash(
        back_mon_val    => $back_mon_val,
        select_date_ym  => $select_date_ym,
        next_mon_val    => $next_mon_val,
        switch_calnavi  => $switch_calnavi,
        store_id        => '',
        caps            => [],
        cal             => [],
        select_date_day => '',
        border_date_day => '',
    );

    return $self->render(
        template => 'region/region_state',
        format   => 'html',
    );
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

#ログイン機能==========================================



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

$self->stash(
    now_data    => $now_date,
    next1m_data => $next1m_date,
    next2m_data => $next2m_date,
    next3m_data => $next3m_date
);




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

#sql値取得
#今日の日付取得
my $now_data_ymd = $now_date->ymd;

#$self->stash(now_data_ymd => $now_data_ymd);


$self->render('region_state');
};

----------

%# 道州名添付用のインデックス定義
% my ($hk_i,$th_i,$kt_i,$tb_i,$kk_i,$tg_i,$ks_i);
% my $S_Dis_id_used = "";
% my $C_Dis_id_used = "";

% foreach my $storeinfo_row_ref (@$storeinfo_rows_ref) {
    %# 店舗テーブルの地域idの上２桁切取り道州名を表示する
    % my $r_idCut = substr ($storeinfo_row_ref->region_id,0,2);
    <% if ($r_idCut =~ /^[0][1]/            and $hk_i == 0 ) { %> <p>北海道</p> <% ++$hk_i; } %>
    <% if ($r_idCut =~ /^[0][2-7]/          and $th_i == 0 ) { %> <p>東北</p>   <% ++$th_i; } %>
    <% if ($r_idCut =~ /^[0][8-9]|[1][0-4]/ and $kt_i == 0 ) { %> <p>関東</p>   <% ++$kt_i; } %>
    <% if ($r_idCut =~ /^[1][5-9]|[2][0-3]/ and $tb_i == 0 ) { %> <p>中部</p>   <% ++$tb_i; } %>
    <% if ($r_idCut =~ /^[2][4-9]|[3][0]/   and $kk_i == 0 ) { %> <p>近畿</p>   <% ++$kk_i; } %>
    <% if ($r_idCut =~ /^[3][1-9]/          and $tg_i == 0 ) { %> <p>中国</p>   <% ++$tg_i; } %>
    <% if ($r_idCut =~ /^[4][0-7]/          and $ks_i == 0 ) { %> <p>九州</p>   <% ++$ks_i; } %>
    %# 表示用の都道府県idを作成する
    % my $S_Dis_id = $r_idCut . "000";
    %# 地域名別に店舗名を表示させる
    % if ($S_Dis_id eq $S_Dis_id_used) {
        % if ($storeinfo_row_ref->region_id eq $C_Dis_id_used) {
            <a href="javascript:void(0)" onclick="document.store_<%= $storeinfo_row_ref->id %>.submit();return false;">　　　<%= $storeinfo_row_ref->name %></a>
            <form name="store_<%= $storeinfo_row_ref->id %>" method="get" action="region_situation">
            <input type="hidden"  name="store_id" value="<%= $storeinfo_row_ref->id %>">
            <input type="hidden"  name="select_date" value="<%= $select_date %>">
            </p>
            </form>
        % } else {
            <p>　　<%= $storeinfo_row_ref->cities %></p>
            <a href="javascript:void(0)" onclick="document.store_<%= $storeinfo_row_ref->id %>.submit();return false;">　　　<%= $storeinfo_row_ref->name %></a>
            <form name="store_<%= $storeinfo_row_ref->id %>" method="get" action="region_situation">
            <input type="hidden"  name="store_id" value="<%= $storeinfo_row_ref->id %>">
            <input type="hidden"  name="select_date" value="<%= $select_date %>">
            </p>
            </form>
        % }
        % $C_Dis_id_used = $storeinfo_row_ref->region_id;
    % } else {
        % foreach my $region_row_ref (@$region_rows_ref) {
            % if ($region_row_ref->id eq $S_Dis_id) {
                <p>　<%= $region_row_ref->name %></p>
            % }
        % }
        % $S_Dis_id_used = $S_Dis_id;
        <p>　　<%= $storeinfo_row_ref->cities %></p>
            <a href="javascript:void(0)" onclick="document.store_<%= $storeinfo_row_ref->id %>.submit();return false;">　　　<%= $storeinfo_row_ref->name %></a>
            <form name="store_<%= $storeinfo_row_ref->id %>" method="get" action="region_situation">
            <input type="hidden"  name="store_id" value="<%= $storeinfo_row_ref->id %>">
            <input type="hidden"  name="select_date" value="<%= $select_date %>">
            </p>
            </form>
    % }
% }
