package Yoyakku::Controller::Mainte::Region;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Mainte::Region;

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Mainte::Region->new();

    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session->{root_id} );

    my $header_stash = $model->get_header_stash_auth_mainte();

    return if !$header_stash;

    $self->stash($header_stash);

    return $model;
}

sub mainte_region_serch {
    my $self  = shift;
    my $model = $self->_init();

    return $self->redirect_to('/index') if !$model;

    my $region_rows = $model->search_region_id_rows();

    $self->stash(
        class       => 'mainte_region_serch',
        region_rows => $region_rows,
    );

    return $self->render(
        template => 'mainte/mainte_region_serch',
        format   => 'html',
    );
}

1;

__END__
