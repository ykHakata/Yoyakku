package Yoyakku::DB::Model::Acting;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::DB::Model';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::DB::Model::Acting - データベース Model

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::DB::Model::Acting version 0.0.1

=head1 SYNOPSIS (概要)

    acting テーブルの API を提供

=cut

=head2 acting_db_overlap_id

    general_id, storeinfo_id, 組み合わせの重複確認

=cut

sub acting_db_overlap_id {
    my $self = shift;
    my $args = shift;
    my $teng = $self->teng();

    my $check_acting_row = $teng->single(
        'acting',
        +{  general_id   => $args->{general_id},
            storeinfo_id => $args->{storeinfo_id},
            status       => $args->{status},
        },
    );
    return $check_acting_row;
}

1;

__END__
