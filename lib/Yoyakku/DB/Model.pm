package Yoyakku::DB::Model;
use Mojo::Base -base;
use Yoyakku::DB::Model::Acting;
use Yoyakku::DB::Model::Admin;
use Yoyakku::DB::Model::Ads;
use Yoyakku::DB::Model::Base;
use Yoyakku::DB::Model::General;
use Yoyakku::DB::Model::Post;
use Yoyakku::DB::Model::Region;
use Yoyakku::DB::Model::Reserve;
use Yoyakku::DB::Model::Roominfo;
use Yoyakku::DB::Model::Storeinfo;

has [qw{app}];

has acting => sub {
    Yoyakku::DB::Model::Acting->new( +{ app => shift->app } );
};

has admin => sub {
    Yoyakku::DB::Model::Admin->new( +{ app => shift->app } );
};

has ads => sub {
    Yoyakku::DB::Model::Ads->new( +{ app => shift->app } );
};

has base => sub {
    Yoyakku::DB::Model::Base->new( +{ app => shift->app } );
};

has general => sub {
    Yoyakku::DB::Model::General->new( +{ app => shift->app } );
};

has post => sub {
    Yoyakku::DB::Model::Post->new( +{ app => shift->app } );
};

has region => sub {
    Yoyakku::DB::Model::Region->new( +{ app => shift->app } );
};

has reserve => sub {
    Yoyakku::DB::Model::Reserve->new( +{ app => shift->app } );
};

has roominfo => sub {
    Yoyakku::DB::Model::Roominfo->new( +{ app => shift->app } );
};

has storeinfo => sub {
    Yoyakku::DB::Model::Storeinfo->new( +{ app => shift->app } );
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

=item * L<Yoyakku::DB::Model::Admin>

=item * L<Yoyakku::DB::Model::Acting>

=item * L<Yoyakku::DB::Model::Base>

=item * L<Yoyakku::DB::Model::General>

=item * L<Yoyakku::DB::Model::Post>

=item * L<Yoyakku::DB::Model::Region>

=item * L<Yoyakku::DB::Model::Reserve>

=item * L<Yoyakku::DB::Model::Roominfo>

=item * L<Yoyakku::DB::Model::Storeinfo>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
