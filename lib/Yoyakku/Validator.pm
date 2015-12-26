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
