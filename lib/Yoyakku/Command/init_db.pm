package Yoyakku::Command::init_db;
use Mojo::Base 'Mojolicious::Command';
use Carp;
use File::Basename;
use File::Temp;

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

    my $config = $self->app->config;
    my $db     = $config->{init_db_file};
    my $schema = $config->{init_schema};
    my $data   = $config->{init_data};

    # スキーマー読み込み初期化
    my $cmd = "sqlite3 $db < $schema";
    system $cmd
        and croak "Couldn'n run: $cmd ($!)";

    # csv ファイル読み込み
IMPORT_ACTION:
    while ( my ( $table, $file, ) = each %{$data} ) {
        next IMPORT_ACTION if !$file;
        $file = $self->_delete_header($file);
        $cmd = qq{sqlite3 -separator , $db '.import $file $table'};
        system $cmd
            and croak "Couldn'n run: $cmd ($!)";
    }

    return;
}

sub _delete_header {
    my $self = shift;
    my $file = shift;

    my $file_temp = File::Temp->new(
        DIR    => $self->app->config->{dir_db},
        SUFFIX => '.csv',
    );

    open my $fh, '<:encoding(utf8)', $file
        or croak "can't open '$file': $!";

    open my $fh_temp, '>>:encoding(utf8)', $file_temp
        or croak "can't open '$file': $!";

    while ( my $row = <$fh> ) {
        next if $. <= 2;
        chomp $row;
        $fh_temp->say($row);
    }

    return $file_temp;
}

1;

__END__
