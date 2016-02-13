use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN {
    use_ok('Yoyakku::Controller::Mainte::Ads') || print "Bail out!\n";
}

my $t      = Test::Mojo->new('Yoyakku');
my $config = $t->app->config;

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
    is( $t->tx->res->headers->location, 'index', 'location ok' );

    # ログインセッション無き場合トップページ
    $t->get_ok('/mainte_ads_serch')->status_is(302);
    $t->get_ok('/mainte_ads_new')->status_is(302);
    is( $t->tx->res->headers->location, 'index', 'location ok' );
};

=head2 mainte_ads_serch

    ads テーブル登録情報の確認、検索

=cut

subtest 'mainte_ads_serch' => sub {
    test_login($t);
    my $msg = qr{\Qイベント広告検索表示画面／テーブル[ads]\E};
    $t->get_ok('/mainte_ads_serch')->status_is(200)->content_like($msg);
    test_logout($t);
};

=head2 mainte_ads_new

    ads テーブルに新規レコード追加、既存レコード修正

=cut

subtest 'mainte_ads_new' => sub {

    # ログインなし
    $t->get_ok('/mainte_ads_new')->status_is(302);
    is( $t->tx->res->headers->location, 'index', 'location ok' );

    # ログイン (編集指定 id なし 新規作成)
    test_login($t);
    $t->get_ok('/mainte_ads_new')->status_is(200);
    $t->content_like(qr{\Qイベント広告入力フォーム／テーブル[ads]\E});
    $t->element_exists('input[name=id][value=][type=text]');

    # 指定のレコード表示
    my $params = +{ id => 2 };
    $t->get_ok( '/mainte_ads_new' => form => $params )->status_is(200);
    $t->content_like(qr{\Qイベント広告入力フォーム／テーブル[ads]\E});
    $t->element_exists('input[name=id][value=2][type=text]');

    my $update_params
        = $t->app->model_mainte_ads->update_form_params( 'ads', $params );

    # url を変更
    $params = +{
        id              => $update_params->{id},
        url             => 'http://www.henkou.com/',
        displaystart_on => $update_params->{displaystart_on},
        displayend_on   => $update_params->{displayend_on},
        name            => $update_params->{name},
        content         => $update_params->{content},
        event_date      => $update_params->{event_date},
    };
    $t->ua->max_redirects(1);
    $t->post_ok( '/mainte_ads_new' => form => $params )->status_is(200);
    $t->content_like(qr{\Q修正完了\E});
    $t->content_like(qr{\Qhttp://www.henkou.com/\E});
    test_logout($t);
};

sub test_login {
    my $self  = shift;
    my $login = +{
        url    => '/root_login',
        params => +{ login => 'yoyakku', password => '0520' },
    };
    $self->post_ok( $login->{url} => form => $login->{params} );
    return $self;
}

sub test_logout {
    my $self = shift;
    $self->get_ok('/up_logout');
    return $self;
}

done_testing();

__END__
