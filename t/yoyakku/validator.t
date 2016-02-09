use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN { use_ok('Yoyakku::Validator') || print "Bail out!\n"; }

subtest 'method' => sub {
    my $obj = Yoyakku::Validator->new();
    isa_ok( $obj, 'Yoyakku::Validator' );

    my @methods = qw{get_msg_validator reserve _check_reserve_use_time acting
        ads entry storeinfo roominfo _check_start_and_end_on _check_rentalunit};

    can_ok( $obj, @methods );
};

subtest 'reserve' => sub {
    my $obj = Yoyakku::Validator->new();

    # 必須入力
    my $params = +{
        getstarted_on_day  => '2016-02-09',
        enduse_on_day      => '2016-02-09',
        getstarted_on_time => '10:00:00',
        enduse_on_time     => '12:00:00',
        tel                => '080-0000-0000',
    };

    my $error = $obj->reserve($params);

    is($error, undef, 'not null params');
};

done_testing();

__END__
