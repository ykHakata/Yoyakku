use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN {
    use_ok('Yoyakku::Controller::Calendar') || print "Bail out!\n";
}

my $t             = Test::Mojo->new('Yoyakku');
my $config        = $t->app->config;
my $login_admin   = $config->{site}->{login_account}->{admin};
my $login_general = $config->{site}->{login_account}->{general};
$t->app->commands->start_app( 'Yoyakku', 'init_db', );

=head2 method

    オブジェクト、メソッド存在確認

=cut

subtest 'method' => sub {
    my $obj = Yoyakku::Controller::Calendar->new();
    isa_ok( $obj, 'Yoyakku::Controller::Calendar' );

    my @methods = qw{index this_month index_next_m index_next_two_m
        index_next_three_m};

    can_ok( $obj, @methods );
};

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

subtest 'index' => sub {

    # get, post 以外は トップページにリダイレクト
    $t->head_ok('/')->status_is(302);
    $t->head_ok('/index')->status_is(302);
    $t->head_ok('/index_next_m')->status_is(302);
    $t->head_ok('/index_next_two_m')->status_is(302);
    $t->head_ok('/index_next_three_m')->status_is(302);
    $t->header_is( Location => 'index' );

    # ログインなしアクセス
    $t->get_ok('/')->status_is(200);
    $t->get_ok('/index')->status_is(200);
    $t->get_ok('/index_next_m')->status_is(200);
    $t->get_ok('/index_next_two_m')->status_is(200);
    $t->get_ok('/index_next_three_m')->status_is(200);
};

=head2 this_month

    オープニングカレンダー確認画面(今月)

=cut

subtest 'this_month' => sub {
    my $tp_obj     = $t->app->model->calendar->get_date_info('now_date');
    my $year_month = $tp_obj->year . '年' . $tp_obj->mon . '月';

    $t->get_ok('/')->status_is(200)
        ->text_is( 'html head title' => 'yoyakkuオープニング' )
        ->text_is( '#month'          => $year_month );

    $t->get_ok('/index')->status_is(200)
        ->text_is( 'html head title' => 'yoyakkuオープニング' )
        ->text_is( '#month'          => $year_month );
};

=head2 index_next_m

    オープニングカレンダー確認画面(1ヶ月後)

=cut

subtest 'index_next_m' => sub {
    my $tp_obj     = $t->app->model->calendar->get_date_info('next1m_date');
    my $year_month = $tp_obj->year . '年' . $tp_obj->mon . '月';

    $t->get_ok('/index_next_m')->status_is(200)
        ->text_is( 'html head title' => 'yoyakkuオープニング' )
        ->text_is( '#month'          => $year_month );
};

=head2 index_next_two_m

    オープニングカレンダー確認画面(2ヶ月後)

=cut

subtest 'index_next_two_m' => sub {
    my $tp_obj     = $t->app->model->calendar->get_date_info('next2m_date');
    my $year_month = $tp_obj->year . '年' . $tp_obj->mon . '月';

    $t->get_ok('/index_next_two_m')->status_is(200)
        ->text_is( 'html head title' => 'yoyakkuオープニング' )
        ->text_is( '#month'          => $year_month );
};

=head2 index_next_three_m

    オープニングカレンダー確認画面(3ヶ月後)

=cut

subtest 'index_next_three_m' => sub {
    my $tp_obj     = $t->app->model->calendar->get_date_info('next3m_date');
    my $year_month = $tp_obj->year . '年' . $tp_obj->mon . '月';

    $t->get_ok('/index_next_three_m')->status_is(200)
        ->text_is( 'html head title' => 'yoyakkuオープニング' )
        ->text_is( '#month'          => $year_month );
};

done_testing();

__END__
