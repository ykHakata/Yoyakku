package Yoyakku::DB::Row::Reserve;
use parent 'Teng::Row';

sub fetch_profile {
    my $self = shift;
    return $self->handle->single( 'profile',
        +{ general_id => $self->general_id },
    );
}

1;

__END__
