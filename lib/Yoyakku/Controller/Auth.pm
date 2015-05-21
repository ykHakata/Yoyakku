package Yoyakku::Controller::Auth;
use Mojo::Base 'Mojolicious::Controller';

sub up_login {
    my $self = shift;

    # テンプレート用bodyのクラス名
    my $class = 'up_login_admin';

    $self->stash( class => $class );

    $self->render( template => 'auth/up_login', format => 'html' );
}

1;

__END__

# up_login.html.ep
# ログインフォーム入り口========================================
get '/up_login' => sub {
    my $self = shift;
    # テンプレート用bodyのクラス名
    my $class = "up_login_admin";
    $self->stash(class => $class);

    $self->render('up_login');
};
