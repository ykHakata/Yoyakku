use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

my $t      = Test::Mojo->new('Yoyakku');
my $config = $t->app->config;

=encoding utf8

=head2 exists file

    ファイル存在確認

=cut

subtest 'exists file' => sub {
    my $dir = 'etc';
    my $files = [ 'yoyakku.development.conf', 'yoyakku.testing.conf', ];

    my $home       = $t->app->home;
    my $file_names = [];

    for my $name ( @{$files} ) {
        my $file_name = $home->rel_file("$dir/$name");
        push @{$file_names}, $file_name;
    }

    for my $file_name ( @{$file_names} ) {
        ok( -f $file_name, "$file_name read ok!" );
    }
};

done_testing();

__END__
