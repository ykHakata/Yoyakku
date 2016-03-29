package Yoyakku::Model;
use Mojo::Base -base;
use Yoyakku::Model::Auth;
use Yoyakku::Model::Calendar;
use Yoyakku::Model::Entry;
use Yoyakku::Model::Profile;
use Yoyakku::Model::Region;
use Yoyakku::Model::Setting;
use Yoyakku::Model::Mainte;
use Yoyakku::DB::Model;
use Yoyakku::Validator;

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model - データベース Model アクセスメソッド

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model version 0.0.1

=head1 SYNOPSIS (概要)

    yoyakku コントローラーモデルへのアクセス一式

=cut

has [qw{mail_temp mail_header mail_body yoyakku_conf model_stash}];

has validator => sub {
    Yoyakku::Validator->new( +{ yoyakku_conf => shift->yoyakku_conf } );
};

has db => sub {
    Yoyakku::DB::Model->new( +{ yoyakku_conf => shift->yoyakku_conf } );
};

has mainte => sub {
    Yoyakku::Model::Mainte->new( +{ yoyakku_conf => shift->yoyakku_conf } );
};

has setting => sub {
    Yoyakku::Model::Setting->new( +{ yoyakku_conf => shift->yoyakku_conf } );
};

has auth => sub {
    Yoyakku::Model::Auth->new( +{ yoyakku_conf => shift->yoyakku_conf } );
};

has calendar => sub {
    Yoyakku::Model::Calendar->new( +{ yoyakku_conf => shift->yoyakku_conf } );
};

has entry => sub {
    Yoyakku::Model::Entry->new( +{ yoyakku_conf => shift->yoyakku_conf } );
};

has profile => sub {
    Yoyakku::Model::Profile->new( +{ yoyakku_conf => shift->yoyakku_conf } );
};

has region => sub {
    Yoyakku::Model::Region->new( +{ yoyakku_conf => shift->yoyakku_conf } );
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
