use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN {
    use_ok('Yoyakku::Controller::Mainte::Storeinfo') || print "Bail out!\n";
}

my $t            = Test::Mojo->new('Yoyakku');
my $config       = $t->app->config;
my $login_params = $config->{mainte}->{login_account};
$t->app->commands->start_app( 'Yoyakku', 'init_db', );

=head2 method

    オブジェクト、メソッド存在確認

=cut

subtest 'method' => sub {
    my $obj = Yoyakku::Controller::Mainte::Storeinfo->new();
    isa_ok( $obj, 'Yoyakku::Controller::Mainte::Storeinfo' );

    my @methods = qw{mainte_storeinfo_serch mainte_storeinfo_new _update
        _common _render_storeinfo};

    can_ok( $obj, @methods );
};

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

subtest 'index' => sub {

    # get, post 以外は トップページにリダイレクト
    $t->head_ok('/mainte_storeinfo_serch')->status_is(302);
    $t->head_ok('/mainte_storeinfo_new')->status_is(302);
    $t->header_is( Location => 'index' );

    # ログインセッション無き場合トップページ
    $t->get_ok('/mainte_storeinfo_serch')->status_is(302);
    $t->get_ok('/mainte_storeinfo_new')->status_is(302);
    $t->header_is( Location => 'index' );
};

=head2 mainte_storeinfo_serch

    storeinfo テーブル登録情報の確認、検索

=cut

subtest 'mainte_storeinfo_serch' => sub {
    $t->post_ok( '/root_login' => form => $login_params );
    my $msg = qr{\Q店舗情報／テーブル[storeinfo]\E};
    $t->get_ok('/mainte_storeinfo_serch')->status_is(200)->content_like($msg);
    $t->get_ok('/up_logout');
};

=head2 mainte_storeinfo_new

    storeinfo テーブル指定のレコードの修正画面 (更新のみ、新規は admin 承認時)

=cut

subtest 'mainte_storeinfo_new' => sub {

    # ログインなし
    $t->get_ok('/mainte_storeinfo_new')->status_is(302);
    $t->header_is( Location => 'index' );

    # ログイン (編集指定 id なし)
    $t->post_ok( '/root_login' => form => $login_params );
    $t->get_ok('/mainte_storeinfo_new')->status_is(302);
    is( $t->tx->res->headers->location,
        'mainte_storeinfo_serch', 'location ok' );

    # 指定のレコード表示
    my $params = +{ id => 1 };
    $t->get_ok( '/mainte_storeinfo_new' => form => $params )->status_is(200);
    $t->element_exists('input[name=id][value=1][type=text]');

    # 郵便番号検索ボタンが押されたときの処理
    my @input_values = (
        'input[name=id][value=1][type=text]',
        'input[name=post][value=8120043][type=text]',
        'input[name=state][value=福岡県][type=text]',
        'input[name=cities][value=福岡市博多区][type=text]',
        'input[name=addressbelow][value=][type=text]',
    );
    $params = +{ id => 1, kensaku => '検索する', post => '8120043', };
    $t->post_ok( '/mainte_storeinfo_new' => form => $params )->status_is(200);
    for my $input (@input_values) {
        $t->element_exists($input);
    }

    my $update_params
        = $t->app->model_mainte_storeinfo->update_form_params( 'storeinfo',
        $params );

    # 店舗名を変更
    $params = +{
        id            => 1,
        region_id     => $update_params->{region_id} || undef,
        admin_id      => $update_params->{admin_id} || undef,
        name          => 'テスト店舗名',
        icon          => $update_params->{icon},
        post          => $update_params->{post},
        state         => $update_params->{state},
        cities        => $update_params->{cities},
        addressbelow  => $update_params->{addressbelow},
        tel           => $update_params->{tel},
        mail          => $update_params->{mail},
        remarks       => $update_params->{remarks},
        url           => $update_params->{url},
        locationinfor => $update_params->{locationinfor},
        status        => $update_params->{status},
    };
    $t->ua->max_redirects(1);
    $t->post_ok( '/mainte_storeinfo_new' => form => $params )->status_is(200);
    $t->content_like(qr{\Q修正完了\E});
    $t->content_like(qr{\Qテスト店舗名\E});
    $t->get_ok('/up_logout');
};

done_testing();

__END__
