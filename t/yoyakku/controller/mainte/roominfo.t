use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN {
    use_ok('Yoyakku::Controller::Mainte::Roominfo') || print "Bail out!\n";
}

my $t            = Test::Mojo->new('Yoyakku');
my $config       = $t->app->config;
my $login_params = $config->{mainte}->{login_account};
$t->app->commands->start_app( 'Yoyakku', 'init_db', );

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
    $t->header_is( Location => 'index' );

# ログインセッション無き場合トップページにリダイレクト
    $t->get_ok('/mainte_roominfo_serch')->status_is(302);
    $t->get_ok('/mainte_roominfo_new')->status_is(302);
    $t->header_is( Location => 'index' );
};

=head2 mainte_roominfo_serch

    roominfo テーブル登録情報の確認、検索

=cut

subtest 'mainte_roominfo_serch' => sub {
    $t->post_ok( '/root_login' => form => $login_params );
    my $msg = qr{\Q部屋情報設定／テーブル[roominfo]\E};
    $t->get_ok('/mainte_roominfo_serch')->status_is(200)->content_like($msg);
    $t->get_ok('/up_logout');
};

=head2 mainte_roominfo_new

    roominfo テーブル指定のレコードの修正画面 (更新のみ、新規は storeinfo)

=cut

subtest 'mainte_roominfo_new' => sub {

    # ログインなし
    $t->get_ok('/mainte_roominfo_new')->status_is(302);
    $t->header_is( Location => 'index' );

    # ログイン (編集指定 id なし)
    $t->post_ok( '/root_login' => form => $login_params );
    $t->get_ok('/mainte_roominfo_new')->status_is(302);
    is( $t->tx->res->headers->location,
        'mainte_roominfo_serch', 'location ok' );

    # 指定のレコード表示
    my $params = +{ id => 1 };
    $t->get_ok( '/mainte_roominfo_new' => form => $params )->status_is(200);
    $t->element_exists('input[name=id][value=1][type=text]');

    my $update_params
        = $t->app->model_mainte_roominfo->update_form_params( 'roominfo',
        $params );

    # 部屋名を変更
    $params = +{
        id                => $update_params->{id},
        storeinfo_id      => $update_params->{storeinfo_id} || undef,
        name              => 'AB',
        starttime_on      => $update_params->{starttime_on},
        endingtime_on     => $update_params->{endingtime_on},
        rentalunit        => $update_params->{rentalunit},
        time_change       => $update_params->{time_change},
        pricescomments    => $update_params->{pricescomments},
        privatepermit     => $update_params->{privatepermit},
        privatepeople     => $update_params->{privatepeople},
        privateconditions => $update_params->{privateconditions},
        bookinglimit      => $update_params->{bookinglimit},
        cancellimit       => $update_params->{cancellimit},
        remarks           => $update_params->{remarks},
        webpublishing     => $update_params->{webpublishing},
        webreserve        => $update_params->{webreserve},
        status            => $update_params->{status},
    };
    $t->ua->max_redirects(1);
    $t->post_ok( '/mainte_roominfo_new' => form => $params )->status_is(200);
    $t->content_like(qr{\Q修正完了\E});
    $t->content_like(qr{\QAB\E});
    $t->get_ok('/up_logout');
};

done_testing();

__END__
