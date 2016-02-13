package Yoyakku::Validator;
use strict;
use warnings;
use utf8;
use base qw{Class::Accessor::Fast};
use FormValidator::Lite qw{Email URL DATE TIME};
use Yoyakku::Util qw{get_start_end_tp};
use parent 'Yoyakku::Model';

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

=head2 admin

    バリデート処理(admin)

=cut

sub admin {
    my $self   = shift;
    my $params = shift;

    my $check_params = [
        login    => [ 'NOT_NULL', ],
        password => [ 'NOT_NULL', ],
    ];

    my $msg_params = [
        'login.not_null'    => '必須入力',
        'password.not_null' => '必須入力',
    ];

    my $arg = +{
        check_params => $check_params,
        msg_params   => $msg_params,
        params       => $params,
    };

    my $msg = $self->get_msg_validator($arg);

    return if !$msg;

    my $valid_msg_admin = +{
        login    => $msg->{login},
        password => $msg->{password},
    };

    return $valid_msg_admin;
}

=head2 general

    バリデート処理(general)

=cut

sub general {
    my $self   = shift;
    my $params = shift;

    my $check_params = [
        login    => [ 'NOT_NULL', ],
        password => [ 'NOT_NULL', ],
    ];

    my $msg_params = [
        'login.not_null'    => '必須入力',
        'password.not_null' => '必須入力',
    ];

    my $arg = +{
        check_params => $check_params,
        msg_params   => $msg_params,
        params       => $params,
    };

    my $msg = $self->get_msg_validator($arg);

    return if !$msg;

    my $valid_msg_general = +{
        login    => $msg->{login},
        password => $msg->{password},
    };

    return $valid_msg_general;
}

=head2 profile

    バリデート処理(profile)

=cut

sub profile {
    my $self   = shift;
    my $params = shift;

    my $check_params = [
        general_id    => [ 'INT', ],
        admin_id      => [ 'INT', ],
        nick_name     => [ [ 'LENGTH', 0, 20, ], ],
        full_name     => [ [ 'LENGTH', 0, 20, ], ],
        phonetic_name => [ [ 'LENGTH', 0, 20, ], ],
        tel           => [ [ 'LENGTH', 0, 20, ], ],
        mail          => [ 'EMAIL_LOOSE', ],
    ];

    my $msg_params = [
        'general_id.not_null' => '指定の形式で入力してください',
        'admin_id.not_null'   => '指定の形式で入力してください',
        'nick_name.length'    => '文字数!!',
        'full_name.length'    => '文字数!!',
        'phonetic_name.length' => '文字数!!',
        'tel.length'           => '文字数!!',
        'mail.email_loose'     => 'Eメールを入力してください',
    ];

    my $arg = +{
        check_params => $check_params,
        msg_params   => $msg_params,
        params       => $params,
    };

    my $msg = $self->get_msg_validator($arg);

    return if !$msg;

    my $valid_msg_profile = +{
        general_id    => $msg->{general_id},
        admin_id      => $msg->{admin_id},
        nick_name     => $msg->{nick_name},
        full_name     => $msg->{full_name},
        phonetic_name => $msg->{phonetic_name},
        tel           => $msg->{tel},
        mail          => $msg->{mail},
    };

    return $valid_msg_profile;
}

=head2 reserve

    バリデート処理(reserve)

=cut

sub reserve {
    my $self   = shift;
    my $params = shift;

    my $check_params = [
        roominfo_id        => [ 'INT', ],
        getstarted_on_day  => [ 'NOT_NULL', 'DATE', ],
        enduse_on_day      => [ 'NOT_NULL', 'DATE', ],
        getstarted_on_time => [ 'NOT_NULL', ],
        enduse_on_time     => [ 'NOT_NULL', ],
        +{ on_day => [ 'getstarted_on_day', 'enduse_on_day', ], } =>
            ['DUPLICATION'],
        useform    => [ 'INT', ],
        message    => [ [ 'LENGTH', 0, 20, ], ],
        general_id => [ 'INT', ],
        admin_id   => [ 'INT', ],
        tel        => [ 'NOT_NULL', [ 'LENGTH', 0, 20, ], ],
        status     => [ 'INT', ],
    ];

    my $msg_params = [
        'roominfo_id.int' => '指定の形式で入力してください',
        'getstarted_on_day.not_null' => '必須入力',
        'enduse_on_day.not_null'     => '必須入力',
        'getstarted_on_day.date' =>
            '日付の形式で入力してください',
        'enduse_on_day.date' => '日付の形式で入力してください',
        'on_day.duplication' => '開始と同じ日付にして下さい',
        'useform.int'        => '指定の形式で入力してください',
        'message.length'     => '文字数!!',
        'general_id.int'     => '指定の形式で入力してください',
        'admin_id.int'       => '指定の形式で入力してください',
        'tel.not_null'       => '必須入力',
        'tel.length'         => '文字数!!',
        'status.int'         => '指定の形式で入力してください',
    ];

    my $arg = +{
        check_params => $check_params,
        msg_params   => $msg_params,
        params       => $params,
    };

    my $msg = $self->get_msg_validator($arg);

    my $valid_msg_reserve = +{
        id                 => '',
        roominfo_id        => $msg->{roominfo_id},
        getstarted_on_day  => $msg->{getstarted_on_day},
        getstarted_on_time => $msg->{getstarted_on_time},
        enduse_on_day      => $msg->{enduse_on_day} || $msg->{on_day},
        enduse_on_time     => $msg->{enduse_on_time},
        useform            => $msg->{useform},
        message            => $msg->{message},
        general_id         => $msg->{general_id},
        admin_id           => $msg->{admin_id},
        tel                => $msg->{tel},
        status             => $msg->{status},
    };

    return $valid_msg_reserve if scalar values %{$msg};

    # 日付の計算をするために通常の日時の表記に変更
    $params = $self->change_format_datetime($params);

    # 利用終了時刻が開始時刻より早くなっていないか？
    my $check_reserve_use_time = _check_reserve_use_time($params);

    $valid_msg_reserve->{enduse_on_time} = $check_reserve_use_time;

    return $valid_msg_reserve if $check_reserve_use_time;

    return;
}

=head2 _check_reserve_use_time

    入力された利用希望時間の適正をチェック

=cut

sub _check_reserve_use_time {
    my $params = shift;

    my $start_date_time = $params->{getstarted_on};
    my $end_date_time   = $params->{enduse_on};

    # 日付のオブジェクトに変換
    my ( $start_tp, $end_tp, )
        = get_start_end_tp( $start_date_time, $end_date_time, );

    # 日付のオブジェクトで比較
    return '開始時刻より遅くして下さい' if $start_tp >= $end_tp;

    # 不合格時はメッセージ、合格時は undef
    return;
}

=head2 acting

    バリデート処理(acting)

=cut

sub acting {
    my $self   = shift;
    my $params = shift;

    my $check_params = [
        general_id   => [ 'NOT_NULL', ],
        storeinfo_id => [ 'NOT_NULL', ],
    ];

    my $msg_params = [
        'general_id.not_null'   => '両方を選んでください',
        'storeinfo_id.not_null' => '両方を選んでください',
    ];

    my $arg = +{
        check_params => $check_params,
        msg_params   => $msg_params,
        params       => $params,
    };

    my $msg = $self->get_msg_validator($arg);

    return if !$msg;

    return +{
        general_id   => $msg->{general_id},
        storeinfo_id => $msg->{storeinfo_id},
    };
}

=head2 ads

    バリデート処理(ads)

=cut

sub ads {
    my $self   = shift;
    my $params = shift;

    my $check_params = [
        url             => [ 'NOT_NULL', 'HTTP_URL', ],
        displaystart_on => [ 'NOT_NULL', 'DATE', ],
        displayend_on   => [ 'NOT_NULL', 'DATE', ],
        name       => [ 'NOT_NULL', [ 'LENGTH', 0, 30, ], ],
        content    => [ 'NOT_NULL', [ 'LENGTH', 0, 140, ], ],
        event_date => [ 'NOT_NULL', [ 'LENGTH', 0, 30, ], ],
    ];

    my $msg_params = [
        'url.not_null'             => '必須入力',
        'displaystart_on.not_null' => '必須入力',
        'displayend_on.not_null'   => '必須入力',
        'name.not_null'            => '必須入力',
        'content.not_null'         => '必須入力',
        'event_date.not_null'      => '必須入力',
        'url.http_url' => '指定の形式で入力してください',
        'displaystart_on.date' =>
            '日付の形式で入力してください',
        'displayend_on.date' => '日付の形式で入力してください',
        'name.length'        => '文字数!!',
        'content.length'     => '文字数!!',
        'event_date.length'  => '文字数!!',
    ];

    my $arg = +{
        check_params => $check_params,
        msg_params   => $msg_params,
        params       => $params,
    };

    my $msg = $self->get_msg_validator($arg);

    return if !$msg;

    return +{
        url             => $msg->{url},
        displaystart_on => $msg->{displaystart_on},
        displayend_on   => $msg->{displayend_on},
        name            => $msg->{name},
        content         => $msg->{content},
        event_date      => $msg->{event_date},
    };
}

=head2 entry

    バリデート処理(entry)

=cut

sub entry {
    my $self   = shift;
    my $params = shift;

    my $check_params = [ mail_j => [ 'NOT_NULL', 'EMAIL_LOOSE' ], ];

    my $msg_params = [
        'mail_j.email_loose' => 'Eメールを入力してください',
        'mail_j.not_null'    => '必須入力',
    ];

    my $arg = +{
        check_params => $check_params,
        msg_params   => $msg_params,
        params       => $params,
    };

    my $msg = $self->get_msg_validator($arg);

    return if !$msg;

    return +{ mail_j => $msg->{mail_j}, };
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

    my @start = split ':', $starttime_on;
    my @end   = split ':', $endingtime_on;

    $starttime_on  = shift @start;
    $endingtime_on = shift @end;

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

    return if !$starttime_on;
    return if !$endingtime_on;
    return if !$rentalunit;

    my @start = split ':', $starttime_on;
    my @end   = split ':', $endingtime_on;

    $starttime_on  = shift @start;
    $endingtime_on = shift @end;

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
