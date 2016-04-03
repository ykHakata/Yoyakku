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

=head2 writing_db

    データベースへの書き込み

=cut

sub writing_db {
    my $self = shift;
    my $args = shift;

    my $table       = $args->{table};
    my $create_data = $args->{create_data};
    my $update_id   = $args->{update_id};
    my $type        = $args->{type};

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
