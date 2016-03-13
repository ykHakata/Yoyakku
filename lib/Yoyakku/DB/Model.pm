package Yoyakku::DB::Model;
use strict;
use warnings;
use utf8;
use Teng;
use Teng::Schema::Loader;

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::DB::Model - データベース Model

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model version 0.0.1

=head1 SYNOPSIS (概要)

    データベース接続の API teng を提供

=cut

=head2 teng

    teng モジュールセットアップ

=cut

sub teng {
    my $self = shift;
    my $conf = $self->yoyakku_conf->{db};

    my $dsn_str = $conf->{dsn_str};
    my $user    = $conf->{user} || '';
    my $pass    = $conf->{pass} || '';
    my $option  = $conf->{option} || +{
        RaiseError        => 1,
        PrintError        => 0,
        AutoCommit        => 1,
        sqlite_unicode    => 1,
        mysql_enable_utf8 => 1,
    };

    my $dbh = DBI->connect( $dsn_str, $user, $pass, $option );

    my $teng = Teng::Schema::Loader->load(
        dbh       => $dbh,
        namespace => 'Yoyakku::DB',
    );

    return $teng;
}

1;

__END__
