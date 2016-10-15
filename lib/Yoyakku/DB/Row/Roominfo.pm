package Yoyakku::DB::Row::Roominfo;
use parent 'Teng::Row';

sub search_reserve {
    my $self = shift;
    my $args = shift;
    my @reserve_rows = $self->handle->search(
        'reserve',
        +{  roominfo_id => $self->id,
            %{$args},
        },
    );
    return \@reserve_rows;
}

1;

__END__
