package Yoyakku::DB::Model;
use Mojo::Base -base;
use Yoyakku::DB::Model::Acting;
use Yoyakku::DB::Model::Base;
use Yoyakku::DB::Model::General;

has [qw{yoyakku_conf}];

has acting => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj  = Yoyakku::DB::Model::Acting->new( +{ yoyakku_conf => $conf } );
    return $obj;
};

has base => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj  = Yoyakku::DB::Model::Base->new( +{ yoyakku_conf => $conf } );
    return $obj;
};

has general => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj  = Yoyakku::DB::Model::General->new( +{ yoyakku_conf => $conf } );
    return $obj;
};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::DB::Model - データベース Model 集約

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::DB::Model version 0.0.1

=head1 SYNOPSIS (概要)

    yoyakku テーブルの API 一式を提供

=cut

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::DB::Model::Acting>

=item * L<Yoyakku::DB::Model::Base>

=item * L<Yoyakku::DB::Model::General>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
