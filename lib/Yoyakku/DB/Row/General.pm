package Yoyakku::DB::Row::General;
use parent 'Teng::Row';

sub fetch_profile {
    my $self = shift;
    return $self->handle->single( 'profile', +{ general_id => $self->id }, );
}

sub fetch_actings {
    my $self    = shift;
    my @actings = $teng->search( 'acting',
        +{ general_id => $self->id, status => 1, } );
    return \@actings;
}

sub get_table_name {
    my $self = shift;
    return 'general';
}

1;

__END__
