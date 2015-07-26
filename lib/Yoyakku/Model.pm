package Yoyakku::Model;
use strict;
use warnings;
use utf8;
use Teng;
use Teng::Schema::Loader;
use FormValidator::Lite qw{Email URL DATE TIME};

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model - データベース関連 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model version 0.0.1

=head1 SYNOPSIS (概要)

    データベース接続関連の API を提供

=cut

sub new {
    my $class  = shift;
    my $params = +{};
    my $self   = bless $params, $class;
    return $self;
}

sub params {
    my $self   = shift;
    my $params = shift;
    if ($params) {
        $self->{params} = $params;
    }
    return $self->{params};
}

sub session {
    my $self    = shift;
    my $session = shift;
    if ($session) {
        $self->{session} = $session;
    }
    return $self->{session};
}

sub method {
    my $self   = shift;
    my $method = shift;
    if ($method) {
        $self->{method} = $method;
    }
    return $self->{method};
}

sub html {
    my $self = shift;
    my $html = shift;
    if ($html) {
        $self->{html} = $html;
    }
    return $self->{html};
}

sub login_row {
    my $self      = shift;
    my $login_row = shift;
    if ($login_row) {
        $self->{login_row} = $login_row;
    }
    return $self->{login_row};
}

sub login_table {
    my $self        = shift;
    my $login_table = shift;
    if ($login_table) {
        $self->{login_table} = $login_table;
    }
    return $self->{login_table};
}

sub login_name {
    my $self       = shift;
    my $login_name = shift;
    if ($login_name) {
        $self->{login_name} = $login_name;
    }
    return $self->{login_name};
}

sub profile_row {
    my $self        = shift;
    my $profile_row = shift;
    if ($profile_row) {
        $self->{profile_row} = $profile_row;
    }
    return $self->{profile_row};
}

sub storeinfo_row {
    my $self          = shift;
    my $storeinfo_row = shift;
    if ($storeinfo_row) {
        $self->{storeinfo_row} = $storeinfo_row;
    }
    return $self->{storeinfo_row};
}

sub template {
    my $self     = shift;
    my $template = shift;
    if ($template) {
        $self->{template} = $template;
    }
    return $self->{template};
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

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
