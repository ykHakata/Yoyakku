package Yoyakku::Controller::Mainte::Post;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Mainte::Post;

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Mainte::Post->new();

    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session->{root_id} );

    my $header_stash = $model->get_header_stash_auth_mainte();

    return if !$header_stash;

    $self->stash($header_stash);

    return $model;
}

sub mainte_post_serch {
    my $self  = shift;
    my $model = $self->_init();

    return $self->redirect_to('/index') if !$model;

    my $post_rows = $model->search_post_id_rows();

    $self->stash(
        class     => 'mainte_post_serch',
        post_rows => $post_rows,
    );

    return $self->render(
        template => 'mainte/mainte_post_serch',
        format   => 'html',
    );
}

1;

__END__
