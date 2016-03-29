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
    Yoyakku::Model::Mainte::Acting->new(
        +{ yoyakku_conf => shift->yoyakku_conf } );
};

has admin => sub {
    Yoyakku::Model::Mainte::Admin->new(
        +{ yoyakku_conf => shift->yoyakku_conf } );
};

has ads => sub {
    Yoyakku::Model::Mainte::Ads->new(
        +{ yoyakku_conf => shift->yoyakku_conf } );
};

has base => sub {
    Yoyakku::Model::Mainte::Base->new(
        +{ yoyakku_conf => shift->yoyakku_conf } );
};

has general => sub {
    Yoyakku::Model::Mainte::General->new(
        +{ yoyakku_conf => shift->yoyakku_conf } );
};

has post => sub {
    Yoyakku::Model::Mainte::Post->new(
        +{ yoyakku_conf => shift->yoyakku_conf } );
};

has profile => sub {
    Yoyakku::Model::Mainte::Profile->new(
        +{ yoyakku_conf => shift->yoyakku_conf } );
};

has region => sub {
    Yoyakku::Model::Mainte::Region->new(
        +{ yoyakku_conf => shift->yoyakku_conf } );
};

has reserve => sub {
    Yoyakku::Model::Mainte::Reserve->new(
        +{ yoyakku_conf => shift->yoyakku_conf } );
};

has roominfo => sub {
    Yoyakku::Model::Mainte::Roominfo->new(
        +{ yoyakku_conf => shift->yoyakku_conf } );
};

has storeinfo => sub {
    Yoyakku::Model::Mainte::Storeinfo->new(
        +{ yoyakku_conf => shift->yoyakku_conf } );
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
