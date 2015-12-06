package Yoyakku::Model::Mainte::Roominfo;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model::Mainte';
use Yoyakku::Util qw{now_datetime get_fill_in_params};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Mainte::Roominfo - storeinfo テーブル管理用 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Mainte::Roominfo version 0.0.1

=head1 SYNOPSIS (概要)

    Roominfo コントローラーのロジック API

=cut

=head2 search_storeinfo_id_for_roominfo_rows

    roominfo テーブル一覧作成時に利用

=cut

sub search_storeinfo_id_for_roominfo_rows {
    my $self = shift;
    return $self->search_id_single_or_all_rows( 'roominfo',
        $self->params()->{storeinfo_id} );
}

sub get_init_valid_params_roominfo {
    my $self = shift;
    return $self->get_init_valid_params(
        [qw{name endingtime_on rentalunit pricescomments remarks}] );
}

sub get_update_form_params_roominfo {
    my $self = shift;
    $self->get_update_form_params('roominfo');
    return $self;
}

sub check_roominfo_validator {
    my $self = shift;

    my $check_params = [
        name              => [ [ 'LENGTH', 0, 20, ], ],
        starttime_on      => [ [ 'LENGTH', 0, 20, ], ],
        endingtime_on     => [ [ 'LENGTH', 0, 20, ], ],
        rentalunit        => [ 'INT', ],
        time_change       => [ 'INT', ],
        pricescomments    => [ [ 'LENGTH', 0, 200, ], ],
        privatepermit     => [ 'INT', ],
        privatepeople     => [ 'INT', ],
        privateconditions => [ 'INT', ],
        bookinglimit      => [ 'INT', ],
        cancellimit       => [ 'INT', ],
        remarks           => [ [ 'LENGTH', 0, 200, ], ],
        webpublishing     => [ 'INT', ],
        webreserve        => [ 'INT', ],
        status            => [ 'INT', ],
    ];

    my $msg_params = [
        'name.length'          => '文字数!!',
        'starttime_on.length'  => '文字数!!',
        'endingtime_on.length' => '文字数!!',
        'rentalunit.int'  => '指定の形式で入力してください',
        'time_change.int' => '指定の形式で入力してください',
        'pricescomments.length' => '文字数!!',
        'privatepermit.int' => '指定の形式で入力してください',
        'privatepeople.int' => '指定の形式で入力してください',
        'privateconditions.int' =>
            '指定の形式で入力してください',
        'bookinglimit.int'  => '指定の形式で入力してください',
        'cancellimit.int'   => '指定の形式で入力してください',
        'remarks.length'    => '文字数!!',
        'webpublishing.int' => '指定の形式で入力してください',
        'webreserve.int'    => '指定の形式で入力してください',
        'status.int'        => '指定の形式で入力してください',
    ];

    my $msg = $self->get_msg_validator( $check_params, $msg_params, );

    my $valid_msg_roominfo = +{
        name              => $msg->{name},
        starttime_on      => $msg->{starttime_on},
        endingtime_on     => $msg->{endingtime_on},
        rentalunit        => $msg->{rentalunit},
        time_change       => $msg->{time_change},
        pricescomments    => $msg->{pricescomments},
        privatepermit     => $msg->{privatepermit},
        privatepeople     => $msg->{privatepeople},
        privateconditions => $msg->{privateconditions},
        bookinglimit      => $msg->{bookinglimit},
        cancellimit       => $msg->{cancellimit},
        remarks           => $msg->{remarks},
        webpublishing     => $msg->{webpublishing},
        webreserve        => $msg->{webreserve},
        status            => $msg->{status},
    };

    return $valid_msg_roominfo if scalar values %{$msg};

    # starttime_on, endingtime_on, 営業時間のバリデート
    my $check_start_and_end_msg = $self->_check_start_and_end_on();

    $valid_msg_roominfo->{endingtime_on} = $check_start_and_end_msg;

    return $valid_msg_roominfo if $check_start_and_end_msg;

    # starttime_on, endingtime_on, rentalunit, 貸出単位のバリデート
    my $check_rentalunit_msg = $self->_check_rentalunit();

    $valid_msg_roominfo->{rentalunit} = $check_rentalunit_msg;

    return $valid_msg_roominfo if $check_rentalunit_msg;

    return;
}

=head2 _check_start_and_end_on

    starttime_on, endingtime_on, 営業時間の時間指定の確認

=cut

sub _check_start_and_end_on {
    my $self   = shift;
    my $params = $self->params();

    my $starttime_on  = $params->{starttime_on};
    my $endingtime_on = $params->{endingtime_on};

    # 営業時間バリデート
    return '開始時刻より遅くしてください'
        if $endingtime_on <= $starttime_on;

    return;
}

=head2 _check_rentalunit

    rentalunit, 貸出単位の指定バリデート

=cut

sub _check_rentalunit {
    my $self   = shift;
    my $params = $self->params();

    my $starttime_on  = $params->{starttime_on};
    my $endingtime_on = $params->{endingtime_on};
    my $rentalunit    = $params->{rentalunit};

    # 貸出単位のバリデート
    my $opening_hours = $endingtime_on - $starttime_on;

    my $division = $opening_hours % $rentalunit;

    return '営業時間が割り切れません' if $division;

    return;
}

=head2 writing_roominfo

    roominfo テーブル書込み、修正に対応

=cut

sub writing_roominfo {
    my $self   = shift;
    my $params = $self->params();

    # 書き込む前に開始、終了時刻変換
    my $FIELD_SEPARATOR_TIME = q{:};
    my $FIELD_COUNT_TIME     = 3;

    my ( $start_hour, $start_minute, $start_second, )
        = split $FIELD_SEPARATOR_TIME, $params->{starttime_on},
        $FIELD_COUNT_TIME + 1;

    my ( $end_hour, $end_minute, $end_second, ) = split $FIELD_SEPARATOR_TIME,
        $params->{endingtime_on}, $FIELD_COUNT_TIME + 1;

    # 数字にもどす
    $start_hour += 0;
    $end_hour   += 0;

    # 時間の表示を変換
    if ( $start_hour >= 24 && $start_hour <= 30 ) {
        $start_hour -= 24;
    }

    if ( $end_hour >= 24 && $end_hour <= 30 ) {
        $end_hour -= 24;
    }

    $params->{starttime_on} = join ':', $start_hour, $start_minute,
        $start_second;
    $params->{endingtime_on} = join ':', $end_hour, $end_minute, $end_second;

    $params->{starttime_on}  = sprintf '%08s', $params->{starttime_on};
    $params->{endingtime_on} = sprintf '%08s', $params->{endingtime_on};

    my $create_data = +{
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

    # update 以外は禁止
    die 'update only'
        if !$self->type() || ( $self->type() && $self->type() ne 'update' );

    return $self->writing_db( 'roominfo', $create_data, $params->{id} );
}

sub get_fill_in_roominfo {
    my $self   = shift;
    my $html   = $self->html();
    my $params = $self->params();
    my $output = get_fill_in_params( $html, $params );
    return $output;
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<parent>

=item * L<Yoyakku::Model::Mainte>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
