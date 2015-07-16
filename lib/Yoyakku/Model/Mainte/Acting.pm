package Yoyakku::Model::Mainte::Acting;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model::Mainte';
use Yoyakku::Util qw{now_datetime get_fill_in_params};

sub search_acting_id_rows {
    my $self = shift;
    return $self->search_id_single_or_all_rows( 'acting',
        $self->params()->{id} );
}

sub get_init_valid_params_acting {
    my $self = shift;
    return $self->get_init_valid_params( [qw{general_id storeinfo_id}] );
}

sub get_general_rows_all {
    my $self         = shift;
    my $teng         = $self->teng();
    my @general_rows = $teng->search( 'general', +{}, );
    return \@general_rows;
}

sub get_storeinfo_rows_all {
    my $self           = shift;
    my $teng           = $self->teng();
    my @storeinfo_rows = $teng->search( 'storeinfo', +{}, );
    return \@storeinfo_rows;
}

sub get_fill_in_acting {
    my $self   = shift;
    my $html   = $self->html();
    my $params = $self->params();
    my $output = get_fill_in_params( $html, $params );
    return $output;
}

1;

__END__
