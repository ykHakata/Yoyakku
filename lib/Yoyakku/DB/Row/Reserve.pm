package Yoyakku::DB::Row::Reserve;
use parent 'Teng::Row';

sub fetch_profile_general {
    my $self = shift;
    return $self->handle->single( 'profile',
        +{ general_id => $self->general_id } );
}

sub fetch_profile_admin {
    my $self = shift;
    return $self->handle->single( 'profile',
        +{ admin_id => $self->admin_id } );
}

sub fetch_roominfo {
    my $self = shift;
    return $self->handle->single( 'roominfo', +{ id => $self->roominfo_id } );
}

1;

__END__
