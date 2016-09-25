use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN {
    use_ok('Yoyakku::Controller::Profile') || print "Bail out!\n";
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
    my $obj = Yoyakku::Controller::Profile->new();
    isa_ok( $obj, 'Yoyakku::Controller::Profile' );

    my @methods = qw{index profile_comp profile _insert _update _common
        _render_profile};

    can_ok( $obj, @methods );
};

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

subtest 'index' => sub {

    my @to_index = ( Location => '/index' );

    # get, post 以外は トップページにリダイレクト
    $t->head_ok('/profile')->status_is(302)->header_is(@to_index);
    $t->head_ok('/profile_comp')->status_is(302)->header_is(@to_index);

    # ログインなしアクセス
    $t->get_ok('/profile')->status_is(302)->header_is(@to_index);
    $t->get_ok('/profile_comp')->status_is(302)->header_is(@to_index);
};

=head2 profile_comp

    プロフィール情報確認画面

=cut

subtest 'profile_comp' => sub {

    my @to_index = ( Location => '/index' );

    subtest 'success' => sub {

        # ログイン (admin)
        $t->post_ok( '/up_login_admin' => form => $login_admin )
            ->status_is(302)->header_is(@to_index);

        $t->get_ok('/profile_comp')->status_is(200)
            ->content_type_is('text/html;charset=UTF-8')
            ->text_is(
            'html head title' => 'yoyakkuプロフィール設定' )
            ->content_like(
            qr{\Qプロフィールの確認／(admin)スタジオヨヤック\E}
            );

        my $elements = [
            'input[type=hidden][name=id][value=1]',
            'input[name=login][value=yoyakku@gmail.com][readonly=readonly][type=text]',
            'input[type=text][name=nick_name][value=スタジオヨヤック][readonly=readonly]',
            'input[value=yoyakku][name=password][readonly=readonly][type=password]',
            'input[type=text][name=full_name][value=藤村 真帆][readonly=readonly]',
            'input[value=ふじむら まほ][name=phonetic_name][readonly=readonly][type=text]',
            'input[type=text][readonly=readonly][value=090-2568-4213][name=tel]',
            'input[type=text][name=mail][value=yoyakku@gmail.com][readonly=readonly]',
        ];

        for my $element ( @{$elements} ) {
            $t->element_exists($element);
        }

        $t->get_ok('/up_logout')->status_is(200);

        # ログイン (general)
        $t->post_ok( '/up_login_general' => form => $login_general )
            ->status_is(302)->header_is(@to_index);

        $t->get_ok('/profile_comp')->status_is(200)
            ->content_type_is('text/html;charset=UTF-8')
            ->text_is(
            'html head title' => 'yoyakkuプロフィール設定' )
            ->content_like(
            qr{\Qプロフィールの確認／ふくしま\E});

        $elements = [
            'input[type=hidden][value=1][name=id]',
            'input[readonly=readonly][name=login][value=yoyakku+user@gmail.com][type=text]',
            'input[type=text][value=ふくしま][readonly=readonly][name=nick_name]',
            'input[readonly=readonly][name=password][value=yoyakku+user][type=password]',
            'input[type=text][value=福島 寛][readonly=readonly][name=full_name]',
            'input[readonly=readonly][name=phonetic_name][value=ふくしま ひろし][type=text]',
            'input[value=080-3134-9970][type=text][readonly=readonly][name=tel]',
            'input[value=yoyakku+user@gmailcom][type=text][name=mail][readonly=readonly]',
            'input[type=text][value=スタジオヨヤック][name=acting_1][readonly=readonly]',
            'input[type=text][name=acting_2][readonly=readonly]',
            'input[readonly=readonly][name=acting_3][type=text]',
        ];

        for my $element ( @{$elements} ) {
            $t->element_exists($element);
        }

        $t->get_ok('/up_logout')->status_is(200);
    };

    subtest 'fail' => sub {
        $t->post_ok('/profile_comp')->status_is(302)->header_is(@to_index);
    };
};

=head2 profile

    プロフィール登録画面

=cut

subtest 'profile' => sub {

    my @to_index = ( Location => '/index' );

    subtest 'success' => sub {

        subtest 'update' => sub {

            # ログイン (admin)
            $t->post_ok( '/up_login_admin' => form => $login_admin )
                ->status_is(302)->header_is(@to_index);

            $t->get_ok('/profile')->status_is(200)
                ->content_type_is('text/html;charset=UTF-8')
                ->text_is(
                'html head title' => 'yoyakkuプロフィール設定' )
                ->content_like(
                qr{\Qプロフィールの設定／(admin)スタジオヨヤック\E}
                );

            my $elements = [
                'input[name=id][value=1][type=hidden]',
                'input[readonly=readonly][name=login][type=text][value=yoyakku@gmail.com]',
                'input[value=スタジオヨヤック][type=text][name=nick_name]',
                'input[type=password][value=yoyakku][name=password]',
                'input[type=password][value=yoyakku][name=password_2]',
                'input[name=profile_id][type=hidden][value=1]',
                'input[type=text][value=藤村 真帆][name=full_name]',
                'input[value=ふじむら まほ][type=text][name=phonetic_name]',
                'input[name=tel][type=text][value=090-2568-4213]',
                'input[name=mail][value=yoyakku@gmail.com][type=text]',
                'input[id=button_submit][name=submit][value=登録][type=submit]',
            ];

            for my $element ( @{$elements} ) {
                $t->element_exists($element);
            }

            # パラメーターの取得
            my $login_row = $t->app->model->db->base->teng->single( 'admin',
                +{ id => 1 } );

            my $update_params
                = $t->app->model->profile->set_form_params_profile( 'profile',
                $login_row );

            # nick_name を変更
            my $params = +{
                id            => $update_params->{id},
                login         => $update_params->{login},
                password      => $update_params->{password},
                password_2    => $update_params->{password_2},
                profile_id    => $update_params->{profile_id},
                nick_name     => 'テストニックネーム',
                full_name     => $update_params->{full_name},
                phonetic_name => $update_params->{phonetic_name},
                tel           => $update_params->{tel},
                mail          => $update_params->{mail},
            };

            $t->ua->max_redirects(1);
            $t->post_ok( '/profile' => form => $params )->status_is(200);
            $t->content_like(qr{\Q修正完了\E});
            $t->content_like(qr{\Qテストニックネーム\E});
            $t->ua->max_redirects(0);

            $t->get_ok('/up_logout')->status_is(200);

            # ログイン (general)
            $t->post_ok( '/up_login_general' => form => $login_general )
                ->status_is(302)->header_is(@to_index);

            $t->get_ok('/profile')->status_is(200)
                ->content_type_is('text/html;charset=UTF-8')
                ->text_is(
                'html head title' => 'yoyakkuプロフィール設定' )
                ->content_like(
                qr{\Qプロフィールの設定／ふくしま\E} );

            $elements = [
                'input[value=1][type=hidden][name=id]',
                'input[name=login][type=text][readonly=readonly][value=yoyakku+user@gmail.com]',
                'input[value=ふくしま][type=text][name=nick_name]',
                'input[type=password][name=password][value=yoyakku+user]',
                'input[name=password_2][type=password][value=yoyakku+user]',
                'input[value=2][type=hidden][name=profile_id]',
                'input[type=text][name=full_name][value=福島 寛]',
                'input[type=text][name=phonetic_name][value=ふくしま ひろし]',
                'input[type=text][name=tel][value=080-3134-9970]',
                'input[type=text][name=mail][value=yoyakku+user@gmailcom]',
                'select[name=acting_1]',
                'select[name=acting_2]',
                'select[name=acting_3]',
            ];

            for my $element ( @{$elements} ) {
                $t->element_exists($element);
            }

            $t->get_ok('/up_logout')->status_is(200);
        };
    };

    # subtest 'fail' => sub {

   # };
};

done_testing();

__END__
