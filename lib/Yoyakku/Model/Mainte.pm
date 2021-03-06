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

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::Model::Management::Roominfo>

=item * L<Yoyakku::Model::Management::Storeinfo>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
