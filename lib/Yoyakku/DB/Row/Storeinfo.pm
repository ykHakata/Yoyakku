package Yoyakku::DB::Row::Storeinfo;
use parent 'Teng::Row';

sub fetch_roominfos {
    my $self = shift;
    my @roominfo_rows
        = $self->handle->search( 'roominfo', +{ storeinfo_id => $self->id },
        );
    return \@roominfo_rows;
}

sub get_roominfo_ids {
    my $self = shift;
    my @rows
        = $self->handle->search( 'roominfo', +{ storeinfo_id => $self->id },
        );
    my $ids = [ map { $_->id } @rows ];
    return $ids;
}

sub search_roominfos {
    my $self = shift;
    my $args = shift;
    my @roominfo_rows
        = $self->handle->search( 'roominfo',
        +{ storeinfo_id => $self->id, %{$args}, },
        );
    return \@roominfo_rows;
}

1;

__END__
