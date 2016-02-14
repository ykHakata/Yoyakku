use Mojo::Base -strict;

use open ':std', ':encoding(utf8)';
use Test::More;
use Test::Mojo;
use Data::Dumper;
$ENV{MOJO_MODE} = 'testing';

BEGIN {
    use_ok('Yoyakku::Controller::Mainte::Post') || print "Bail out!\n";
}

my $t            = Test::Mojo->new('Yoyakku');
my $config       = $t->app->config;
my $login_params = $config->{mainte}->{login_account};
$t->app->commands->start_app( 'Yoyakku', 'init_db', );

=head2 method

    オブジェクト、メソッド存在確認

=cut

subtest 'method' => sub {
    my $obj = Yoyakku::Controller::Mainte::Post->new();
    isa_ok( $obj, 'Yoyakku::Controller::Mainte::Post' );

    my @methods = qw{index mainte_post_serch};

    can_ok( $obj, @methods );
};

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

subtest 'index' => sub {

    # get, post 以外は トップページにリダイレクト
    $t->head_ok('/mainte_post_serch')->status_is(302);
    $t->head_ok('/mainte_post_new')->status_is(302);
    $t->header_is( Location => 'index' );

    # ログインセッション無き場合トップページ
    $t->get_ok('/mainte_post_serch')->status_is(302);
    $t->get_ok('/mainte_post_new')->status_is(302);
    $t->header_is( Location => 'index' );
};

=head2 mainte_post_serch

    post テーブル登録情報の確認、検索

=cut

subtest 'mainte_post_serch' => sub {
    $t->post_ok( '/root_login' => form => $login_params );
    my $msg = qr{\Q郵便番号マスター／テーブル[post]\E};
    $t->get_ok('/mainte_post_serch')->status_is(200)->content_like($msg);
    $t->get_ok('/up_logout');
};

=head2 mainte_post_new

    post テーブルに新規レコード追加、既存レコード修正

=cut

subtest 'mainte_post_new' => sub {

    # ログインなし
    $t->get_ok('/mainte_post_new')->status_is(302);
    $t->header_is( Location => 'index' );

    # noteログイン (編集指定 id なし 新規作成)
    $t->post_ok( '/root_login' => form => $login_params );
    $t->get_ok('/mainte_post_new')->status_is(302);
    $t->header_is( Location => 'mainte_list' );
    note(
        'mainte_post_new は未実装につき、現状は mainte_list へリダイレクト'
    );
    $t->get_ok('/up_logout');
};

done_testing();

__END__
