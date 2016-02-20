use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN {
    use_ok('Yoyakku::Controller::Mainte') || print "Bail out!\n";
}

my $t             = Test::Mojo->new('Yoyakku');
my $config        = $t->app->config;
my $login_admin   = $config->{site}->{login_account}->{admin};
my $login_general = $config->{site}->{login_account}->{general};
my $login_root    = $config->{mainte}->{login_account};
$t->app->commands->start_app( 'Yoyakku', 'init_db', );

=encoding utf8

=head2 method

    オブジェクト、メソッド存在確認

=cut

subtest 'method' => sub {
    my $obj = Yoyakku::Controller::Mainte->new();
    isa_ok( $obj, 'Yoyakku::Controller::Mainte' );

    my @methods = qw{index mainte_list};

    can_ok( $obj, @methods );
};

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

subtest 'index' => sub {

    my @to_index = ( Location => 'index' );

    # get, post 以外は トップページにリダイレクト
    $t->head_ok('/mainte_list')->status_is(302)->header_is(@to_index);

    # ログインなしアクセス
    $t->get_ok('/mainte_list')->status_is(302)->header_is(@to_index);
};

=head2 mainte_list

    システム管理のオープニング画面

=cut

subtest 'mainte_list' => sub {

    my @to_index = ( Location => 'index' );

    subtest 'success' => sub {
        $t->post_ok( '/root_login' => form => $login_root );

        $t->get_ok('/mainte_list')->status_is(200)
            ->content_type_is('text/html;charset=UTF-8')
            ->text_is( 'html head title' => 'yoyakkuデータ管理' )
            ->content_like(qr{\Q地域区分マスタ\E})
            ->content_like(qr{\Q郵便番号マスタ\E})
            ->content_like(qr{\Q店舗情報\E})
            ->content_like(qr{\Q部屋情報設定\E})
            ->content_like(qr{\Q予約履歴\E})
            ->content_like(qr{\Q広告\E})
            ->content_like(qr{\Q管理ユーザー\E})
            ->content_like(qr{\Q一般ユーザー\E})
            ->content_like(qr{\Q個人情報\E});

        $t->get_ok('/up_logout');
    };
};

done_testing();

__END__
