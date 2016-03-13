package Yoyakku::DB::Model::General;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::DB::Model';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::DB::Model::General - データベース Model

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::DB::Model::General version 0.0.1

=head1 SYNOPSIS (概要)

    general テーブルの API を提供

=cut

=head2 general_db_rows_all

    一般ユーザー情報の全てを row オブジェクトで取得重複確認

=cut

sub general_db_rows_all {
    my $self = shift;
    my $teng = $self->teng();
    my @rows = $teng->search( 'general', +{}, );
    return \@rows;
}

1;

__END__
