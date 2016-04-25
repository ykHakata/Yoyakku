package Yoyakku::Model;
use Mojo::Base -base;
use Yoyakku::DB::Model;
use Yoyakku::Model::Auth;
use Yoyakku::Model::Calendar;
use Yoyakku::Model::Entry;
use Yoyakku::Model::Mainte;
use Yoyakku::Model::Management;
use Yoyakku::Model::Profile;
use Yoyakku::Model::Region;
use Yoyakku::Validator;

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model - データベース Model アクセスメソッド

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model version 0.0.1

=head1 SYNOPSIS (概要)

    yoyakku コントローラーモデルへのアクセス一式

=cut

has [qw{app model_stash}];

has db => sub {
    Yoyakku::DB::Model->new( +{ app => shift->app } );
};

my $methods = [
    qw{
        auth
        calendar
        entry
        mainte
        management
        profile
        region
        }
];

for my $method ( @{$methods} ) {
    my $package_name = ucfirst $method;
    my $package      = __PACKAGE__ . '::' . $package_name;
    has $method => sub {
        $package->new( +{ app => shift->app } );
    };
}

has validator => sub {
    Yoyakku::Validator->new( +{ app => shift->app } );
};

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
