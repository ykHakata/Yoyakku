use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN {
    use_ok('Yoyakku::Controller::Mainte::Admin') || print "Bail out!\n";
}

my $t      = Test::Mojo->new('Yoyakku');
my $config = $t->app->config;

=head2 method

    オブジェクト、メソッド存在確認

=cut

subtest 'method' => sub {
    my $obj = Yoyakku::Controller::Mainte::Admin->new();
    isa_ok( $obj, 'Yoyakku::Controller::Mainte::Admin' );

    my @methods = qw{mainte_registrant_serch mainte_registrant_new
        _insert _update _common _render_registrant};

    can_ok( $obj, @methods );
};

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

subtest 'index' => sub {

    # get, post 以外は トップページにリダイレクト
    $t->head_ok('/mainte_registrant_serch')->status_is(302);
    $t->head_ok('/mainte_registrant_new')->status_is(302);
    is( $t->tx->res->headers->location, 'index', 'location ok' );

    # ログインセッション無き場合トップページ
    $t->get_ok('/mainte_registrant_serch')->status_is(302);
    $t->get_ok('/mainte_registrant_new')->status_is(302);
    is( $t->tx->res->headers->location, 'index', 'location ok' );
};

=head2 mainte_registrant_serch

    admin テーブル登録情報の確認、検索

=cut

subtest 'mainte_registrant_serch' => sub {
    test_login($t);
    my $msg = qr{\Q管理ユーザー／テーブル[admin]\E};
    $t->get_ok('/mainte_registrant_serch')->status_is(200)->content_like($msg);
    test_logout($t);
};

=head2 mainte_registrant_new

    admin テーブルに新規レコード追加、既存レコード修正

=cut

subtest 'mainte_registrant_new' => sub {

    # ログインなし
    $t->get_ok('/mainte_registrant_new')->status_is(302);
    is( $t->tx->res->headers->location, 'index', 'location ok' );

    # ログイン (編集指定 id なし 新規作成)
    test_login($t);
    $t->get_ok('/mainte_registrant_new')->status_is(200);
    $t->content_like(qr{\Q管理ユーザー／テーブル[admin]\E});
    $t->element_exists('input[name=id][value=][type=text]');

    # 指定のレコード表示
    my $params = +{ id => 2 };
    $t->get_ok( '/mainte_registrant_new' => form => $params )->status_is(200);
    $t->content_like(qr{\Q管理ユーザー／テーブル[admin]\E});
    $t->element_exists('input[name=id][value=2][type=text]');

    my $update_params
        = $t->app->model_mainte_admin->update_form_params( 'admin', $params );

    # password を変更
    $params = +{
        id       => $update_params->{id},
        login    => $update_params->{login},
        password => 'testpass',
    };
    $t->ua->max_redirects(1);
    $t->post_ok( '/mainte_registrant_new' => form => $params )->status_is(200);
    $t->content_like(qr{\Q修正完了\E});
    $t->content_like(qr{\Qtestpass\E});
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
