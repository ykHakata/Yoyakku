package Yoyakku::Model;
use strict;
use warnings;
use utf8;
use Teng;
use Teng::Schema::Loader;
use FormValidator::Lite qw{Email URL DATE TIME};

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

# バリデート用パラメータ初期値
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

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model - データベース関連 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model version 0.0.1

=head1 SYNOPSIS (概要)

    use Yoyakku::Model qw{$teng};

    # 指定のテーブルから該当のレコードを１件取得 row オブジェクト変換
    my $row = $teng->single( $table, +{ login => $params->{login} } );

    # teng 関連のメソッドは teng ドキュメント参照

データベース接続関連の API を提供

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<Teng>

=item * L<Teng::Schema::Loader>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
