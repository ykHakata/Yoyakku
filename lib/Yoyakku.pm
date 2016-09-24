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
    my $mainte = qr{mainte_list};
    $r->route( '/:mainte', mainte => $mainte )->to('Mainte#index');

    # システム管理者(admin) 新規 編集
    my $mainte_admin = qr{mainte_registrant_serch|mainte_registrant_new};
    $r->route( '/:mainte_admin', mainte_admin => $mainte_admin )
        ->to('Mainte::Admin#index');

    # システム管理者(general) 新規 編集
    my $mainte_general = qr{mainte_general_serch\z|mainte_general_new\z};
    $r->route( '/:mainte_general', mainte_general => $mainte_general )
        ->to('Mainte::General#index');

    # システム管理者(profile) 新規 編集
    my $mainte_profile = qr{mainte_profile_serch\z|mainte_profile_new\z};
    $r->route( '/:mainte_profile', mainte_profile => $mainte_profile )
        ->to('Mainte::Profile#index');

    # システム管理者(storeinfo) 新規 編集
    my $mainte_storeinfo
        = qr{mainte_storeinfo_serch\z|mainte_storeinfo_new\z};
    $r->route( '/:mainte_storeinfo', mainte_storeinfo => $mainte_storeinfo )
        ->to('Mainte::Storeinfo#index');

    # システム管理者(roominfo) 新規 編集
    my $mainte_roominfo = qr{mainte_roominfo_serch\z|mainte_roominfo_new\z};
    $r->route( '/:mainte_roominfo', mainte_roominfo => $mainte_roominfo )
        ->to('Mainte::Roominfo#index');

    # システム管理者(reserve) 新規 編集
    my $mainte_reserve = qr{mainte_reserve_serch\z|mainte_reserve_new\z};
    $r->route( '/:mainte_reserve', mainte_reserve => $mainte_reserve )
        ->to('Mainte::Reserve#index');

    # システム管理者(acting) 新規 編集
    my $mainte_acting = qr{mainte_acting_serch\z|mainte_acting_new\z};
    $r->route( '/:mainte_acting', mainte_acting => $mainte_acting )
        ->to('Mainte::Acting#index');

    # システム管理者(ads) 新規 編集
    my $mainte_ads = qr{mainte_ads_serch\z|mainte_ads_new\z};
    $r->route( '/:mainte_ads', mainte_ads => $mainte_ads )
        ->to('Mainte::Ads#index');

    # システム管理者(region) 新規 編集
    my $mainte_region = qr{mainte_region_serch\z|mainte_region_new\z};
    $r->route( '/:mainte_region', mainte_region => $mainte_region )
        ->to('Mainte::Region#index');

    # システム管理者(post) 新規 編集
    my $mainte_post = qr{mainte_post_serch\z|mainte_post_new\z};
    $r->route( '/:mainte_post', mainte_post => $mainte_post )
        ->to('Mainte::Post#index');

    # オープニングカレンダー, 今月, 1ヶ月後, 2ヶ月後, 3ヶ月後
    my $cal
        = qr{index\z|index_next_m\z|index_next_two_m\z|index_next_three_m\z};
    $r->route( '/:cal', cal => $cal )->to('Calendar#index');

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
