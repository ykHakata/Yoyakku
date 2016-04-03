package Yoyakku::DB::Model::Roominfo;
use Mojo::Base 'Yoyakku::DB::Model::Base';
use Yoyakku::Util qw{now_datetime};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::DB::Model::Roominfo - データベース Model

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::DB::Model::Roominfo version 0.0.1

=head1 SYNOPSIS (概要)

    Roominfo テーブルの API を提供

=cut

has table => 'roominfo';

=head2 single_row_search_id

    id に該当するレコードを row オブジェクトで取得

=cut

sub single_row_search_id {
    my $self = shift;
    my $id   = shift;
    my $teng = $self->teng();
    my $row  = $teng->single( $self->table, +{ id => $id, }, );
    return $row;
}

=head2 writing

    テーブル書込み、新規、修正、両方に対応

=cut

sub writing {
    my $self   = shift;
    my $params = shift;
    my $type   = shift;

    my $create_data = $self->get_create_data($params);

    my $args = +{
        table       => $self->table,
        create_data => $create_data,
        update_id   => $params->{id},
        type        => $type,
    };

    return $self->writing_db($args);
}

=head2 get_create_data

    データベースへの書き込み用データ作成

=cut

sub get_create_data {
    my $self   = shift;
    my $params = shift;

    my $create_data = +{
        storeinfo_id => $params->{storeinfo_id} || undef,
        name         => $params->{name},
        starttime_on => $params->{starttime_on},
        endingtime_on     => $params->{endingtime_on},
        rentalunit        => $params->{rentalunit},
        time_change       => $params->{time_change},
        pricescomments    => $params->{pricescomments},
        privatepermit     => $params->{privatepermit},
        privatepeople     => $params->{privatepeople},
        privateconditions => $params->{privateconditions},
        bookinglimit      => $params->{bookinglimit},
        cancellimit       => $params->{cancellimit},
        remarks           => $params->{remarks},
        webpublishing     => $params->{webpublishing},
        webreserve        => $params->{webreserve},
        status            => $params->{status},
        create_on         => now_datetime(),
        modify_on         => now_datetime(),
    };

    return $create_data;
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::DB::Model::Base>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
