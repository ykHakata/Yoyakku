use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN {
    use_ok('Yoyakku::Controller::Mainte::Ads') || print "Bail out!\n";
}

my $t            = Test::Mojo->new('Yoyakku');
my $config       = $t->app->config;
my $login_params = $config->{mainte}->{login_account};
$t->app->commands->start_app( 'Yoyakku', 'init_db', );

=head2 method

    オブジェクト、メソッド存在確認

=cut

subtest 'method' => sub {
    my $obj = Yoyakku::Controller::Mainte::Ads->new();
    isa_ok( $obj, 'Yoyakku::Controller::Mainte::Ads' );

    my @methods = qw{index mainte_ads_serch mainte_ads_new _insert _update
        _common _render_ads};

    can_ok( $obj, @methods );
};

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

subtest 'index' => sub {

    # get, post 以外は トップページにリダイレクト
    $t->head_ok('/mainte_ads_serch')->status_is(302);
    $t->head_ok('/mainte_ads_new')->status_is(302);
    $t->header_is( Location => '/index' );

    # ログインセッション無き場合トップページ
    $t->get_ok('/mainte_ads_serch')->status_is(302);
    $t->get_ok('/mainte_ads_new')->status_is(302);
    $t->header_is( Location => '/index' );
};

=head2 mainte_ads_serch

    ads テーブル登録情報の確認、検索

=cut

subtest 'mainte_ads_serch' => sub {
    $t->post_ok( '/root_login' => form => $login_params );
    my $msg
        = qr{\Qイベント広告検索表示画面／テーブル[ads]\E};
    $t->get_ok('/mainte_ads_serch')->status_is(200)->content_like($msg);
    $t->get_ok('/up_logout');
};

=head2 mainte_ads_new

    ads テーブルに新規レコード追加、既存レコード修正

=cut

subtest 'mainte_ads_new' => sub {

    # ログインなし
    $t->get_ok('/mainte_ads_new')->status_is(302);
    $t->header_is( Location => '/index' );

    # ログイン (編集指定 id なし 新規作成)
    $t->post_ok( '/root_login' => form => $login_params );
    $t->get_ok('/mainte_ads_new')->status_is(200);
    $t->content_like(
        qr{\Qイベント広告入力フォーム／テーブル[ads]\E});
    $t->element_exists('input[name=id][value=][type=text]');

    # 指定のレコード表示
    my $params = +{ id => 1 };
    $t->get_ok( '/mainte_ads_new' => form => $params )->status_is(200);
    $t->content_like(
        qr{\Qイベント広告入力フォーム／テーブル[ads]\E});
    $t->element_exists('input[name=id][value=1][type=text]');

    my $update_params
        = $t->app->model->mainte->ads->update_form_params( 'ads', $params );

    # url を変更
    $params = +{
        id              => $update_params->{id},
        kind            => $update_params->{kind},
        storeinfo_id    => $update_params->{storeinfo_id},
        region_id       => $update_params->{region_id},
        url             => 'http://www.henkou.com/',
        displaystart_on => $update_params->{displaystart_on},
        displayend_on   => $update_params->{displayend_on},
        name            => $update_params->{name},
        event_date      => $update_params->{event_date},
        content         => $update_params->{content},
    };
    $t->ua->max_redirects(1);
    $t->post_ok( '/mainte_ads_new' => form => $params )->status_is(200);
    $t->content_like(qr{\Q修正完了\E});
    $t->content_like(qr{\Qhttp://www.henkou.com/\E});
    $t->get_ok('/up_logout');
};

done_testing();

__END__
