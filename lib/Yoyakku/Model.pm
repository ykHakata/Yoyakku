package Yoyakku::Model;
use strict;
use warnings;
use utf8;
use Teng;
use Teng::Schema::Loader;
use FormValidator::Lite qw{Email URL DATE TIME};
use base qw{Class::Accessor::Fast};
use Yoyakku::Util qw{now_datetime switch_header_params};
use Encode qw{encode};
use Email::Sender::Simple 'sendmail';
use Email::MIME;
use Email::Sender::Transport::SMTPS;
use Try::Tiny;
use Yoyakku::Master qw{$MAIL_USER $MAIL_PASS};

__PACKAGE__->mk_accessors(
    qw{params session method html login_row login_table login_name
        profile_row storeinfo_row template type flash_msg acting_rows
        mail_temp mail_header mail_body}
);

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model - データベース関連 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model version 0.0.1

=head1 SYNOPSIS (概要)

    データベース接続関連の API を提供

=cut

=head2 get_calender_caps

    カレンダー表示用の曜日

=cut

sub get_calender_caps {
    my $self = shift;
    my $caps = [qw{日 月 火 水 木 金 土}];
    return $caps;
}

=head2 get_ads_navi_rows

    ナビ広告データ取得

=cut

sub get_ads_navi_rows {
    my $self = shift;
    my $teng = $self->teng();

    my @ads_navi_rows = $teng->search(
        'ads',
        +{ kind     => 3, },
        +{ order_by => 'displaystart_on' },
    );
    return \@ads_navi_rows;
}

=head2 send_gmail

    メール送信(gmail)

=cut

sub send_gmail {
    my $self = shift;

    my $email = Email::MIME->create(
        header => [
            From    => encode( 'UTF-8', $self->mail_header()->{from} ),
            To      => encode( 'UTF-8', $self->mail_header()->{to} ),
            Subject => encode( 'UTF-8', $self->mail_header()->{subject} ),
        ],
        body       => encode( 'UTF-8', $self->mail_body() ),
        attributes => +{
            content_type => 'text/plain',
            charset      => 'UTF-8',
            encoding     => '7bit',
        },
    );

    my $transport = Email::Sender::Transport::SMTPS->new(
        +{  host          => 'smtp.gmail.com',
            ssl           => 'starttls',
            sasl_username => $MAIL_USER,
            sasl_password => $MAIL_PASS,
        }
    );

    try {
        sendmail( $email, +{ transport => $transport } );
    }
    catch {
        my $e = shift;
        warn "Error: $e";
    };

    return;
}

=head2 check_table_column

    指定パラメーターの存在確認

=cut

sub check_table_column {
    my $self         = shift;
    my $check_params = shift;

    my $teng = $self->teng();

    my $column = $check_params->{column};
    my $param  = $check_params->{param};
    my $table  = $check_params->{table};
    my $id     = $check_params->{id};

    my $row = $teng->single( $table, +{ $column => $param, }, );

    # 新規
    return '既に利用されています' if $row && !$id;

    # 更新
    return '既に利用されています'
        if $row && $id && ( $id ne $row->id );

    return;
}

=head2 get_header_stash_params

    header の stash の値を取得

=cut

sub get_header_stash_params {
    my $self          = shift;
    my $switch_header = shift;
    my $login_name    = shift;

    my $header_params = switch_header_params( $switch_header, $login_name );

    my $header_params_hash_ref = +{
        site_title_link        => $header_params->{site_title_link},
        header_heading_link    => $header_params->{header_heading_link},
        header_heading_name    => $header_params->{header_heading_name},
        header_navi_class_name => $header_params->{header_navi_class_name},
        header_navi_link_name  => $header_params->{header_navi_link_name},
        header_navi_row_name   => $header_params->{header_navi_row_name},
    };

    my $stash = +{
        switch_header => $switch_header,    # 切替
        %{$header_params_hash_ref},         # ヘッダー各値
    };

    return $stash;
}

=head2 get_storeinfo_rows_all

    店舗情報の全てを row オブジェクトで取得

=cut

sub get_storeinfo_rows_all {
    my $self           = shift;
    my $teng           = $self->teng();
    my @storeinfo_rows = $teng->search( 'storeinfo', +{}, );
    return \@storeinfo_rows;
}

=head2 get_init_valid_params

    バリデート用パラメータ初期値

=cut

sub get_init_valid_params {
    my $self         = shift;
    my $valid_params = shift;

    my $valid_params_stash = +{};
    for my $param ( @{$valid_params} ) {
        $valid_params_stash->{$param} = '';
    }
    return $valid_params_stash;
}

=head2 writing_db

    データベースへの書き込み

=cut

sub writing_db {
    my $self        = shift;
    my $table       = shift;
    my $create_data = shift;
    my $update_id   = shift;
    my $type        = $self->type();

    my $teng = $self->teng();

    my $insert_row;
    if ( $type eq 'insert' ) {
        $insert_row = $teng->insert( $table, $create_data, );
    }
    elsif ( $type eq 'update' ) {
        delete $create_data->{create_on};
        $insert_row = $teng->single( $table, +{ id => $update_id }, );
        $insert_row->update($create_data);
    }
    die 'not $insert_row' if !$insert_row;

    return $insert_row;
}

=head2 insert_admin_relation

    admin 有効の際の関連データ作成

=cut

sub insert_admin_relation {
    my $self         = shift;
    my $new_admin_id = shift;

    my $teng = $self->teng();

    my $storeinfo_row
        = $teng->single( 'storeinfo', +{ admin_id => $new_admin_id, }, );

    # storeinfo 見つからないときは新規にレコード作成
    if ( !$storeinfo_row ) {

        my $create_data_storeinfo = +{
            admin_id  => $new_admin_id,
            status    => 1,
            create_on => now_datetime(),
            modify_on => now_datetime(),
        };

        my $insert_storeinfo_row
            = $teng->insert( 'storeinfo', $create_data_storeinfo, );

        # roominfo を 10 件作成
        my $create_data_roominfo = +{
            storeinfo_id      => $insert_storeinfo_row->id,
            name              => undef,
            starttime_on      => '10:00:00',
            endingtime_on     => '22:00:00',
            time_change       => 0,
            rentalunit        => 1,
            pricescomments    => '例）１時間２０００円より',
            privatepermit     => 0,
            privatepeople     => 2,
            privateconditions => 0,
            bookinglimit      => 0,
            cancellimit       => 8,
            remarks => '例）スタジオ内の飲食は禁止です。',
            webpublishing => 1,
            webreserve    => 3,
            status        => 0,
            create_on     => now_datetime(),
            modify_on     => now_datetime(),
        };

        for my $i ( 1 .. 10 ) {
            $teng->fast_insert( 'roominfo', $create_data_roominfo, );
        }
    }
}

# 入力値バリデート処理
sub get_msg_validator {
    my $self         = shift;
    my $check_params = shift;
    my $msg_params   = shift;
    my $params       = $self->params();

    my $validator = FormValidator::Lite->new($params);

    $validator->check( @{$check_params} );
    $validator->set_message( @{$msg_params} );

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

sub check_auth_db {
    my $self         = shift;
    my $session      = shift;
    my $session_type = shift;
    return if !$session || !$session_type;
    return $session if $session eq 'yoyakku' && $session_type eq 'mainte';
    return;
}

sub check_auth_db_yoyakku {
    my $self = shift;

    my $teng       = $self->teng();
    my $admin_id   = $self->session->{session_admin_id};
    my $general_id = $self->session->{session_general_id};

    return if !$admin_id && !$general_id;

    my $table  = 'admin';
    my $id     = $admin_id;
    my $column = 'admin_id';

    if ($general_id) {
        $table  = 'general';
        $id     = $general_id;
        $column = 'general_id';
    }

    my $login_row = $teng->single( $table, +{ id => $id } );
    return if !$login_row;

    $self->login_row($login_row);
    $self->profile_row( $teng->single( 'profile', +{ $column => $id } ) );
    $self->login_table($table);

    my $login_name
        = $self->profile_row() ? $self->profile_row()->nick_name : undef;

    if ($admin_id) {
        $login_name = q{(admin)} . $login_name;
        $self->storeinfo_row(
            $teng->single( 'storeinfo', +{ admin_id => $id } ) );
    }
    $self->login_name($login_name);

    if ($general_id) {
        my @actings = $teng->search( 'acting',
            +{ general_id => $login_row->id, status => 1, } );

        $self->acting_rows( \@actings );
    }

    return 1;
}

sub teng {
    my $self = shift;

    my $dbh = DBI->connect(
        'dbi:SQLite:./db/yoyakku.db',
        '', '',
        +{  RaiseError        => 1,
            PrintError        => 0,
            AutoCommit        => 1,
            sqlite_unicode    => 1,
            mysql_enable_utf8 => 1,
        },
    );

    my $teng = Teng::Schema::Loader->load(
        dbh       => $dbh,
        namespace => 'yoyakku_table',
    );

    return $teng;
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<Teng>

=item * L<Teng::Schema::Loader>

=item * L<FormValidator::Lite>

=item * L<base>

=item * L<Class::Accessor::Fast>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
