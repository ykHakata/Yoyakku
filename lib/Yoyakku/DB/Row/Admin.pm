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

sub get_table_name {
    my $self = shift;
    return 'admin';
}

sub get_login_name {
    my $self = shift;
    my $row = $self->handle->single( 'profile', +{ admin_id => $self->id }, );
    my $login_name = q{(admin)} . $row->nick_name;
    return $login_name;
}

1;

__END__
