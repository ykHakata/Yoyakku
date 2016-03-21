package Yoyakku::Model::Setting;
use Mojo::Base -base;
use Yoyakku::Model::Setting::Roominfo;
use Yoyakku::Model::Setting::Storeinfo;

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Setting - データベース Model::Setting アクセスメソッド

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Setting version 0.0.1

=head1 SYNOPSIS (概要)

    yoyakku コントローラーモデルへのアクセス一式

=cut

has [qw{yoyakku_conf}];

has roominfo => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj  = Yoyakku::Model::Setting::Roominfo->new(
        +{ yoyakku_conf => $conf } );
    return $obj;
};

has storeinfo => sub {
    my $self = shift;
    my $conf = $self->yoyakku_conf;
    my $obj  = Yoyakku::Model::Setting::Storeinfo->new(
        +{ yoyakku_conf => $conf } );
    return $obj;
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
