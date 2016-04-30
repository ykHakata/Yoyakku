package Yoyakku::Model::Management;
use Mojo::Base -base;
use Yoyakku::Model::Management::Roominfo;
use Yoyakku::Model::Management::Storeinfo;
use Yoyakku::Model::Management::Reserve;

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Management - データベース Model::Management アクセスメソッド

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Management version 0.0.1

=head1 SYNOPSIS (概要)

    yoyakku コントローラーモデルへのアクセス一式

=cut

has [qw{app}];

my $methods = [
    qw{
        roominfo
        storeinfo
        reserve
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

=item * L<Yoyakku::Model::Management::Reserve>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
