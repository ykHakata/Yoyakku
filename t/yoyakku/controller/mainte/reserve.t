use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN {
    use_ok('Yoyakku::Controller::Mainte::Reserve') || print "Bail out!\n";
}

my $t            = Test::Mojo->new('Yoyakku');
my $config       = $t->app->config;
my $login_params = $config->{mainte}->{login_account};
$t->app->commands->start_app( 'Yoyakku', 'init_db', );

=head2 method

    オブジェクト、メソッド存在確認

=cut

subtest 'method' => sub {
    my $obj = Yoyakku::Controller::Mainte::Reserve->new();
    isa_ok( $obj, 'Yoyakku::Controller::Mainte::Reserve' );

    my @methods = qw{index mainte_reserve_serch mainte_reserve_new _insert
        _update _common _render_reserve};

    can_ok( $obj, @methods );
};

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

subtest 'index' => sub {

    # get, post 以外は トップページにリダイレクト
    $t->head_ok('/mainte_reserve_serch')->status_is(302);
    $t->head_ok('/mainte_reserve_new')->status_is(302);
    $t->header_is( Location => 'index' );

    # ログインセッション無き場合トップページ
    $t->get_ok('/mainte_reserve_serch')->status_is(302);
    $t->get_ok('/mainte_reserve_new')->status_is(302);
    $t->header_is( Location => 'index' );
};

=head2 mainte_reserve_serch

    reserve テーブル登録情報の確認、検索

=cut

subtest 'mainte_reserve_serch' => sub {
    $t->post_ok( '/root_login' => form => $login_params );
    my $msg = qr{\Q予約履歴／テーブル[reserve]\E};
    $t->get_ok('/mainte_reserve_serch')->status_is(200)->content_like($msg);
    $t->get_ok('/up_logout');
};

=head2 mainte_reserve_new

    reserve テーブルに新規レコード追加、既存レコード修正

=cut

subtest 'mainte_reserve_new' => sub {

    # ログインなし
    $t->get_ok('/mainte_reserve_new')->status_is(302);
    $t->header_is( Location => 'index' );

    # ログイン (編集指定 id なし かつ roominfo_id なし)
    $t->post_ok( '/root_login' => form => $login_params );
    $t->get_ok('/mainte_reserve_new')->status_is(302);
    $t->header_is( Location => '/mainte_reserve_serch' );

    # ログイン (roominfo_id あり 新規作成)
    my $params = +{ roominfo_id => 2 };
    $t->get_ok( '/mainte_reserve_new' => form => $params )->status_is(200);
    $t->content_like(
        qr{\Q予約履歴入力フォーム／テーブル[reserve]\E});
    $t->element_exists('input[name=id][value=][type=text]');

    # 指定のレコード表示
    $params = +{ id => 1 };
    $t->get_ok( '/mainte_reserve_new' => form => $params )->status_is(200);
    $t->content_like(
        qr{\Q予約履歴入力フォーム／テーブル[reserve]\E});
    $t->element_exists('input[name=id][value=1][type=text]');

    my $update_params
        = $t->app->model->mainte->reserve->update_form_params( 'reserve',
        $params );

    # tel を変更
    $params = +{
        id                 => $update_params->{id},
        roominfo_id        => $update_params->{roominfo_id},
        getstarted_on_day  => $update_params->{getstarted_on_day},
        enduse_on_day      => $update_params->{enduse_on_day},
        getstarted_on_time => $update_params->{getstarted_on_time},
        enduse_on_time     => $update_params->{enduse_on_time},
        getstarted_on_day  => $update_params->{getstarted_on_day},
        enduse_on_day      => $update_params->{enduse_on_day},
        useform            => $update_params->{useform},
        message            => $update_params->{message},
        general_id         => $update_params->{general_id},
        admin_id           => $update_params->{admin_id},
        tel                => '080-0909-0909',
        status             => $update_params->{status},
    };
    $t->ua->max_redirects(1);
    $t->post_ok( '/mainte_reserve_new' => form => $params )->status_is(200);
    $t->content_like(qr{\Q修正完了\E});
    $t->content_like(qr{\Q080-0909-0909\E});
    $t->get_ok('/up_logout');
};

done_testing();

__END__
