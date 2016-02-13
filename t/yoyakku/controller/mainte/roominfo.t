use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN { use_ok('Yoyakku::Controller::Mainte::Roominfo') || print "Bail out!\n"; }

my $t      = Test::Mojo->new('Yoyakku');
my $config = $t->app->config;

=head2 method

    オブジェクト、メソッド存在確認

=cut

subtest 'method' => sub {
    my $obj = Yoyakku::Controller::Mainte::Roominfo->new();
    isa_ok( $obj, 'Yoyakku::Controller::Mainte::Roominfo' );

    my @methods = qw{mainte_roominfo_serch mainte_roominfo_new _update
        _common _render_roominfo};

    can_ok( $obj, @methods );
};

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

subtest 'index' => sub {

    # リクエスト確認 get, post 以外は トップページにリダイレクト
    $t->head_ok('/mainte_roominfo_serch')->status_is(302);
    $t->head_ok('/mainte_roominfo_new')->status_is(302);
    is($t->tx->res->headers->location, 'index', 'location ok');

    # ログインセッション無き場合トップページにリダイレクト
    $t->get_ok('/mainte_roominfo_serch')->status_is(302);
    $t->get_ok('/mainte_roominfo_new')->status_is(302);
    is($t->tx->res->headers->location, 'index', 'location ok');
};

=head2 mainte_roominfo_serch

    roominfo テーブル登録情報の確認、検索

=cut

subtest 'mainte_roominfo_serch' => sub {
    test_login($t);
    my $msg = qr{\Q部屋情報設定／テーブル[roominfo]\E};
    $t->get_ok('/mainte_roominfo_serch')->status_is(200)->content_like($msg);
    test_logout($t);
};

=head2 mainte_roominfo_new

    roominfo テーブル指定のレコードの修正画面 (更新のみ、新規は storeinfo)

=cut

subtest 'mainte_roominfo_new' => sub {

    # ログインなし
    $t->get_ok('/mainte_roominfo_new')->status_is(302);
    is($t->tx->res->headers->location, 'index', 'location ok');

    # ログイン (編集指定 id なし)
    test_login($t);
    $t->get_ok('/mainte_roominfo_new')->status_is(302);
    is($t->tx->res->headers->location, 'mainte_roominfo_serch', 'location ok');

    # 指定のレコード表示
    my $params = +{id => 1};
    $t->get_ok('/mainte_roominfo_new' => form => $params)->status_is(200);
    $t->element_exists('input[name=id][value=1][type=text]');

    # 部屋名を変更
    $params = +{
        id            => 1,
        name          => 'AB',
        starttime_on  => '10:00:00',
        endingtime_on => '22:00:00'
    };
    $t->ua->max_redirects(1);
    $t->post_ok('/mainte_roominfo_new' => form => $params)->status_is(200);
    $t->content_like(qr{\Q修正完了\E});
    $t->content_like(qr{\QAB\E});
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
