package Yoyakku::Validator;
use strict;
use warnings;
use utf8;
use base qw{Class::Accessor::Fast};
use FormValidator::Lite qw{Email URL DATE TIME};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Validator - バリデーテョン関連 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Validator version 0.0.1

=head1 SYNOPSIS (概要)

    バリデーテョン関連の API を提供

=cut

=head2 get_msg_validator

    入力値バリデート処理

=cut

sub get_msg_validator {
    my $self = shift;
    my $arg  = shift;

    my $validator = FormValidator::Lite->new( $arg->{params} );
    $validator->check( @{ $arg->{check_params} } );
    $validator->set_message( @{ $arg->{msg_params} } );

    my $error_params = [ map {$_} keys %{ $validator->errors() } ];

    my $msg = +{};
    for my $error_param ( @{$error_params} ) {
        $msg->{$error_param}
            = $validator->get_error_messages_from_param($error_param);
        $msg->{$error_param} = shift @{ $msg->{$error_param} };
    }

    return $msg if $validator->has_error();
    return;
}

=head2 storeinfo

    バリデート処理(storeinfo)

=cut

sub storeinfo {
    my $self   = shift;
    my $params = shift;

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

    my $arg = +{
        check_params => $check_params,
        msg_params   => $msg_params,
        params       => $params,
    };

    my $msg = $self->get_msg_validator($arg);

    return if !$msg;

    my $valid_msg = +{
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

    return $valid_msg;
}

=head2 roominfo

    バリデート処理(roominfo)

=cut

sub roominfo {
    my $self   = shift;
    my $params = shift;

    my $check_params = [
        name              => [ [ 'LENGTH', 0, 2, ], [ REGEXP => qr/\S/ ] ],
        starttime_on      => [ [ 'LENGTH', 0, 20, ], ],
        endingtime_on     => [ [ 'LENGTH', 0, 20, ], ],
        rentalunit        => [ 'INT', ],
        time_change       => [ 'INT', ],
        pricescomments    => [ [ 'LENGTH', 0, 20, ], ],
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
        'name.regexp'          => '空白文字は不可!!',
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

    my $arg = +{
        check_params => $check_params,
        msg_params   => $msg_params,
        params       => $params,
    };

    my $msg = $self->get_msg_validator($arg);

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
    my $check_start_and_end_msg = $self->_check_start_and_end_on($params);

    $valid_msg_roominfo->{endingtime_on} = $check_start_and_end_msg;

    return $valid_msg_roominfo if $check_start_and_end_msg;

    # starttime_on, endingtime_on, rentalunit, 貸出単位のバリデート
    my $check_rentalunit_msg = $self->_check_rentalunit($params);

    $valid_msg_roominfo->{rentalunit} = $check_rentalunit_msg;

    return $valid_msg_roominfo if $check_rentalunit_msg;

    return;
}

=head2 _check_start_and_end_on

    starttime_on, endingtime_on, 営業時間の時間指定の確認

=cut

sub _check_start_and_end_on {
    my $self   = shift;
    my $params = shift;

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
    my $params = shift;

    my $starttime_on  = $params->{starttime_on};
    my $endingtime_on = $params->{endingtime_on};
    my $rentalunit    = $params->{rentalunit};

    # 貸出単位のバリデート
    my $opening_hours = $endingtime_on - $starttime_on;

    my $division = $opening_hours % $rentalunit;

    return '営業時間が割り切れません' if $division;

    return;
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<base>

=item * L<Class::Accessor::Fast>

=item * L<FormValidator::Lite>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
