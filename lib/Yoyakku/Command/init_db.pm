package Yoyakku::Command::init_db;
use Mojo::Base 'Mojolicious::Command';
use File::Basename;
use DBI;
use FindBin;

binmode STDOUT, ':encoding(UTF-8)';
binmode STDIN,  ':encoding(UTF-8)';

my $mycommand = "$0 " . basename( __FILE__, '.pm' );

has description => 'yoyakku データベースを初期化 サンプルデーター投入';
has usage => <<"END_USAGE";
Usage: $mycommand [-i <infile>]

Options:
    -i <infile>     Specify input source [default: STDIN]

    --help          Print this summary

    * -i オプションは未実装
END_USAGE

sub run {
    my ( $self, @args ) = @_;

    my $db_path = $FindBin::Bin . '/../db/yoyakku.db';
    my $db      = DBI->connect(
        'dbi:SQLite:' . $db_path,
        '', '',
        +{  RaiseError     => 1,
            PrintError     => 0,
            AutoCommit     => 1,
            sqlite_unicode => 1,
        },
    );

    return;
}

1;

__END__