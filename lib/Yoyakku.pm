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
}

1;
