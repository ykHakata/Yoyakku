package Yoyakku::Model::Base;
use Mojo::Base -base;
use Yoyakku::Model::Auth;
use Yoyakku::Model::Calendar;
use Yoyakku::Model::Entry;
use Yoyakku::Model::Profile;
use Yoyakku::Model::Region;

has [qw{mail_temp mail_header mail_body yoyakku_conf model_stash}];

has auth => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj  = Yoyakku::Model::Auth->new( +{ yoyakku_conf => $conf } );
    return $obj;
};

has calendar => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj  = Yoyakku::Model::Calendar->new( +{ yoyakku_conf => $conf } );
    return $obj;
};

has entry => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj  = Yoyakku::Model::Entry->new( +{ yoyakku_conf => $conf } );
    return $obj;
};

has profile => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj  = Yoyakku::Model::Profile->new( +{ yoyakku_conf => $conf } );
    return $obj;
};

has region => sub {my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj  = Yoyakku::Model::Region->new( +{ yoyakku_conf => $conf } );
    return $obj;
};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Base - データベース Model 集約

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Base version 0.0.1

=head1 SYNOPSIS (概要)

    yoyakku コントローラーのモデル API 一式を提供

=cut

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::Model::Auth>

=item * L<Yoyakku::Model::Calendar>

=item * L<Yoyakku::Model::Entry>

=item * L<Yoyakku::Model::Profile>

=item * L<Yoyakku::Model::Region>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
