use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN { use_ok('Yoyakku') || print "Bail out!\n"; }

my $t = Test::Mojo->new('Yoyakku');

subtest 'plugin conf' => sub {
    my $conf = $t->app->config;
    ok( exists $conf->{db}, 'config check' );
};

subtest 'helper method' => sub {
    my $class_args = [
        +{  method => 'model_calendar',
            class  => 'Yoyakku::Model::Calendar',
        },
        +{  method => 'model_mainte_roominfo',
            class  => 'Yoyakku::Model::Mainte::Roominfo',
        },
        +{  method => 'model_mainte_storeinfo',
            class  => 'Yoyakku::Model::Mainte::Storeinfo',
        },
        +{  method => 'model_mainte_profile',
            class  => 'Yoyakku::Model::Mainte::Profile',
        },
        +{  method => 'model_mainte_general',
            class  => 'Yoyakku::Model::Mainte::General',
        },
        +{  method => 'model_mainte_admin',
            class  => 'Yoyakku::Model::Mainte::Admin',
        },
        +{  method => 'model_mainte_ads',
            class  => 'Yoyakku::Model::Mainte::Ads',
        },
        +{  method => 'model_mainte_acting',
            class  => 'Yoyakku::Model::Mainte::Acting',
        },
        +{  method => 'model_mainte_post',
            class  => 'Yoyakku::Model::Mainte::Post',
        },
    ];

    my @model_methods = qw{params session method html login_row login_table
        login_name profile_row storeinfo_row template type flash_msg acting_rows
        mail_temp mail_header mail_body login_storeinfo_row login_roominfo_rows
        yoyakku_conf};

    for my $class ( @{$class_args} ) {
        my $method = $class->{method};
        my $model = $t->app->build_controller->$method;
        isa_ok( $model, $class->{class} );
        can_ok( $model, @model_methods );
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
        # '/up_logout',
        # '/profile',
        # '/profile_comp',
        # '/mainte_list',
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
        # '/mainte_reserve_serch',
        # '/mainte_reserve_new',
        '/mainte_acting_serch',
        '/mainte_acting_new',
        '/mainte_ads_serch',
        '/mainte_ads_new',
        # '/mainte_region_serch',
        # '/mainte_region_new',
        '/mainte_post_serch',
        '/mainte_post_new',
        '/index',
        '/index_next_m',
        '/index_next_two_m',
        '/index_next_three_m',
        # '/entry',
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
