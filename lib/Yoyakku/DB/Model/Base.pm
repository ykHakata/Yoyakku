package Yoyakku::DB::Model::Base;
use Mojo::Base -base;
use Teng;
use Teng::Schema::Loader;

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::DB::Model::Base - データベース Model

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::DB::Model::Base version 0.0.1

=head1 SYNOPSIS (概要)

    データベース接続の API teng を提供

=cut

has [qw{app}];

=head2 teng

    teng モジュールセットアップ

=cut

sub teng {
    my $self = shift;
    my $conf = $self->app->config->{db};

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

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Teng>

=item * L<Teng::Schema::Loader>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
