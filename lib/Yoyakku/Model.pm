package Yoyakku::Model;
use strict;
use warnings;
use utf8;
use Teng;
use Teng::Schema::Loader;
use Exporter 'import';
our @EXPORT_OK = qw{
    $teng
};

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

our $teng = Teng::Schema::Loader->load(
    dbh       => $dbh,
    namespace => 'yoyakku_table',
);

sub new {
    my $class  = shift;
    my $params = +{};
    my $self   = bless $params, $class;
    return $self;
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
