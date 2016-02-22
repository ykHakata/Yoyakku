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

    my @to_index = ( Location => 'index' );

    # get, post 以外は トップページにリダイレクト
    $t->head_ok('/profile')->status_is(302)->header_is(@to_index);
    $t->head_ok('/profile_comp')->status_is(302)->header_is(@to_index);

    # ログインなしアクセス
    $t->get_ok('/profile')->status_is(302)->header_is(@to_index);
    $t->get_ok('/profile_comp')->status_is(302)->header_is(@to_index);
};

=head2 profile

    登録画面

=cut

subtest 'profile' => sub {

    my @to_index = ( Location => 'index' );

    subtest 'success' => sub {
        # $t->get_ok('/profile')->status_is(200)
        #     ->content_type_is('text/html;charset=UTF-8')
        #     ->text_is( 'html head title' => 'yoyakkuオープニング' )
        #     ->content_like(qr{\Qyoyakkuログイン登録\E})
        #     ->content_like(
        #     qr{\Qログイン登録/yoyakkuベーター版について\E})
        #     ->content_like(qr{\QQ&A\E});

        # # 登録完了からメール配信
        # my $params = +{
        #     mail_j     => 'yoyakku+test@gmail.com',
        #     select_usr => 'admin',
        # };

        # $t->ua->max_redirects(1);

        # $t->post_ok( '/entry' => form => $params )->status_is(200)
        #     ->header_is('entry')->content_like(qr{\Q登録完了\E});

        # $t->ua->max_redirects(0);

        # # メール内容確認
        # my $send_mail = $t->app->model_entry->model_stash;
        # my $mail      = shift @{$send_mail};
        # my $transport = shift @{$send_mail};

        # like( $mail->body_str, qr{\Qyoyakku+test\E}, 'mail body' );
        # like( $mail->body_str, qr{\Qはじめてのyoyakku利用の方へ\E},
        #     'mail body' );

        # # 登録完了後、レコード新規追加
        # my $mail  = $params->{mail_j};
        # my $table = $params->{select_usr};

        # my $create_user = $t->app->model_entry->teng->single( $table,
        #     +{ login => $mail } );

        # is( $create_user->password, 'yoyakku', 'password ok' );
        # is( $create_user->status,   0,         'status ok' );

        # my $create_profile = $t->app->model_entry->teng->single( 'profile',
        #     +{ admin_id => $create_user->id, } );

        # is( $create_profile->nick_name, $mail, 'nick_name ok' );
        # is( $create_profile->mail,      $mail, 'mail ok' );
        # is( $create_profile->status,    0,     'status ok' );
        ok(1);
    };

    # subtest 'fail' => sub {

    #     my $params = +{};
    #     $t->post_ok( '/entry' => form => $params )->status_is(200)
    #         ->content_type_is('text/html;charset=UTF-8')
    #         ->text_is( 'html head title' => 'yoyakkuオープニング' )
    #         ->content_like(qr{\Q必須入力\E});

    #     $params = +{ mail_j => 'fail_mail' };
    #     $t->post_ok( '/entry' => form => $params )->status_is(200)
    #         ->content_like(qr{\QEメールを入力してください\E});

    #     $params = +{ mail_j => 'yoyakku@gmail.com', select_usr => 'admin', };
    #     $t->post_ok( '/entry' => form => $params )->status_is(200)
    #         ->content_like(qr{\Q既に利用されています\E});
    # };
};

done_testing();

__END__
