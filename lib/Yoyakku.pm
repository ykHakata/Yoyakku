package Yoyakku;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');

    # ログインフォーム入り口
    $r->get('/up_login')->to( controller => 'auth', action => 'up_login' );

    # ログインフォーム(スーパーユーザー)
    $r->route('/root_login')->to( controller => 'auth', action => 'root_login' );
}

1;
