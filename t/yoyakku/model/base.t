use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN { use_ok('Yoyakku::Model::Base') || print "Bail out!\n"; }

my $t            = Test::Mojo->new('Yoyakku');
my $config       = $t->app->config;
my $login_params = $config->{mainte}->{login_account};
$t->app->commands->run('init_db');

=head2 method

    オブジェクト、メソッド存在確認

=cut

subtest 'method' => sub {
    my $obj = Yoyakku::Model::Base->new();
    isa_ok( $obj, 'Yoyakku::Model::Base' );

    my @methods = qw{change_format_datetime set_fill_in_params
        get_calender_caps send_gmail check_table_column
        get_header_stash_params get_valid_params
        get_init_valid_params
        insert_admin_relation};

    can_ok( $obj, @methods );
};

done_testing();

__END__
