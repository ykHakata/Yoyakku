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

sub fetch_reserve {
    my $self        = shift;
    my $search_time = shift;

    my $start_time = $search_time->{start};
    my $end_time   = $search_time->{end};

    # 利用開始日時 getstarted_on
    my @reserve_rows = $self->handle->search(
        'reserve',
        +{  admin_id => $self->id,
            status   => 0,
            getstarted_on =>
                [ '-and', +{ '>=' => $start_time }, +{ '<' => $end_time }, ],
        },
        +{ order_by => 'getstarted_on ASC' },
    );

    return \@reserve_rows;
}

1;

__END__
