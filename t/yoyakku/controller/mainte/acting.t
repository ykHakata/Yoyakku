use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN {
    use_ok('Yoyakku::Controller::Mainte::Acting') || print "Bail out!\n";
}

my $t            = Test::Mojo->new('Yoyakku');
my $config       = $t->app->config;
my $login_params = $config->{mainte}->{login_account};
$t->app->commands->start_app( 'Yoyakku', 'init_db', );

=head2 method

    オブジェクト、メソッド存在確認

=cut

subtest 'method' => sub {
    my $obj = Yoyakku::Controller::Mainte::Acting->new();
    isa_ok( $obj, 'Yoyakku::Controller::Mainte::Acting' );

    my @methods = qw{index mainte_acting_serch mainte_acting_new _insert
        _update _common _render_acting};

    can_ok( $obj, @methods );
};

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

subtest 'index' => sub {

    # get, post 以外は トップページにリダイレクト
    $t->head_ok('/mainte_acting_serch')->status_is(302);
    $t->head_ok('/mainte_acting_new')->status_is(302);
    $t->header_is( Location => '/index' );

    # ログインセッション無き場合トップページ
    $t->get_ok('/mainte_acting_serch')->status_is(302);
    $t->get_ok('/mainte_acting_new')->status_is(302);
    $t->header_is( Location => '/index' );
};

=head2 mainte_acting_serch

    acting テーブル登録情報の確認、検索

=cut

subtest 'mainte_acting_serch' => sub {
    $t->post_ok( '/root_login' => form => $login_params );
    my $msg = qr{\Q代行リスト／テーブル[acting]\E};
    $t->get_ok('/mainte_acting_serch')->status_is(200)->content_like($msg);
    $t->get_ok('/up_logout');
};

=head2 mainte_acting_new

    acting テーブルに新規レコード追加、既存レコード修正

=cut

subtest 'mainte_acting_new' => sub {

    # ログインなし
    $t->get_ok('/mainte_acting_new')->status_is(302);
    $t->header_is( Location => '/index' );

    # ログイン (編集指定 id なし 新規作成)
    $t->post_ok( '/root_login' => form => $login_params );
    $t->get_ok('/mainte_acting_new')->status_is(200);
    $t->content_like(qr{\Q代行リスト／テーブル[acting]\E});
    $t->element_exists('input[name=id][value=][type=text]');

    # 指定のレコード表示
    my $params = +{ id => 2 };
    $t->get_ok( '/mainte_acting_new' => form => $params )->status_is(200);
    $t->content_like(qr{\Q代行リスト／テーブル[acting]\E});
    $t->element_exists('input[name=id][value=2][type=text]');

    my $update_params
        = $t->app->model->mainte->acting->update_form_params( 'acting',
        $params );

    # storeinfo_id を変更
    $params = +{
        id           => $update_params->{id},
        general_id   => $update_params->{general_id} || undef,
        storeinfo_id => 2,
        status       => $update_params->{status},
    };
    $t->ua->max_redirects(1);
    $t->post_ok( '/mainte_acting_new' => form => $params )->status_is(200);
    $t->content_like(qr{\Q修正完了\E});
    $t->content_like(qr{\Q2\E});
    $t->get_ok('/up_logout');
};

done_testing();

__END__
