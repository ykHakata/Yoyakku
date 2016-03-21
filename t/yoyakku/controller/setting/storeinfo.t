use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN {
    use_ok('Yoyakku::Controller::Setting::Storeinfo') || print "Bail out!\n";
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
    my $obj = Yoyakku::Controller::Setting::Storeinfo->new();
    isa_ok( $obj, 'Yoyakku::Controller::Setting::Storeinfo' );

    my @methods = qw{index admin_store_edit _cancel _post_search _update
        _common _render_fill_in_form admin_store_comp};

    can_ok( $obj, @methods );
};

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

subtest 'index' => sub {

    my @to_index = ( Location => 'index' );

    # get, post 以外は トップページにリダイレクト
    $t->head_ok('/admin_store_edit')->status_is(302)->header_is(@to_index);
    $t->head_ok('/admin_store_comp')->status_is(302)->header_is(@to_index);

    # ログインなしアクセス
    $t->get_ok('/admin_store_edit')->status_is(302)->header_is(@to_index);
    $t->get_ok('/admin_store_comp')->status_is(302)->header_is(@to_index);
};

=head2 admin_store_edit

    選択店舗情報確認コントロール

=cut

subtest 'admin_store_edit' => sub {

    my @to_index = ( Location => 'index' );

    subtest 'success' => sub {

        # ログイン (admin)
        subtest 'admin' => sub {
            $t->post_ok( '/up_login_admin' => form => $login_admin )
                ->status_is(302)->header_is(@to_index);

            $t->get_ok('/admin_store_edit')->status_is(200)
                ->content_type_is('text/html;charset=UTF-8')
                ->text_is( 'html head title' => 'yoyakku管理モード' )
                ->content_like(qr{\Q(admin)スタジオヨヤック\E});

            my $elements = [
                'input[value=キャンセル][name=cancel][type=submit]',
                'input[type=hidden][name=id][value=1]',
                'input[value=完了][name=][type=submit]',
                'input[value=40132][name=region_id][type=hidden]',
                'input[type=text][name=name][value=スタジオヨヤック]',
                'input[value=検索][name=post_search][type=submit]',
                'input[name=post][value=8120041][type=text]',
                'input[name=state][value=福岡県][type=text]',
                'input[type=text][value=福岡市博多区][name=cities]',
                'input[value=吉塚２丁目２１−１５][name=addressbelow][type=text]',
                'input[type=text][value=090-2568-4213][name=tel]',
                'input[type=text][value=yoyakku@gmail.com][name=mail]',
                'input[type=text][value=http://www.yoyakku.com/][name=url]',
            ];

            for my $element ( @{$elements} ) {
                $t->element_exists($element);
            }

            $t->text_is(
                'textarea[name=remarks]' => '吉塚公民館すぐそば' );

            $t->get_ok('/up_logout')->status_is(200);
        };

        # ログイン (general)
        subtest 'general' => sub {
            $t->post_ok( '/up_login_general' => form => $login_general )
                ->status_is(302)->header_is(@to_index);
            $t->get_ok('/admin_store_edit')->status_is(302)
                ->header_is(@to_index);
            $t->get_ok('/up_logout')->status_is(200);
        };

        subtest 'cancel' => sub {
            $t->post_ok( '/up_login_admin' => form => $login_admin )
                ->status_is(302)->header_is(@to_index);

            my $params = +{ cancel => 'キャンセル', };

            $t->post_ok( '/admin_store_edit' => form => $params )
                ->status_is(200)->content_type_is('text/html;charset=UTF-8')
                ->text_is( 'html head title' => 'yoyakku管理モード' )
                ->content_like(qr{\Q(admin)スタジオヨヤック\E});

            my $elements = [
                'input[value=キャンセル][name=cancel][type=submit]',
                'input[type=hidden][name=id][value=1]',
                'input[value=完了][name=][type=submit]',
                'input[value=][name=region_id][type=hidden]',
                'input[type=text][name=name][value=]',
                'input[value=検索][name=post_search][type=submit]',
                'input[name=post][value=][type=text]',
                'input[name=state][value=][type=text]',
                'input[type=text][value=][name=cities]',
                'input[value=][name=addressbelow][type=text]',
                'input[type=text][value=][name=tel]',
                'input[type=text][value=][name=mail]',
                'input[type=text][value=][name=url]',
            ];

            for my $element ( @{$elements} ) {
                $t->element_exists($element);
            }
            $t->text_is( 'textarea[name=remarks]' => '' );
            $t->get_ok('/up_logout')->status_is(200);
        };

        subtest 'post_search' => sub {
            $t->post_ok( '/up_login_admin' => form => $login_admin )
                ->status_is(302)->header_is(@to_index);

            my $args = +{
                table    => 'admin',
                login    => $login_admin->{login},
                password => $login_admin->{password},
            };
            my $login_row = $t->app->model->setting->storeinfo->login($args);
            my $params    = $login_row->fetch_storeinfo->get_columns;

            $params->{post_search} = '検索';
            $params->{post}        = '8010811';

            $t->post_ok( '/admin_store_edit' => form => $params )
                ->status_is(200)->content_type_is('text/html;charset=UTF-8')
                ->text_is( 'html head title' => 'yoyakku管理モード' )
                ->content_like(qr{\Q(admin)スタジオヨヤック\E});

            my $elements = [
                'input[value=キャンセル][name=cancel][type=submit]',
                'input[type=hidden][name=id][value=1]',
                'input[value=完了][name=][type=submit]',
                'input[value=40101][name=region_id][type=hidden]',
                'input[type=text][name=name][value=スタジオヨヤック]',
                'input[value=検索][name=post_search][type=submit]',
                'input[name=post][value=8010811][type=text]',
                'input[name=state][value=福岡県][type=text]',
                'input[type=text][value=北九州市門司区][name=cities]',
                'input[value=吉塚２丁目２１−１５][name=addressbelow][type=text]',
                'input[type=text][value=090-2568-4213][name=tel]',
                'input[type=text][value=yoyakku@gmail.com][name=mail]',
                'input[type=text][value=http://www.yoyakku.com/][name=url]',
            ];

            for my $element ( @{$elements} ) {
                $t->element_exists($element);
            }

            $t->text_is(
                'textarea[name=remarks]' => '吉塚公民館すぐそば' );

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
            my $login_row = $t->app->model->setting->storeinfo->login($args);
            my $params    = $login_row->fetch_storeinfo->get_columns;

            $params->{name} = $params->{name} . 'テスト';

            $t->ua->max_redirects(1);
            $t->post_ok( '/admin_store_edit' => form => $params )
                ->status_is(200)->content_type_is('text/html;charset=UTF-8')
                ->text_is( 'html head title' => 'yoyakku管理モード' )
                ->content_like(qr{\Q(admin)スタジオヨヤック\E})
                ->content_like(qr{\Q完了！\E})
                ->content_like(qr{\Qスタジオヨヤックテスト\E});
            $t->ua->max_redirects(0);

            $t->get_ok('/up_logout')->status_is(200);
        };
    };

    # subtest 'fail' => sub {
    # };
};

=head2 admin_store_comp

    店舗情報確認画面

=cut

subtest 'admin_store_comp' => sub {

    my @to_index = ( Location => 'index' );

    subtest 'success' => sub {

        # ログイン (admin)
        subtest 'admin' => sub {
            $t->post_ok( '/up_login_admin' => form => $login_admin )
                ->status_is(302)->header_is(@to_index);

            $t->get_ok('/admin_store_comp')->status_is(200)
                ->content_type_is('text/html;charset=UTF-8')
                ->text_is( 'html head title' => 'yoyakku管理モード' );

            my $mail = 'yoyakku@gmail.com';
            my $elements = [
                qr{\Q(admin)スタジオヨヤック\E},
                qr{\Qスタジオヨヤックテスト\E},
                qr{\Q8120041\E},
                qr{\Q福岡県福岡市博多区\E},
                qr{\Q吉塚２丁目２１−１５\E},
                qr{\Q090-2568-4213\E},
                qr{$mail},
                qr{\Q吉塚公民館すぐそば\E},
            ];

            for my $element ( @{$elements} ) {
                $t->content_like($element);
            }

            $t->get_ok('/up_logout')->status_is(200);
        };

        # ログイン (general)
        subtest 'general' => sub {
            $t->post_ok( '/up_login_general' => form => $login_general )
                ->status_is(302)->header_is(@to_index);
            $t->get_ok('/admin_store_comp')->status_is(302)
                ->header_is(@to_index);
            $t->get_ok('/up_logout')->status_is(200);
        };
    };

    # subtest 'fail' => sub {
    # };
};

done_testing();

__END__
