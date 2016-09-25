package Yoyakku;
use Mojo::Base 'Mojolicious';
use Yoyakku::Model;

# This method will run once at server start
sub startup {
    my $self = shift;

    my $home        = $self->home->to_string;
    my $mode        = $self->mode;
    my $moniker     = $self->moniker;
    my $conf_file   = qq{$home/etc/$moniker.$mode.conf};
    my $common_file = qq{$home/etc/$moniker.common.conf};

    # 設定ファイル
    $self->plugin( Config => +{ file => $conf_file } );
    $self->plugin( Config => +{ file => $common_file } );

    $self->helper(
        model => sub {
            state $model = Yoyakku::Model->new( +{ app => $self->app } );
        }
    );

    # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer');

    # コマンドをロードするための他の名前空間
    push @{ $self->commands->namespaces }, 'Yoyakku::Command';

    # Router
    $self->_routing();

    # セッション情報設定
    $self->sessions->cookie_name('yoyakku');

    # ログ情報を STDERR に出力
    $self->log->path('');
}

sub _routing {
    my $self = shift;

    # Router
    my $r = $self->routes;

    # トップページ遷移(/)
    $r->route('/')->to('Calendar#index');

    # 一般, 店舗管理者, ログインフォーム 入り口, スーパーユーザー, ログアウト
    $r->route('up_login_general')->to('Auth#index');
    $r->route('up_login_admin')->to('Auth#index');
    $r->route('up_login')->to('Auth#index');
    $r->route('root_login')->to('Auth#index');
    $r->route('up_logout')->to('Auth#index');

    # 個人情報 確認画面, 入力画面
    $r->route('/profile_comp')->to('Profile#index');
    $r->route('/profile')->to('Profile#index');

    # システム管理者のオープニング画面
    $r->route('/mainte_list')->to('Mainte#index');

    # システム管理者(admin) 新規 編集
    $r->route('/mainte_registrant_serch')->to('Mainte::Admin#index');
    $r->route('/mainte_registrant_new')->to('Mainte::Admin#index');

    # システム管理者(general) 新規 編集
    $r->route('/mainte_general_serch')->to('Mainte::General#index');
    $r->route('/mainte_general_new')->to('Mainte::General#index');

    # システム管理者(profile) 新規 編集
    $r->route('/mainte_profile_serch')->to('Mainte::Profile#index');
    $r->route('/mainte_profile_new')->to('Mainte::Profile#index');

    # システム管理者(storeinfo) 新規 編集
    $r->route('/mainte_storeinfo_serch')->to('Mainte::Storeinfo#index');
    $r->route('/mainte_storeinfo_new')->to('Mainte::Storeinfo#index');

    # システム管理者(roominfo) 新規 編集
    $r->route('/mainte_roominfo_serch')->to('Mainte::Roominfo#index');
    $r->route('/mainte_roominfo_new')->to('Mainte::Roominfo#index');

    # システム管理者(reserve) 新規 編集
    $r->route('/mainte_reserve_serch')->to('Mainte::Reserve#index');
    $r->route('/mainte_reserve_new')->to('Mainte::Reserve#index');

    # システム管理者(acting) 新規 編集
    $r->route('/mainte_acting_serch')->to('Mainte::Acting#index');
    $r->route('/mainte_acting_new')->to('Mainte::Acting#index');

    # システム管理者(ads) 新規 編集
    $r->route('/mainte_ads_serch')->to('Mainte::Ads#index');
    $r->route('/mainte_ads_new')->to('Mainte::Ads#index');

    # システム管理者(region) 新規 編集
    $r->route('/mainte_region_serch')->to('Mainte::Region#index');
    $r->route('/mainte_region_new')->to('Mainte::Region#index');

    # システム管理者(post) 新規 編集
    $r->route('/mainte_post_serch')->to('Mainte::Post#index');
    $r->route('/mainte_post_new')->to('Mainte::Post#index');

    # オープニングカレンダー, 今月, 1ヶ月後, 2ヶ月後, 3ヶ月後
    $r->route('/index_next_m')->to('Calendar#index');
    $r->route('/index_next_two_m')->to('Calendar#index');
    $r->route('/index_next_three_m')->to('Calendar#index');
    $r->route('/index')->to('Calendar#index');

    # 登録(entry)
    $r->route('/entry')->to('Entry#index');

    # 予約(region)
    $r->route('/region_state')->to('Region#index');

    # 店舗管理(Management) 選択店舗情報確認
    $r->route('/admin_store_edit')->to('Management::Storeinfo#index');
    $r->route('/admin_store_comp')->to('Management::Storeinfo#index');

    # 店舗管理(Management) 予約部屋情報設定
    $r->route('/admin_reserv_edit')->to('Management::Roominfo#index');
    $r->route('/up_admin_r_d_edit')->to('Management::Roominfo#index');
    $r->route('/admin_reserv_comp')->to('Management::Roominfo#index');
    $r->route('/admin_pub_edit')->to('Management::Roominfo#index');
    $r->route('/admin_pub_comp')->to('Management::Roominfo#index');

    # 店舗管理(Management) 管理者予約
    $r->route('/admin_reserv_list')->to('Management::Reserve#index');

    # 紹介ページ
    $r->route('/tutorial')->to('Tutorial#index');

    # スマホに特化した予約確認画面
    $r->route('/simple_res')->to('Simple#index');

    return;
}

1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku - Yoyakku アプリケーション

=head1 VERSION (改定番号)

This documentation referes to Yoyakku version 0.0.1

=head1 SYNOPSIS (概要)

Yoyakku アプリケーション

=head2 startup

    #!/usr/bin/env perl

    use strict;
    use warnings;

    use FindBin;
    BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

    # Start command line interface for application
    require Mojolicious::Commands;
    Mojolicious::Commands->start_app('Yoyakku');

Yoyakku アプリケーションスタート設定

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
