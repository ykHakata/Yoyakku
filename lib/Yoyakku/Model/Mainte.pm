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

has [qw{app}];

has acting => sub {
    Yoyakku::Model::Mainte::Acting->new( +{ app => shift->app } );
};

has admin => sub {
    Yoyakku::Model::Mainte::Admin->new( +{ app => shift->app } );
};

has ads => sub {
    Yoyakku::Model::Mainte::Ads->new( +{ app => shift->app } );
};

has base => sub {
    Yoyakku::Model::Mainte::Base->new( +{ app => shift->app } );
};

has general => sub {
    Yoyakku::Model::Mainte::General->new( +{ app => shift->app } );
};

has post => sub {
    Yoyakku::Model::Mainte::Post->new( +{ app => shift->app } );
};

has profile => sub {
    Yoyakku::Model::Mainte::Profile->new( +{ app => shift->app } );
};

has region => sub {
    Yoyakku::Model::Mainte::Region->new( +{ app => shift->app } );
};

has reserve => sub {
    Yoyakku::Model::Mainte::Reserve->new( +{ app => shift->app } );
};

has roominfo => sub {
    Yoyakku::Model::Mainte::Roominfo->new( +{ app => shift->app } );
};

has storeinfo => sub {
    Yoyakku::Model::Mainte::Storeinfo->new( +{ app => shift->app } );
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
