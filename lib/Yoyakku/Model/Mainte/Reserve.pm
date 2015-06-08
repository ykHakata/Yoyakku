package Yoyakku::Model::Mainte::Reserve;
use strict;
use warnings;
use utf8;
use Yoyakku::Model qw{$teng};
# use Yoyakku::Util qw{now_datetime};
use Yoyakku::Model::Mainte qw{search_id_single_or_all_rows};
use Exporter 'import';
our @EXPORT_OK = qw{
    search_reserve_id_rows
    get_roominfo_with_storeinfo_name_rows
    get_general_rows_all
    get_admin_rows_all
};

sub search_reserve_id_rows {
    my $reserve_id = shift;

    return search_id_single_or_all_rows( 'reserve', $reserve_id );
}


sub get_roominfo_with_storeinfo_name_rows {

    my $sql = q{
        SELECT
            roominfo.id AS roominfo_id,
            roominfo.name AS roominfo_name,
            storeinfo.name AS storeinfo_name
        FROM roominfo INNER JOIN storeinfo
        ON roominfo.storeinfo_id = storeinfo.id
        WHERE roominfo.status = :status
    };

    my $bind_values = +{
        status => '1',
    };

    my @roominfo_with_storeinfo_rows
        = $teng->search_named( $sql, $bind_values );

    return \@roominfo_with_storeinfo_rows;
}

sub get_general_rows_all {
    my @rows = $teng->search('general', +{}, );

    return \@rows;
}

sub get_admin_rows_all {
    my @rows = $teng->search('admin', +{}, );

    return \@rows;
}




# sub search_zipcode_for_address {
#     my $self = shift;
#     my $post = shift;

#     my $address_params = +{
#         region_id => undef,
#         post      => $post,
#         state     => undef,
#         cities    => undef,
#     };

#     my $post_row = $teng->single( 'post', +{ post_id => $post }, );

#     if ($post_row) {
#         $address_params = +{
#             region_id => $post_row->region_id,
#             post      => $post_row->post,
#             state     => $post_row->state,
#             cities    => $post_row->cities,
#         };
#     }

#     return $address_params;
# }


# sub search_reserve_id_row {
#     my $self         = shift;
#     my $reserve_id = shift;

#     die 'not $reserve_id!!' if !$reserve_id;

#     my $reserve_row
#         = $teng->single( 'reserve', +{ id => $reserve_id, }, );

#     die 'not $reserve_row!!' if !$reserve_row;

#     return $reserve_row;
# }

# sub writing_reserve {
#     my $self   = shift;
#     my $type   = shift;
#     my $params = shift;

#     my $create_data_reserve = +{
#         region_id     => $params->{region_id} || undef,
#         admin_id      => $params->{admin_id} || undef,
#         name          => $params->{name},
#         icon          => $params->{icon},
#         post          => $params->{post},
#         state         => $params->{state},
#         cities        => $params->{cities},
#         addressbelow  => $params->{addressbelow},
#         tel           => $params->{tel},
#         mail          => $params->{mail},
#         remarks       => $params->{remarks},
#         url           => $params->{url},
#         locationinfor => $params->{locationinfor},
#         status        => $params->{status},
#         create_on     => now_datetime(),
#         modify_on     => now_datetime(),
#     };

#     my $insert_reserve_row;

#     if ( $type eq 'update' ) {

#         $insert_reserve_row
#             = $teng->single( 'reserve', +{ id => $params->{id} }, );

#         $insert_reserve_row->update($create_data_reserve);
#     }

#     die 'not $insert_reserve_row' if !$insert_reserve_row;

#     return;
# }


1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model::Mainte::Reserve - reserve テーブル管理用 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Mainte::Reserve version 0.0.1

=head1 SYNOPSIS (概要)

Reserve コントローラーのロジック API

=head2 search_zipcode_for_address

    use Yoyakku::Model::Mainte::Reserve qw{search_zipcode_for_address};

    # 郵便番号から住所検索のアクション時
    if ( $params->{kensaku} && $params->{kensaku} eq '検索する' ) {

        my $address_params
            = $self->search_zipcode_for_address( $params->{post} );

        $params->{region_id} = $address_params->{region_id};
        $params->{post}      = $address_params->{post};
        $params->{state}     = $address_params->{state};
        $params->{cities}    = $address_params->{cities};

        return $self->_render_reserve($params);
    }

    # 該当の住所なき場合、各項目は undef を返却

郵便番号から住所を検索、値を返却

=head2 search_reserve_id_rows

    use Yoyakku::Model::Mainte::Reserve qw{search_reserve_id_rows};

    # 指定の id に該当するレコードを row オブジェクトを配列リファレンスで返却
    my $reserve_rows = $self->search_reserve_id_rows($reserve_id);

    # 指定の id に該当するレコードなき場合 reserve 全てのレコード返却

reserve テーブル一覧作成時に利用

=head2 search_reserve_id_row

    use Yoyakku::Model::Mainte::Reserve qw{search_reserve_id_row};

    # 指定の id に該当するレコードを row オブジェクト単体で返却
    my $reserve_row = $self->search_reserve_id_row( $params->{id} );

    # 指定の id に該当するレコードなき場合エラー発生

reserve テーブル修正フォーム表示などに利用

=head2 writing_reserve

    use Yoyakku::Model::Mainte::Reserve qw{writing_reserve};

    # reserve テーブルレコード修正時
    $self->writing_reserve( 'update', $params );
    $self->flash( henkou => '修正完了' );

reserve テーブル書込み、修正に対応

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<Yoyakku::Model>

=item * L<Yoyakku::Util>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
