package Yoyakku::Controller::Example;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub welcome {
  my $self = shift;

    my $class = '';

    $self->stash( class => $class );

  # Render template "example/welcome.html.ep" with message
  $self->render(msg => 'Welcome to the Mojolicious real-time web framework!');
}

1;
