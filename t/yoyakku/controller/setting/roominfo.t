use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN {
    use_ok('Yoyakku::Controller::Setting::Roominfo') || print "Bail out!\n";
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
    my $obj = Yoyakku::Controller::Setting::Roominfo->new();
    isa_ok( $obj, 'Yoyakku::Controller::Setting::Roominfo' );

    my @methods = qw{index admin_reserv_edit up_admin_r_d_edit _cancel
                 _update _render_fill_in_form};

    can_ok( $obj, @methods );
};


=head2 index

    コントローラー内のルーティング、セッション確認

=cut

subtest 'index' => sub {

    my @to_index = ( Location => 'index' );

    # get, post 以外は トップページにリダイレクト
    $t->head_ok('/admin_reserv_edit')->status_is(302)->header_is(@to_index);
    $t->head_ok('/up_admin_r_d_edit')->status_is(302)->header_is(@to_index);

    # ログインなしアクセス
    $t->get_ok('/admin_reserv_edit')->status_is(302)->header_is(@to_index);
    $t->get_ok('/up_admin_r_d_edit')->status_is(302)->header_is(@to_index);
};


=head2 admin_reserv_edit

    予約部屋情報設定コントロール

=cut

subtest 'admin_reserv_edit' => sub {

    my @to_index = ( Location => 'index' );

    subtest 'success' => sub {

        # ログイン (admin)
        subtest 'admin' => sub {
            $t->post_ok( '/up_login_admin' => form => $login_admin )
                ->status_is(302)->header_is(@to_index);

            $t->get_ok('/admin_reserv_edit')->status_is(200)
                ->content_type_is('text/html;charset=UTF-8')
                ->text_is( 'html head title' => 'yoyakku管理モード' )
                ->content_like(qr{\Q(admin)スタジオヨヤック\E});

            my $elements = [
                'input[name=cancel][value=キャンセル][type=submit]',
                'input[value=完了][type=submit][name=]',
                'input[type=hidden][value=1][name=id]',
                'input[value=A][type=text][name=name]',
                'select[name=starttime_on]',
                'option[selected=selected][value=10:00:00]',
                'select[name=endingtime_on]',
                'option[value=22:00:00][selected=selected]',
                'select[name=time_change]',
                'option[value=0][selected=selected]',
                'select[name=rentalunit]',
                'option[value=1][selected=selected]',
                'input[name=pricescomments][type=text][value=例）１時間２０００円より]',
                'select[name=privatepermit]',
                'option[selected=selected][value=0]',
                'option[value=1]',
                'select[name=privatepeople]',
                'option[value=2][selected=selected]',
                'select[name=privateconditions]',
                'option[value=0][selected=selected]',
            ];

            for my $element ( @{$elements} ) {
                $t->element_exists($element);
            }

            $t->get_ok('/up_logout')->status_is(200);
        };

        # ログイン (general)
        subtest 'general' => sub {
            $t->post_ok( '/up_login_general' => form => $login_general )
                ->status_is(302)->header_is(@to_index);
            $t->get_ok('/admin_reserv_edit')->status_is(302)
                ->header_is(@to_index);
            $t->get_ok('/up_logout')->status_is(200);
        };

        subtest 'cancel' => sub {
            $t->post_ok( '/up_login_admin' => form => $login_admin )
                ->status_is(302)->header_is(@to_index);

            my $params = +{ cancel => 'キャンセル', };

            $t->post_ok( '/admin_reserv_edit' => form => $params )
                ->status_is(200)->content_type_is('text/html;charset=UTF-8')
                ->text_is( 'html head title' => 'yoyakku管理モード' )
                ->content_like(qr{\Q(admin)スタジオヨヤック\E});

            my $elements = [
                'input[name=cancel][value=キャンセル][type=submit]',
                'input[value=完了][type=submit][name=]',
                'input[type=hidden][value=1][name=id]',
                'input[value=][type=text][name=name]',
                'select[name=starttime_on]',
                'option[selected=][value=10:00:00]',
                'select[name=endingtime_on]',
                'option[value=22:00:00][selected=]',
                'select[name=time_change]',
                'option[value=0][selected=]',
                'select[name=rentalunit]',
                'option[value=1][selected=]',
                'input[name=pricescomments][type=text][value=',
                'select[name=privatepermit]',
                'option[selected=][value=0]',
                'option[value=1]',
                'select[name=privatepeople]',
                'option[value=2][selected=]',
                'select[name=privateconditions]',
                'option[value=0][selected=]',
            ];

            for my $element ( @{$elements} ) {
                $t->element_exists($element);
            }
            $t->get_ok('/up_logout')->status_is(200);
        };

        subtest 'update' => sub {
            $t->post_ok( '/up_login_admin' => form => $login_admin )
                ->status_is(302)->header_is(@to_index);

            my $args = +{
                table    => 'admin',
                login    => $login_admin->{login},
                password => $login_admin->{password},
            };
            my $login_row = $t->app->model->auth->login($args);
            my $params = $t->app->model->setting->roominfo->set_roominfo_params(
                $login_row);

            # 部屋名変更
            $params->{name}->[0] = 'AA';

            # データ構造を整形
            my $delete_params = [
                qw{storeinfo_id webreserve cancellimit
                    status remarks webpublishing bookinglimit create_on modify_on}
            ];
            for my $key ( @{$delete_params} ) {
                delete $params->{$key};
            }

            $t->ua->max_redirects(1);
            $t->post_ok( '/admin_reserv_edit' => form => $params )
                ->status_is(200)->content_type_is('text/html;charset=UTF-8')
                ->text_is( 'html head title' => 'yoyakku管理モード' )
                ->content_like(qr{\Q(admin)スタジオヨヤック\E})
                ->content_like(qr{\Q完了！\E})
                ->content_like(qr{\QAA\E});
            $t->ua->max_redirects(0);
            $t->get_ok('/up_logout')->status_is(200);
        };
    };

    # subtest 'fail' => sub {
    # };
};

=head2 up_admin_r_d_edit

    予約部屋詳細設定コントロール

=cut

subtest 'up_admin_r_d_edit' => sub {

    my @to_index = ( Location => 'index' );

    subtest 'success' => sub {

        # ログイン (admin)
        subtest 'admin' => sub {
            $t->post_ok( '/up_login_admin' => form => $login_admin )
                ->status_is(302)->header_is(@to_index);

            $t->get_ok('/up_admin_r_d_edit')->status_is(200)
                ->content_type_is('text/html;charset=UTF-8')
                ->text_is( 'html head title' => 'yoyakku管理モード' );

            my $elements = [
                'input[type=text][value=B][name=name][readonly=readonly][id=name_Detail]',
                'select[name=bookinglimit]',
                'option[value=0][selected=selected]',
                'select[name=cancellimit]',
                'option[value=8][selected=selected]',
                'input[id=reserv_t_Detail_rem][name=remarks][type=text][value=例）スタジオ内の飲食は禁止です。]',
            ];

            for my $element ( @{$elements} ) {
                $t->element_exists($element);
            }

            $t->get_ok('/up_logout')->status_is(200);
        };

        # ログイン (general)
        subtest 'general' => sub {
            $t->post_ok( '/up_login_general' => form => $login_general )
                ->status_is(302)->header_is(@to_index);
            $t->get_ok('/up_admin_r_d_edit')->status_is(302)
                ->header_is(@to_index);
            $t->get_ok('/up_logout')->status_is(200);
        };
    };

    # subtest 'fail' => sub {
    # };
};

done_testing();

__END__
