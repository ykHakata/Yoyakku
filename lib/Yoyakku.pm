package Yoyakku;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # コマンドをロードするための他の名前空間
  push @{ $self->commands->namespaces }, 'Yoyakku::Command';

  # Router
  my $r = $self->routes;


    # ログインフォーム 入り口, 一般, 店舗管理者, スーパーユーザー, ログアウト
    my $auth
        = qr{up_login\z|up_login_general|up_login_admin|root_login|up_logout};
    $r->route( '/:action', action => $auth )->to( controller => 'auth' );

    # 個人情報 入力画面, 確認画面
    my $profile = qr{profile\z|profile_comp};
    $r->route( '/:action', action => $profile )->to( controller => 'profile' );

    # システム管理者のオープニング画面
    my $mainte = qr{mainte_list};
    $r->route( '/:action', action => $mainte )->to( controller => 'mainte' );

    # システム管理者(admin)
    my $m_admin = qr{mainte_registrant_serch|mainte_registrant_new};
    $r->route( '/:action', action => $m_admin )->to( controller => 'Mainte::Admin' );

    # システム管理者(general)
    $r->route('/mainte_general_serch')
        ->to( controller => 'Mainte::General', action => 'mainte_general_serch' );

    # システム管理者(general) 新規 編集
    $r->route('/mainte_general_new')
        ->to( controller => 'Mainte::General', action => 'mainte_general_new' );

    # システム管理者(profile)
    $r->route('/mainte_profile_serch')
        ->to( controller => 'Mainte::Profile', action => 'mainte_profile_serch' );

    # システム管理者(profile) 新規 編集
    $r->route('/mainte_profile_new')
        ->to( controller => 'Mainte::Profile', action => 'mainte_profile_new' );

    # システム管理者(storeinfo)
    $r->route('/mainte_storeinfo_serch')
        ->to( controller => 'Mainte::Storeinfo', action => 'mainte_storeinfo_serch' );

    # システム管理者(storeinfo) 新規 編集
    $r->route('/mainte_storeinfo_new')
        ->to( controller => 'Mainte::Storeinfo', action => 'mainte_storeinfo_new' );

    # システム管理者(roominfo)
    $r->route('/mainte_roominfo_serch')
        ->to( controller => 'Mainte::Roominfo', action => 'mainte_roominfo_serch' );

    # システム管理者(roominfo) 新規 編集
    $r->route('/mainte_roominfo_new')
        ->to( controller => 'Mainte::Roominfo', action => 'mainte_roominfo_new' );

    # システム管理者(reserve)
    $r->route('/mainte_reserve_serch')
        ->to( controller => 'Mainte::Reserve', action => 'mainte_reserve_serch' );

    # システム管理者(reserve) 新規 編集
    $r->route('/mainte_reserve_new')
        ->to( controller => 'Mainte::Reserve', action => 'mainte_reserve_new' );

    # システム管理者(acting)
    $r->route('/mainte_acting_serch')
        ->to( controller => 'Mainte::Acting', action => 'mainte_acting_serch' );

    # システム管理者(acting) 新規 編集
    $r->route('/mainte_acting_new')
        ->to( controller => 'Mainte::Acting', action => 'mainte_acting_new' );

    # システム管理者(ads)
    $r->route('/mainte_ads_serch')
        ->to( controller => 'Mainte::Ads', action => 'mainte_ads_serch' );

    # システム管理者(ads) 新規 編集
    $r->route('/mainte_ads_new')
        ->to( controller => 'Mainte::Ads', action => 'mainte_ads_new' );

    # システム管理者(region)
    $r->route('/mainte_region_serch')
        ->to( controller => 'Mainte::Region', action => 'mainte_region_serch' );

    # システム管理者(region) 新規 編集
    $r->route('/mainte_region_new')
        ->to( controller => 'Mainte::Region', action => 'mainte_region_new' );

    # システム管理者(post)
    $r->route('/mainte_post_serch')
        ->to( controller => 'Mainte::Post', action => 'mainte_post_serch' );

    # システム管理者(post) 新規 編集
    $r->route('/mainte_post_new')
        ->to( controller => 'Mainte::Post', action => 'mainte_post_new' );

    # トップページ遷移(/)
    $r->route('/')
        ->to( controller => 'Calendar', action => 'index' );

    # オープニングカレンダー(index)
    $r->route('/index')
        ->to( controller => 'Calendar', action => 'index' );

    # オープニングカレンダー1ヶ月後(index_next_m)
    $r->route('/index_next_m')
        ->to( controller => 'Calendar', action => 'index_next_m' );

    # オープニングカレンダー2ヶ月後(index_next_two_m)
    $r->route('/index_next_two_m')
        ->to( controller => 'Calendar', action => 'index_next_two_m' );

    # オープニングカレンダー3ヶ月後(index_next_three_m)
    $r->route('/index_next_three_m')
        ->to( controller => 'Calendar', action => 'index_next_three_m' );

    # 登録(entry)
    $r->route( '/:entry', entry => qr{entry} )
        ->to( controller => 'Entry', action => 'index' );

    # 予約(region)
    $r->route( '/:region', region => qr{region_state} )
        ->to( controller => 'Region', action => 'index' );

    # 店舗管理(Setting) 選択店舗情報確認
    my $setting_storeinfo = qr{admin_store_edit|admin_store_comp};
    $r->route( '/:store', store => $setting_storeinfo )
        ->to( controller => 'Setting::Storeinfo', action => 'index' );

    # 店舗管理(Setting) 予約部屋情報設定
    my $setting_roominfo = qr{admin_reserv_edit|up_admin_r_d_edit};
    $r->route( '/:room', room => $setting_roominfo )
        ->to( controller => 'Setting::Roominfo', action => 'index' );

    # セッション情報設定
    $self->sessions->cookie_name('yoyakku');

    # ログ情報を STDERR に出力
    $self->log->path('');
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

    use lib 'lib';

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
