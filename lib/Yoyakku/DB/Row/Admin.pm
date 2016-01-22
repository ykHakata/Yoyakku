package Yoyakku::DB::Row::Admin;
use parent 'Teng::Row';

sub fetch_profile {
    my $self = shift;
    return $self->handle->single( 'profile', +{ admin_id => $self->id }, );
}

sub fetch_storeinfo {
    my $self = shift;
    return $self->handle->single( 'storeinfo', +{ admin_id => $self->id }, );
}

1;

__END__
