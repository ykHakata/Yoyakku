use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN { use_ok('Yoyakku::Model::Base') || print "Bail out!\n"; }

my $t            = Test::Mojo->new('Yoyakku');
my $config       = $t->app->config;
my $login_params = $config->{mainte}->{login_account};
$t->app->commands->start_app( 'Yoyakku', 'init_db', );

=head2 method

    オブジェクト、メソッド存在確認

=cut

subtest 'method' => sub {
    my $obj = Yoyakku::Model::Base->new();
    isa_ok( $obj, 'Yoyakku::Model::Base' );

    my @methods = qw{login logged_in get_login_row get_logged_in_row login};

    can_ok( $obj, @methods );
};

=head2 get_login_row

    ログイン情報の取得
    成功 -> DB の teng row オブジェクトを返却
    失敗 -> 未定義(undef)

=cut

subtest 'get_login_row' => sub {
    my $obj = Yoyakku::Model::Base->new( +{ yoyakku_conf => $config } );

    my $session = +{};

    subtest 'success' => sub {
        $session = +{ session_admin_id => 1, };
        my $login_row = $obj->get_login_row($session);
        isa_ok( $login_row, 'Yoyakku::DB::Row::Admin' );
        is( $login_row->id, 1, 'id' );
    };

    subtest 'fail' => sub {
        $session = +{ session_admin_id => 0, };
        my $login_row = $obj->get_login_row($session);
        is( $login_row, undef, 'not login_row' );
    };
};

=head2 logged_in

    セッション確認によるログイン機能
    成功 -> 1
    失敗 -> 未定義(undef)

=cut

subtest 'logged_in' => sub {
    my $obj = Yoyakku::Model::Base->new( +{ yoyakku_conf => $config } );
    my $session = +{};

    subtest 'success' => sub {
        $session = +{ session_admin_id => 1, };
        my $logged_in = $obj->logged_in($session);
        is( $logged_in, 1,'logged_in ok' );
    };

    subtest 'fail' => sub {
        $session = +{ session_admin_id => 0, };
        my $logged_in = $obj->logged_in($session);
        is( $logged_in, undef, 'not logged_in' );
    };
};

=head2 get_logged_in_row

    セッション確認からログイン情報取得
    成功 -> ログイン中の row オブジェクト返却
    失敗 -> 未定義(undef)

=cut

subtest 'get_logged_in_row' => sub {
    my $obj = Yoyakku::Model::Base->new( +{ yoyakku_conf => $config } );
    my $session = +{};

    subtest 'success' => sub {
        $session = +{ session_admin_id => 1, };
        my $logged_in_row = $obj->get_logged_in_row($session);
        isa_ok( $logged_in_row, 'Yoyakku::DB::Row::Admin' );
        is( $logged_in_row->id, 1, 'id' );
    };

    subtest 'fail' => sub {
        $session = +{ session_admin_id => 0, };
        my $logged_in_row = $obj->get_logged_in_row($session);
        is( $logged_in_row, undef, 'not logged_in_row' );
    };
};

=head2 login

    テキスト入力フォームによるログイン機能
    成功 -> ログイン成功の row オブジェクト返却
    失敗 -> 1 (id が存在しない), 2 (password が存在しない)

=cut

subtest 'login' => sub {
    my $obj = Yoyakku::Model::Base->new( +{ yoyakku_conf => $config } );
    my $args = +{};

    subtest 'success' => sub {
        $args = +{
            table    => 'admin',
            login    => 'yoyakku@gmail.com',
            password => 'yoyakku'
        };
        my $login_row = $obj->login($args);
        isa_ok( $login_row, 'Yoyakku::DB::Row::Admin' );
        is( $login_row->login, 'yoyakku@gmail.com', 'login' );
    };

    subtest 'fail not id' => sub {
        $args = +{ table => 'admin', login => 'MR', password => 'yoyakku' };
        my $login_row = $obj->login($args);
        is( $login_row, 1, 'not id' );
    };

    subtest 'fail not password' => sub {
        $args = +{
            table    => 'admin',
            login    => 'yoyakku@gmail.com',
            password => 'MR'
        };
        my $login_row = $obj->login($args);
        is( $login_row, 2, 'not password' );
    };
};

done_testing();

__END__
