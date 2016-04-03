package Yoyakku::DB::Model::Storeinfo;
use Mojo::Base 'Yoyakku::DB::Model::Base';
use Yoyakku::Util qw{now_datetime};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::DB::Model::Storeinfo - データベース Model

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::DB::Model::Storeinfo version 0.0.1

=head1 SYNOPSIS (概要)

    Storeinfo テーブルの API を提供

=cut

has table => 'storeinfo';

=head2 rows_all

    店舗情報の全てを row オブジェクトで取得

=cut

sub rows_all {
    my $self = shift;
    my $teng = $self->teng();
    my @rows = $teng->search( $self->table, +{}, );
    return \@rows;
}

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

=head2 storeinfo_rows_region_navi

    地域ナビため、店舗登録をすべて抽出(web公開許可分だけ)

=cut

sub storeinfo_rows_region_navi {
    my $self = shift;
    my $teng = $self->teng();
    my @rows = $teng->search(
        $self->table,
        +{ status   => 0, },
        +{ order_by => 'region_id', },
    );
    return \@rows;
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
        region_id => $params->{region_id} || undef,
        admin_id  => $params->{admin_id}  || undef,
        name      => $params->{name},
        icon      => $params->{icon},
        post      => $params->{post},
        state     => $params->{state},
        cities    => $params->{cities},
        addressbelow  => $params->{addressbelow},
        tel           => $params->{tel},
        mail          => $params->{mail},
        remarks       => $params->{remarks},
        url           => $params->{url},
        locationinfor => $params->{locationinfor},
        status        => $params->{status},
        create_on     => now_datetime(),
        modify_on     => now_datetime(),
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
