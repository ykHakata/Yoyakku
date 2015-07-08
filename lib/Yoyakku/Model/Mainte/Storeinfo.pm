package Yoyakku::Model::Mainte::Storeinfo;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model::Mainte';
use Yoyakku::Model qw{$teng};
use Yoyakku::Util qw{now_datetime get_fill_in_params};

sub search_storeinfo_id_rows {
    my $self = shift;
    return $self->search_id_single_or_all_rows( 'storeinfo',
        $self->params()->{storeinfo_id} );
}

sub get_init_valid_params_storeinfo {
    my $self = shift;
    return $self->get_init_valid_params(
        [   qw{name post state cities addressbelow tel mail remarks url
                locationinfor status }
        ]
    );
}

sub get_update_form_params_storeinfo {
    my $self = shift;
    $self->get_update_form_params('storeinfo');
    return $self;
}

sub search_zipcode_for_address {
    my $self   = shift;
    my $params = $self->params();

    my $post_row = $teng->single( 'post', +{ post_id => $params->{post} }, );

    if ($post_row) {
        $params->{region_id} = $post_row->region_id;
        $params->{post}      = $post_row->post;
        $params->{state}     = $post_row->state;
        $params->{cities}    = $post_row->cities;
    }
    $self->params($params);
    return $self;
}

sub check_storeinfo_validator {
    my $self = shift;

    my $check_params = [
        name          => [ [ 'LENGTH', 0, 20, ], ],
        post          => [ 'INT', ],
        state         => [ [ 'LENGTH', 0, 20, ], ],
        cities        => [ [ 'LENGTH', 0, 20, ], ],
        addressbelow  => [ [ 'LENGTH', 0, 20, ], ],
        tel           => [ [ 'LENGTH', 0, 20, ], ],
        mail          => [ 'EMAIL_LOOSE', ],
        remarks       => [ [ 'LENGTH', 0, 200, ], ],
        url           => [ 'HTTP_URL', ],
        locationinfor => [ [ 'LENGTH', 0, 20, ], ],
        status        => [ 'INT', ],
    ];

    my $msg_params = [
        'name.length'         => '文字数!!',
        'post.int'            => '指定の形式で入力してください',
        'state.length'        => '文字数!!',
        'cities.length'       => '文字数!!',
        'addressbelow.length' => '文字数!!',
        'tel.length'          => '文字数!!',
        'mail.email_loose'    => 'Eメールを入力してください',
        'remarks.length'      => '文字数!!',
        'url.http_url'        => '指定の形式で入力してください',
        'locationinfor.length' => '文字数!!',
        'status.int' => '指定の形式で入力してください',
    ];

    my $msg = $self->get_msg_validator( $check_params, $msg_params, );

    return if !$msg;

    my $valid_msg_storeinfo = +{
        name          => $msg->{name},
        post          => $msg->{post},
        state         => $msg->{state},
        cities        => $msg->{cities},
        addressbelow  => $msg->{addressbelow},
        tel           => $msg->{tel},
        mail          => $msg->{mail},
        remarks       => $msg->{remarks},
        url           => $msg->{url},
        locationinfor => $msg->{locationinfor},
        status        => $msg->{status},
    };

    return $valid_msg_storeinfo;
}

sub writing_storeinfo {
    my $self = shift;

    my $create_data = +{
        region_id     => $self->params()->{region_id} || undef,
        admin_id      => $self->params()->{admin_id} || undef,
        name          => $self->params()->{name},
        icon          => $self->params()->{icon},
        post          => $self->params()->{post},
        state         => $self->params()->{state},
        cities        => $self->params()->{cities},
        addressbelow  => $self->params()->{addressbelow},
        tel           => $self->params()->{tel},
        mail          => $self->params()->{mail},
        remarks       => $self->params()->{remarks},
        url           => $self->params()->{url},
        locationinfor => $self->params()->{locationinfor},
        status        => $self->params()->{status},
        create_on     => now_datetime(),
        modify_on     => now_datetime(),
    };

    # update 以外は禁止
    die 'update only'
        if !$self->type() || ( $self->type() && $self->type() ne 'update' );

    return $self->writing_db( 'storeinfo', $create_data,
        $self->params()->{id} );
}

sub get_fill_in_storeinfo {
    my $self   = shift;
    my $html   = $self->html();
    my $params = $self->params();
    my $output = get_fill_in_params( $html, $params );
    return $output;
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
