use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN {
    use_ok('Yoyakku::Controller::Region') || print "Bail out!\n";
}

my $t             = Test::Mojo->new('Yoyakku');
my $config        = $t->app->config;
my $login_admin   = $config->{site}->{login_account}->{admin};
my $login_general = $config->{site}->{login_account}->{general};
my $login_root    = $config->{mainte}->{login_account};
$t->app->commands->run('init_db');

=encoding utf8

=head2 method

    オブジェクト、メソッド存在確認

=cut

subtest 'method' => sub {
    my $obj = Yoyakku::Controller::Region->new();
    isa_ok( $obj, 'Yoyakku::Controller::Region' );

    my @methods = qw{index region_state};

    can_ok( $obj, @methods );
};

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

subtest 'index' => sub {

    my @to_index = ( Location => '/index' );

    # get, post 以外は トップページにリダイレクト
    $t->head_ok('/region_state')->status_is(302)->header_is(@to_index);

    # ログインなしアクセス
    $t->get_ok('/region_state')->status_is(200);
};

=head2 region_state

    予約の為のスタジオ検索(地域)

=cut

subtest 'region_state' => sub {

    my @to_index = ( Location => '/index' );

    subtest 'success' => sub {

        # ログイン (admin)
        $t->post_ok( '/up_login_admin' => form => $login_admin )
            ->status_is(302)->header_is(@to_index);

        $t->get_ok('/region_state')->status_is(200)
            ->content_type_is('text/html;charset=UTF-8')
            ->text_is( 'html head title' => 'yoyakku予約検索' )
            ->content_like(qr{\Q(admin)スタジオヨヤック\E});

        $t->get_ok('/up_logout')->status_is(200);

        # ログイン (general)
        $t->post_ok( '/up_login_general' => form => $login_general )
            ->status_is(302)->header_is(@to_index);

        $t->get_ok('/region_state')->status_is(200)
            ->content_type_is('text/html;charset=UTF-8')
            ->text_is( 'html head title' => 'yoyakku予約検索' )
            ->content_like(qr{\Qふくしま\E});

        $t->get_ok('/up_logout')->status_is(200);

        # ログインなし
        $t->get_ok('/region_state')->status_is(200)
            ->content_type_is('text/html;charset=UTF-8')
            ->text_is( 'html head title' => 'yoyakku予約検索' );
    };

    # subtest 'fail' => sub {
    # };
};

done_testing();

__END__
