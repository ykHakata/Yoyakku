use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

BEGIN {
    use_ok('Yoyakku::Controller::Auth') || print "Bail out!\n";
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
    my $obj = Yoyakku::Controller::Auth->new();
    isa_ok( $obj, 'Yoyakku::Controller::Auth' );

    my @methods = qw{index up_login up_logout up_login_general
        up_login_admin root_login _render_input_form _render_auth};

    can_ok( $obj, @methods );
};

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

subtest 'index' => sub {

    my @to_index = ( Location => 'index' );

    # get, post 以外は トップページにリダイレクト
    $t->head_ok('/up_login')->status_is(302)->header_is(@to_index);
    $t->head_ok('/up_login_general')->status_is(302)->header_is(@to_index);
    $t->head_ok('/up_login_admin')->status_is(302)->header_is(@to_index);
    $t->head_ok('/root_login')->status_is(302)->header_is(@to_index);
    $t->head_ok('/up_logout')->status_is(302)->header_is(@to_index);

    # ログインなしアクセス
    $t->get_ok('/up_login')->status_is(200);
    $t->get_ok('/up_login_general')->status_is(200);
    $t->get_ok('/up_login_admin')->status_is(200);
    $t->get_ok('/root_login')->status_is(200);
    $t->get_ok('/up_logout')->status_is(302)->header_is(@to_index);
};

=head2 up_login

    ログインフォーム入口画面の描写

=cut

subtest 'up_login' => sub {

    my @to_index = ( Location => 'index' );

    # ログインなしの場合、ログイン入力選択画面へ
    subtest 'render login select' => sub {
        $t->get_ok('/up_login')->status_is(200)
            ->content_type_is('text/html;charset=UTF-8')
            ->text_is( 'html head title' => 'yoyakkuログイン' )
            ->content_like(qr{\Qログインを選択してください。\E})
            ->content_like(qr{\Q一般ユーザーログイン\E})
            ->content_like(qr{\Q店舗管理者ログイン\E});
    };

    # ログイン中の場合、 index へリダイレクト
    subtest 'redirect loging in' => sub {
        $t->post_ok( '/up_login_admin' => form => $login_admin )
            ->status_is(302)->header_is(@to_index);
        $t->get_ok('/up_login')->status_is(302)->header_is(@to_index);
        $t->get_ok('/up_logout')->status_is(200);
        $t->get_ok('/up_login')->status_is(200);
    };
};

=head2 up_logout

    ログアウト機能 (レスポンス時に session データを消去)

=cut

subtest 'up_logout' => sub {

    my @to_index = ( Location => 'index' );

    # ログイン中の場合 session 終了後ログイン終了画面へ
    subtest 'render logout' => sub {

        # セッション成功リダイレクト (profile 設定済み)
        $t->post_ok( '/up_login_admin' => form => $login_admin )
            ->status_is(302)->header_is(@to_index);

        $t->get_ok('/up_logout')->status_is(200)
            ->content_type_is('text/html;charset=UTF-8')
            ->text_is( 'html head title' => 'ログアウト' )
            ->content_like(qr{\Qログアウトしました。\E})
            ->content_like(qr{\Qありがとうございました。\E});
    };

    # ログインなしの場合、 index へリダイレクト
    subtest 'redirect not loging in' => sub {
        $t->get_ok('/up_logout')->status_is(302)->header_is(@to_index);
    };
};

=head2 up_login_admin

    店舗管理者用ログイン

=cut

subtest 'up_login_admin' => sub {

    my @to_index = ( Location => 'index' );

    # ログイン入力画面
    subtest 'render login input' => sub {
        $t->get_ok('/up_login_admin')->status_is(200)
            ->content_type_is('text/html;charset=UTF-8')
            ->text_is( 'html head title' => 'yoyakkuログイン' )
            ->element_exists('input[name=login][type=text][value=]')
            ->element_exists('input[name=password][type=password][value=]')
            ->content_like(qr{\Qyoyakku店舗管理者ログイン\E})
            ->content_like(qr{\Qメールアドレス\E})
            ->content_like(qr{\Qパスワード\E});
    };

    # ログイン情報送信
    subtest 'sender login data' => sub {

        # セッション成功リダイレクト (profile 設定済み)
        subtest 'success' => sub {
            $t->post_ok( '/up_login_admin' => form => $login_admin )
                ->status_is(302)->header_is(@to_index);

            $t->get_ok('/up_logout')->status_is(200)
                ->content_type_is('text/html;charset=UTF-8')
                ->text_is( 'html head title' => 'ログアウト' )
                ->content_like(qr{\Qログアウトしました。\E})
                ->content_like(qr{\Qありがとうございました。\E});
        };

        # 入力値の違い
        subtest 'fail' => sub {
            my $login_fail = +{
                login    => 'fail_login',
                password => 'fail_password',
            };

            my $login_val    = $login_fail->{login};
            my $password_val = $login_fail->{password};

            $t->post_ok( '/up_login_admin' => form => $login_fail )
                ->status_is(200)->content_type_is('text/html;charset=UTF-8')
                ->text_is( 'html head title' => 'yoyakkuログイン' )
                ->element_exists(
                "input[name=login][type=text][value=$login_val]")
                ->element_exists(
                "input[name=password][type=password][value=$password_val]")
                ->content_like(qr{\Qメールアドレス違い\E});

            $login_fail->{login} = $login_admin->{login};
            $login_val           = $login_fail->{login};
            $password_val        = $login_fail->{password};

            $t->post_ok( '/up_login_admin' => form => $login_fail )
                ->status_is(200)->content_type_is('text/html;charset=UTF-8')
                ->text_is( 'html head title' => 'yoyakkuログイン' )
                ->element_exists(
                "input[name=login][type=text][value=$login_val]")
                ->element_exists(
                "input[name=password][type=password][value=$password_val]")
                ->content_like(qr{\Qパスワードが違います\E});

            $login_fail->{login} = '';
            $login_val           = $login_fail->{login};
            $password_val        = $login_fail->{password};

            $t->post_ok( '/up_login_admin' => form => $login_fail )
                ->status_is(200)->content_type_is('text/html;charset=UTF-8')
                ->text_is( 'html head title' => 'yoyakkuログイン' )
                ->element_exists(
                "input[name=login][type=text][value=$login_val]")
                ->element_exists(
                "input[name=password][type=password][value=$password_val]")
                ->content_like(qr{\Q必須入力\E});

            $login_fail->{login}    = $login_admin->{login};
            $login_fail->{password} = '';
            $login_val              = $login_fail->{login};
            $password_val           = $login_fail->{password};

            $t->post_ok( '/up_login_admin' => form => $login_fail )
                ->status_is(200)->content_type_is('text/html;charset=UTF-8')
                ->text_is( 'html head title' => 'yoyakkuログイン' )
                ->element_exists(
                "input[name=login][type=text][value=$login_val]")
                ->element_exists(
                "input[name=password][type=password][value=$password_val]")
                ->content_like(qr{\Q必須入力\E});
        };

        # ログイン中は index へリダイレクト
        subtest 'loging in' => sub {
            $t->post_ok( '/up_login_admin' => form => $login_admin )
                ->status_is(302)->header_is(@to_index);

            $t->post_ok( '/up_login_admin' => form => $login_admin )
                ->status_is(302)->header_is(@to_index);

            $t->get_ok('/up_logout')->status_is(200);
        };

    };

    # profile 設定が終了している

    # profile 設定が終了していない
};

=head2 up_login_general

    一般ユーザー用ログイン

=cut

subtest 'up_login_general' => sub {

    my @to_index = ( Location => 'index' );

    # ログイン入力画面
    subtest 'render login input' => sub {
        $t->get_ok('/up_login_general')->status_is(200)
            ->content_type_is('text/html;charset=UTF-8')
            ->text_is( 'html head title' => 'yoyakku一般idログイン' )
            ->element_exists('input[name=login][type=text][value=]')
            ->element_exists('input[name=password][type=password][value=]')
            ->content_like(qr{\Qyoyakku一般id用ログイン\E})
            ->content_like(qr{\Qメールアドレス\E})
            ->content_like(qr{\Qパスワード\E});
    };

    # ログイン情報送信
    subtest 'sender login data' => sub {

        # セッション成功リダイレクト (profile 設定済み)
        subtest 'success' => sub {
            $t->post_ok( '/up_login_general' => form => $login_general )
                ->status_is(302)->header_is(@to_index);
            $t->get_ok('/up_logout')->status_is(200)
                ->content_type_is('text/html;charset=UTF-8')
                ->text_is( 'html head title' => 'ログアウト' )
                ->content_like(qr{\Qログアウトしました。\E})
                ->content_like(qr{\Qありがとうございました。\E});
        };

        # 入力値の違い
        subtest 'fail' => sub {
            my $login_fail = +{
                login    => 'fail_login',
                password => 'fail_password',
            };

            my $login_val    = $login_fail->{login};
            my $password_val = $login_fail->{password};

            $t->post_ok( '/up_login_general' => form => $login_fail )
                ->status_is(200)->content_type_is('text/html;charset=UTF-8')
                ->text_is(
                'html head title' => 'yoyakku一般idログイン' )
                ->element_exists(
                "input[name=login][type=text][value=$login_val]")
                ->element_exists(
                "input[name=password][type=password][value=$password_val]")
                ->content_like(qr{\Qメールアドレス違い\E});

            $login_fail->{login} = $login_general->{login};
            $login_val           = $login_fail->{login};
            $password_val        = $login_fail->{password};

            $t->post_ok( '/up_login_general' => form => $login_fail )
                ->status_is(200)->content_type_is('text/html;charset=UTF-8')
                ->text_is(
                'html head title' => 'yoyakku一般idログイン' )
                ->element_exists(
                "input[name=login][type=text][value=$login_val]")
                ->element_exists(
                "input[name=password][type=password][value=$password_val]")
                ->content_like(qr{\Qパスワードが違います\E});

            $login_fail->{login} = '';
            $login_val           = $login_fail->{login};
            $password_val        = $login_fail->{password};

            $t->post_ok( '/up_login_general' => form => $login_fail )
                ->status_is(200)->content_type_is('text/html;charset=UTF-8')
                ->text_is(
                'html head title' => 'yoyakku一般idログイン' )
                ->element_exists(
                "input[name=login][type=text][value=$login_val]")
                ->element_exists(
                "input[name=password][type=password][value=$password_val]")
                ->content_like(qr{\Q必須入力\E});

            $login_fail->{login}    = $login_general->{login};
            $login_fail->{password} = '';
            $login_val              = $login_fail->{login};
            $password_val           = $login_fail->{password};

            $t->post_ok( '/up_login_general' => form => $login_fail )
                ->status_is(200)->content_type_is('text/html;charset=UTF-8')
                ->text_is(
                'html head title' => 'yoyakku一般idログイン' )
                ->element_exists(
                "input[name=login][type=text][value=$login_val]")
                ->element_exists(
                "input[name=password][type=password][value=$password_val]")
                ->content_like(qr{\Q必須入力\E});
        };

        # ログイン中は index へリダイレクト
        subtest 'loging in' => sub {
            $t->post_ok( '/up_login_general' => form => $login_general )
                ->status_is(302)->header_is(@to_index);

            $t->post_ok( '/up_login_general' => form => $login_general )
                ->status_is(302)->header_is(@to_index);

            $t->get_ok('/up_logout')->status_is(200);
        };

    };

    # profile 設定が終了している

    # profile 設定が終了していない
};

=head2 root_login

    スーパーユーザー用ログイン

=cut

subtest 'root_login' => sub {

    my @to_index = ( Location => 'index' );

    # ログイン入力画面
    subtest 'render login input' => sub {
        $t->get_ok('/root_login')->status_is(200)
            ->content_type_is('text/html;charset=UTF-8')
            ->text_is( 'html head title' =>
                'yoyakkuスーパーユーザーログイン' )
            ->element_exists('input[name=login][type=text][value=]')
            ->element_exists('input[name=password][type=password][value=]')
            ->content_like(
            qr{\Qyoyakkuスーパーユーザーログイン\E})
            ->content_like(qr{\QID\E})->content_like(qr{\Qpassword\E});
    };

    # ログイン情報送信
    subtest 'sender login data' => sub {

     # セッション成功リダイレクト ( 管理画面メニューへ )
        subtest 'success' => sub {
            $t->post_ok( '/root_login' => form => $login_root )
                ->status_is(302)->header_is('mainte_list');
            $t->get_ok('/up_logout')->status_is(200)
                ->content_type_is('text/html;charset=UTF-8')
                ->text_is( 'html head title' => 'ログアウト' )
                ->content_like(qr{\Qログアウトしました。\E})
                ->content_like(qr{\Qありがとうございました。\E});
        };

        # 入力値の違い
        subtest 'fail' => sub {
            my $login_fail = +{
                login    => 'fail_login',
                password => 'fail_password',
            };

            my $login_val    = $login_fail->{login};
            my $password_val = $login_fail->{password};

            $t->post_ok( '/root_login' => form => $login_fail )
                ->status_is(200)->content_type_is('text/html;charset=UTF-8')
                ->text_is(
                'html head title' => 'yoyakkuスーパーユーザーログイン' )
                ->element_exists(
                "input[name=login][type=text][value=$login_val]")
                ->element_exists(
                "input[name=password][type=password][value=$password_val]")
                ->content_like(qr{\QID違い\E});

            $login_fail->{login} = $login_admin->{login};
            $login_val           = $login_fail->{login};
            $password_val        = $login_fail->{password};

            $t->post_ok( '/root_login' => form => $login_fail )
                ->status_is(200)->content_type_is('text/html;charset=UTF-8')
                ->text_is(
                'html head title' => 'yoyakkuスーパーユーザーログイン' )
                ->element_exists(
                "input[name=login][type=text][value=$login_val]")
                ->element_exists(
                "input[name=password][type=password][value=$password_val]")
                ->content_like(qr{\Qpassword違い\E});

            $login_fail->{login} = '';
            $login_val           = $login_fail->{login};
            $password_val        = $login_fail->{password};

            $t->post_ok( '/root_login' => form => $login_fail )
                ->status_is(200)->content_type_is('text/html;charset=UTF-8')
                ->text_is(
                'html head title' => 'yoyakkuスーパーユーザーログイン' )
                ->element_exists(
                "input[name=login][type=text][value=$login_val]")
                ->element_exists(
                "input[name=password][type=password][value=$password_val]")
                ->content_like(qr{\Q必須入力\E});

            $login_fail->{login}    = $login_admin->{login};
            $login_fail->{password} = '';
            $login_val              = $login_fail->{login};
            $password_val           = $login_fail->{password};

            $t->post_ok( '/root_login' => form => $login_fail )
                ->status_is(200)->content_type_is('text/html;charset=UTF-8')
                ->text_is(
                'html head title' => 'yoyakkuスーパーユーザーログイン' )
                ->element_exists(
                "input[name=login][type=text][value=$login_val]")
                ->element_exists(
                "input[name=password][type=password][value=$password_val]")
                ->content_like(qr{\Q必須入力\E});
        };

        # ログイン中は index へ (root セッション存在時)
        subtest 'loging in' => sub {
            $t->post_ok( '/root_login' => form => $login_root )
                ->status_is(302)->header_is('mainte_list');

            $t->post_ok( '/root_login' => form => $login_root )
                ->status_is(302)->header_is(@to_index);

            $t->get_ok('/up_logout')->status_is(200);

            # 店舗管理者用ログイン中でもログイン可能
            $t->post_ok( '/up_login_admin' => form => $login_admin )
                ->status_is(302)->header_is(@to_index);

            $t->post_ok( '/root_login' => form => $login_root )
                ->status_is(302)->header_is('mainte_list');

            $t->get_ok('/up_logout')->status_is(200);

            # 一般ユーザー用ログイン中でもログイン可能
            $t->post_ok( '/up_login_general' => form => $login_general )
                ->status_is(302)->header_is(@to_index);

            $t->post_ok( '/root_login' => form => $login_root )
                ->status_is(302)->header_is('mainte_list');

            $t->get_ok('/up_logout')->status_is(200);

        };

    };

    # profile 設定が終了している

    # profile 設定が終了していない
};

done_testing();

__END__






done_testing();

__END__



=head2 index_next_m

    オープニングカレンダー確認画面(1ヶ月後)

=cut

subtest 'index_next_m' => sub {
    my $tp_obj     = $t->app->model_calendar->get_date_info('next1m_date');
    my $year_month = $tp_obj->year . '年' . $tp_obj->mon . '月';

    $t->get_ok('/index_next_m')->status_is(200)
        ->text_is( 'html head title' => 'yoyakkuオープニング' )
        ->text_is( '#month'          => $year_month );
};

=head2 index_next_two_m

    オープニングカレンダー確認画面(2ヶ月後)

=cut

subtest 'index_next_two_m' => sub {
    my $tp_obj     = $t->app->model_calendar->get_date_info('next2m_date');
    my $year_month = $tp_obj->year . '年' . $tp_obj->mon . '月';

    $t->get_ok('/index_next_two_m')->status_is(200)
        ->text_is( 'html head title' => 'yoyakkuオープニング' )
        ->text_is( '#month'          => $year_month );
};

=head2 index_next_three_m

    オープニングカレンダー確認画面(3ヶ月後)

=cut

subtest 'index_next_three_m' => sub {
    my $tp_obj     = $t->app->model_calendar->get_date_info('next3m_date');
    my $year_month = $tp_obj->year . '年' . $tp_obj->mon . '月';

    $t->get_ok('/index_next_three_m')->status_is(200)
        ->text_is( 'html head title' => 'yoyakkuオープニング' )
        ->text_is( '#month'          => $year_month );
};

done_testing();

__END__
