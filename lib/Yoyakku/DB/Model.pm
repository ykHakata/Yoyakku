package Yoyakku::DB::Model;
use Mojo::Base -base;
use Yoyakku::DB::Model::Acting;
use Yoyakku::DB::Model::Admin;
use Yoyakku::DB::Model::Ads;
use Yoyakku::DB::Model::Base;
use Yoyakku::DB::Model::General;
use Yoyakku::DB::Model::Post;
use Yoyakku::DB::Model::Profile;
use Yoyakku::DB::Model::Region;
use Yoyakku::DB::Model::Reserve;
use Yoyakku::DB::Model::Roominfo;
use Yoyakku::DB::Model::Storeinfo;

has [qw{app}];

my $methods = [
    qw{
        acting
        admin
        ads
        base
        general
        post
        profile
        region
        reserve
        roominfo
        storeinfo
        }
];

for my $method ( @{$methods} ) {
    my $package_name = ucfirst $method;
    my $package      = __PACKAGE__ . '::' . $package_name;
    has $method => sub {
        $package->new( +{ app => shift->app } );
    };
}

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
