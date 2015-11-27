package Yoyakku::Model::Region;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model';
use Yoyakku::Util qw{};

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model::Region - 予約用 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Region version 0.0.1

=head1 SYNOPSIS (概要)

Region コントローラーのロジック API

=cut

=head2 get_header_stash_region

    ヘッダー初期値取得

=cut

sub get_header_stash_region {
    my $self = shift;
    my $switch_header = 5;
    return $self->get_header_stash_params( $switch_header );
}


1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<parent>

=item * L<Yoyakku::Model>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
