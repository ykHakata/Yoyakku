package Yoyakku::DB::Row::Storeinfo;
use parent 'Teng::Row';

sub fetch_roominfos {
    my $self = shift;
    my @roominfo_rows
        = $self->handle->search( 'roominfo', +{ storeinfo_id => $self->id },
        );
    return \@roominfo_rows;
}

1;

__END__
