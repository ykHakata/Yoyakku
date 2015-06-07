package Yoyakku::Model::Mainte::Roominfo;
use strict;
use warnings;
use utf8;
use Yoyakku::Model qw{$teng};
use Yoyakku::Util qw{now_datetime};
use Exporter 'import';
our @EXPORT_OK = qw{
    search_storeinfo_id_for_roominfo_rows
    search_roominfo_id_row
    writing_roominfo
    check_start_and_end_on
    check_rentalunit
};

sub check_start_and_end_on {
    my $self          = shift;
    my $starttime_on  = shift;
    my $endingtime_on = shift;

    # 営業時間バリデート
    return '開始時刻より遅くしてください'
        if $endingtime_on <= $starttime_on;

    return;
}

sub check_rentalunit {
    my $self          = shift;
    my $starttime_on  = shift;
    my $endingtime_on = shift;
    my $rentalunit    = shift;

    # 貸出単位のバリデート
    my $opening_hours = $endingtime_on - $starttime_on;

    my $division = $opening_hours % $rentalunit;

    return '営業時間が割り切れません' if $division;

    return;
}

sub search_storeinfo_id_for_roominfo_rows {
    my $self         = shift;
    my $storeinfo_id = shift;

    my @roominfo_rows;

    if ( defined $storeinfo_id ) {
        @roominfo_rows
            = $teng->search( 'roominfo', +{ storeinfo_id => $storeinfo_id, }, );
        if ( !scalar @roominfo_rows ) {

            # id 検索しないときはテーブルの全てを出力
            @roominfo_rows = $teng->search( 'roominfo', +{}, );
        }
    }
    else {
        # id 検索しないときはテーブルの全てを出力
        @roominfo_rows = $teng->search( 'roominfo', +{}, );
    }

    return \@roominfo_rows;
}

sub search_roominfo_id_row {
    my $self        = shift;
    my $roominfo_id = shift;

    die 'not $roominfo_id!!' if !$roominfo_id;

    my $roominfo_row = $teng->single( 'roominfo', +{ id => $roominfo_id, }, );

    die 'not $roominfo_row!!' if !$roominfo_row;

    return $roominfo_row;
}

sub writing_roominfo {
    my $self   = shift;
    my $type   = shift;
    my $params = shift;

    # 書き込む前に開始、終了時刻変換
    if ( $params->{starttime_on} =~ /^[2][4-9]$/ ) {
        $params->{starttime_on} -= 24;
        $params->{starttime_on} .= ":00";
    }
    else {
        $params->{starttime_on} .= ":00";
    }
    if ( $params->{endingtime_on} =~ /^[2][4-9]$|^[3][0]$/ ) {
        $params->{endingtime_on} -= 24;
        $params->{endingtime_on} .= ":00";
    }
    else {
        $params->{endingtime_on} .= ":00";
    }

    my $create_data_roominfo = +{
        storeinfo_id      => $params->{storeinfo_id} || undef,
        name              => $params->{name},
        starttime_on      => $params->{starttime_on},
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

    my $insert_roominfo_row;

    if ( $type eq 'update' ) {

        $insert_roominfo_row
            = $teng->single( 'roominfo', +{ id => $params->{id} }, );

        $insert_roominfo_row->update($create_data_roominfo);
    }

    die 'not $insert_roominfo_row' if !$insert_roominfo_row;

    return;
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

=item * L<Yoyakku::Util>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
