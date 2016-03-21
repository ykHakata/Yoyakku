package Yoyakku::Model::Mainte;
use Mojo::Base -base;
use Yoyakku::Model::Mainte::Acting;
use Yoyakku::Model::Mainte::Admin;
use Yoyakku::Model::Mainte::Ads;
use Yoyakku::Model::Mainte::Base;
use Yoyakku::Model::Mainte::General;
use Yoyakku::Model::Mainte::Post;
use Yoyakku::Model::Mainte::Profile;
use Yoyakku::Model::Mainte::Region;
use Yoyakku::Model::Mainte::Reserve;
use Yoyakku::Model::Mainte::Roominfo;
use Yoyakku::Model::Mainte::Storeinfo;

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Mainte - アクセスメソッド

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Mainte version 0.0.1

=head1 SYNOPSIS (概要)

    yoyakku コントローラーモデルへのアクセス一式

=cut

has [qw{yoyakku_conf}];

has acting => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj
        = Yoyakku::Model::Mainte::Acting->new( +{ yoyakku_conf => $conf } );
    return $obj;
};

has admin => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj
        = Yoyakku::Model::Mainte::Admin->new( +{ yoyakku_conf => $conf } );
    return $obj;
};

has ads => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj  = Yoyakku::Model::Mainte::Ads->new( +{ yoyakku_conf => $conf } );
    return $obj;
};

has base => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj  = Yoyakku::Model::Mainte::Base->new( +{ yoyakku_conf => $conf } );
    return $obj;
};

has general => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj
        = Yoyakku::Model::Mainte::General->new( +{ yoyakku_conf => $conf } );
    return $obj;
};

has post => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj = Yoyakku::Model::Mainte::Post->new( +{ yoyakku_conf => $conf } );
    return $obj;
};

has profile => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj
        = Yoyakku::Model::Mainte::Profile->new( +{ yoyakku_conf => $conf } );
    return $obj;
};

has region => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj
        = Yoyakku::Model::Mainte::Region->new( +{ yoyakku_conf => $conf } );
    return $obj;
};

has reserve => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj
        = Yoyakku::Model::Mainte::Reserve->new( +{ yoyakku_conf => $conf } );
    return $obj;
};

has roominfo => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj
        = Yoyakku::Model::Mainte::Roominfo->new( +{ yoyakku_conf => $conf } );
    return $obj;
};

has storeinfo => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj  = Yoyakku::Model::Mainte::Storeinfo->new(
        +{ yoyakku_conf => $conf } );
    return $obj;
};

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::Model::Setting::Roominfo>

=item * L<Yoyakku::Model::Setting::Storeinfo>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
