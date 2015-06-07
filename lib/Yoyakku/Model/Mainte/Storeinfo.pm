package Yoyakku::Model::Mainte::Storeinfo;
use strict;
use warnings;
use utf8;
use Yoyakku::Model qw{$teng};
use Yoyakku::Model::Mainte qw{
    search_id_single_or_all_rows
    get_single_row_search_id
    writing_db
};
use Yoyakku::Util qw{now_datetime};
use Exporter 'import';
our @EXPORT_OK = qw{
    search_storeinfo_id_rows
    search_storeinfo_id_row
    search_zipcode_for_address
    writing_storeinfo
};

sub search_zipcode_for_address {
    my $self = shift;
    my $post = shift;

    my $address_params = +{
        region_id => undef,
        post      => $post,
        state     => undef,
        cities    => undef,
    };

    my $post_row = $teng->single( 'post', +{ post_id => $post }, );

    if ($post_row) {
        $address_params = +{
            region_id => $post_row->region_id,
            post      => $post_row->post,
            state     => $post_row->state,
            cities    => $post_row->cities,
        };
    }

    return $address_params;
}

sub search_storeinfo_id_rows {
    my $self         = shift;
    my $storeinfo_id = shift;

    return search_id_single_or_all_rows( 'storeinfo', $storeinfo_id );
}

sub search_storeinfo_id_row {
    my $self         = shift;
    my $storeinfo_id = shift;

    return get_single_row_search_id( 'storeinfo', $storeinfo_id );
}

sub writing_storeinfo {
    my $self   = shift;
    my $type   = shift;
    my $params = shift;

    my $create_data = +{
        region_id     => $params->{region_id} || undef,
        admin_id      => $params->{admin_id} || undef,
        name          => $params->{name},
        icon          => $params->{icon},
        post          => $params->{post},
        state         => $params->{state},
        cities        => $params->{cities},
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

    # update 以外は禁止
    die 'update only' if !$type || ( $type && $type ne 'update' );

    return writing_db( 'storeinfo', $type, $create_data, $params->{id} );
}


1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model::Mainte::Storeinfo - storeinfo テーブル管理用 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Mainte::Storeinfo version 0.0.1

=head1 SYNOPSIS (概要)

Storeinfo コントローラーのロジック API

=head2 search_zipcode_for_address

    use Yoyakku::Model::Mainte::Storeinfo qw{search_zipcode_for_address};

    # 郵便番号から住所検索のアクション時
    if ( $params->{kensaku} && $params->{kensaku} eq '検索する' ) {

        my $address_params
            = $self->search_zipcode_for_address( $params->{post} );

        $params->{region_id} = $address_params->{region_id};
        $params->{post}      = $address_params->{post};
        $params->{state}     = $address_params->{state};
        $params->{cities}    = $address_params->{cities};

        return $self->_render_storeinfo($params);
    }

    # 該当の住所なき場合、各項目は undef を返却

郵便番号から住所を検索、値を返却

=head2 search_storeinfo_id_rows

    use Yoyakku::Model::Mainte::Storeinfo qw{search_storeinfo_id_rows};

    # 指定の id に該当するレコードを row オブジェクトを配列リファレンスで返却
    my $storeinfo_rows = $self->search_storeinfo_id_rows($storeinfo_id);

    # 指定の id に該当するレコードなき場合 storeinfo 全てのレコード返却

storeinfo テーブル一覧作成時に利用

=head2 search_storeinfo_id_row

    use Yoyakku::Model::Mainte::Storeinfo qw{search_storeinfo_id_row};

    # 指定の id に該当するレコードを row オブジェクト単体で返却
    my $storeinfo_row = $self->search_storeinfo_id_row( $params->{id} );

    # 指定の id に該当するレコードなき場合エラー発生

storeinfo テーブル修正フォーム表示などに利用

=head2 writing_storeinfo

    use Yoyakku::Model::Mainte::Storeinfo qw{writing_storeinfo};

    # storeinfo テーブルレコード修正時
    $self->writing_storeinfo( 'update', $params );
    $self->flash( henkou => '修正完了' );

storeinfo テーブル書込み、修正に対応

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<Yoyakku::Model>

=item * L<Yoyakku::Model::Mainte>

=item * L<Yoyakku::Util>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
