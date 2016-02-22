package Yoyakku::DB::Row::General;
use parent 'Teng::Row';

sub fetch_profile {
    my $self = shift;
    return $self->handle->single( 'profile', +{ general_id => $self->id }, );
}

sub fetch_actings {
    my $self    = shift;
    my @actings = $self->handle->search( 'acting',
        +{ general_id => $self->id, status => 1, } );
    return \@actings;
}

sub get_table_name {
    my $self = shift;
    return 'general';
}

sub get_login_name {
    my $self = shift;
    my $row
        = $self->handle->single( 'profile', +{ general_id => $self->id }, );
    return $row->nick_name;
}

1;

__END__
