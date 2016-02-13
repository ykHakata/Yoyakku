package Yoyakku::Command::init_db;
use Mojo::Base 'Mojolicious::Command';
use Carp;
use File::Basename;

binmode STDOUT, ':encoding(UTF-8)';
binmode STDIN,  ':encoding(UTF-8)';

my $mycommand = "$0 " . basename( __FILE__, '.pm' );

has description =>
    'yoyakku データベースを初期化 サンプルデーター投入';
has usage => <<"END_USAGE";
Usage: $mycommand [-i <infile>]

Options:
    -i <infile>     Specify input source [default: STDIN]

    --help          Print this summary

    * -i オプションは未実装
END_USAGE

sub run {
    my ( $self, @args ) = @_;

    my $config  = $self->app->config;
    my $init_db = $config->{init_db};
    my $db      = $init_db->{db};
    my $schema  = $init_db->{schema};
    my $data    = $init_db->{data};

    # スキーマー読み込み初期化
    my $cmd = "sqlite3 $db < $schema";
    system $cmd
        and croak "Couldn'n run: $cmd ($!)";

    # csv ファイル読み込み
IMPORT_ACTION:
    while ( my ( $table, $file, ) = each %{$data} ) {
        next IMPORT_ACTION if !$file;
        $cmd = qq{sqlite3 -separator , $db '.import $file $table'};
        system $cmd
            and croak "Couldn'n run: $cmd ($!)";
    }

    return;
}

1;

__END__
