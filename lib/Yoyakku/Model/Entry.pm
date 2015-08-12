package Yoyakku::Model::Entry;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model';

=head2 get_header_stash_entry

    ヘッダー初期値取得

=cut

sub get_header_stash_entry {
    my $self = shift;

    my $table      = $self->login_table();
    my $login_row  = $self->login_row();
    my $login_name = $self->login_name();

    my $switch_header = 2;

    return $self->get_header_stash_params( $switch_header, $login_name );
}

1;

__END__
