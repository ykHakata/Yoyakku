package Yoyakku;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

    # ログインフォーム入り口
    $r->get('/up_login')->to( controller => 'auth', action => 'up_login' );

    # ログインフォーム(一般)
    $r->route('/up_login_general')
        ->to( controller => 'auth', action => 'up_login_general' );

    # ログインフォーム(店舗管理者)
    $r->route('/up_login_admin')
        ->to( controller => 'auth', action => 'up_login_admin' );

    # ログインフォーム(スーパーユーザー)
    $r->route('/root_login')
        ->to( controller => 'auth', action => 'root_login' );

    # ログアウト
    $r->route('/up_logout')
        ->to( controller => 'auth', action => 'up_logout' );

    # 個人情報(入力画面)
    $r->route('/profile')
        ->to( controller => 'profile', action => 'profile' );

    # システム管理者のオープニング画面
    $r->route('/mainte_list')
        ->to( controller => 'mainte', action => 'mainte_list' );

    # システム管理者(admin)
    $r->route('/mainte_registrant_serch')
        ->to( controller => 'Mainte::Admin', action => 'mainte_registrant_serch' );

    # システム管理者(admin) 新規 編集
    $r->route('/mainte_registrant_new')
        ->to( controller => 'Mainte::Admin', action => 'mainte_registrant_new' );

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
