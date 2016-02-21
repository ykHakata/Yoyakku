use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN { use_ok('Yoyakku') || print "Bail out!\n"; }

my $t            = Test::Mojo->new('Yoyakku');
my $config       = $t->app->config;
my $login_params = $config->{mainte}->{login_account};
$t->app->commands->start_app( 'Yoyakku', 'init_db', );

subtest 'plugin conf' => sub {
    my $conf = $t->app->config;
    ok( exists $conf->{db}, 'config check' );
};

subtest 'helper method' => sub {
    my $class_args = +{
        model_mainte_acting    => 'Yoyakku::Model::Mainte::Acting',
        model_mainte_admin     => 'Yoyakku::Model::Mainte::Admin',
        model_mainte_ads       => 'Yoyakku::Model::Mainte::Ads',
        model_mainte_general   => 'Yoyakku::Model::Mainte::General',
        model_mainte_post      => 'Yoyakku::Model::Mainte::Post',
        model_mainte_profile   => 'Yoyakku::Model::Mainte::Profile',
        model_mainte_region    => 'Yoyakku::Model::Mainte::Region',
        model_mainte_reserve   => 'Yoyakku::Model::Mainte::Reserve',
        model_mainte_roominfo  => 'Yoyakku::Model::Mainte::Roominfo',
        model_mainte_storeinfo => 'Yoyakku::Model::Mainte::Storeinfo',
        model_calendar         => 'Yoyakku::Model::Calendar',
        model_auth             => 'Yoyakku::Model::Auth',
        model_mainte           => 'Yoyakku::Model::Mainte',
        model_entry            => 'Yoyakku::Model::Entry',
    };

    my @model_methods = qw{params session method html login_row login_table
        login_name profile_row storeinfo_row template type flash_msg acting_rows
        mail_temp mail_header mail_body login_storeinfo_row login_roominfo_rows
        yoyakku_conf model_stash};

    while ( my ( $method, $class, ) = each %{$class_args} ) {
        my $model = $t->app->build_controller->$method;
        isa_ok( $model, $class );
        can_ok( $model, @model_methods );
    }

    # model 値を保時
    while ( my ( $method, $class, ) = each %{$class_args} ) {
        my $model = $t->app->build_controller->$method;

        my $model_method = 'model_stash';

        $model->$model_method('stash tast');
        is( $model->$model_method, 'stash tast', "$method method test" );

        $model = $t->app->build_controller->$method;
        is( $model->$model_method, 'stash tast', "$method method test try" );
    }
};

subtest 'namespaces commands' => sub {
    my $namespaces = $t->app->commands->namespaces;
    my @names      = qw{Mojolicious::Command Yoyakku::Command};

    for my $name ( @{$namespaces} ) {
        my $ok = grep { $name eq $_ } @names;
        my $label = $name . ' namespaces ok!';
        ok( $ok, $label );
    }
};

subtest 'router' => sub {

    # 302リダイレクトレスポンスの許可
    $t->ua->max_redirects(1);

    my @url_collection = (
        '/',
        '/up_login',
        '/up_login_general',
        '/up_login_admin',
        '/root_login',
        '/up_logout',
        # '/profile',
        # '/profile_comp',
        '/mainte_list',
        '/mainte_registrant_serch',
        '/mainte_registrant_new',
        '/mainte_general_serch',
        '/mainte_general_new',
        '/mainte_profile_serch',
        '/mainte_profile_new',
        '/mainte_storeinfo_serch',
        '/mainte_storeinfo_new',
        '/mainte_roominfo_serch',
        '/mainte_roominfo_new',
        '/mainte_reserve_serch',
        '/mainte_reserve_new',
        '/mainte_acting_serch',
        '/mainte_acting_new',
        '/mainte_ads_serch',
        '/mainte_ads_new',
        '/mainte_region_serch',
        '/mainte_region_new',
        '/mainte_post_serch',
        '/mainte_post_new',
        '/index',
        '/index_next_m',
        '/index_next_two_m',
        '/index_next_three_m',
        '/entry',
        # '/region_state',
        # '/admin_store_edit',
        # '/admin_store_comp',
        # '/admin_reserv_edit',
        # '/up_admin_r_d_edit',
    );

    for my $url (@url_collection) {
        $t->get_ok($url)->status_is(200);
    }
};

subtest 'session name' => sub {
    my $session_name = $t->app->sessions->cookie_name;
    is( $session_name, 'yoyakku', 'session name ok!!' );
};

done_testing();

__END__
