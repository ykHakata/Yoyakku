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

has [qw{app model_stash}];

has validator => sub {
    Yoyakku::Validator->new( +{ app => shift->app } );
};

has db => sub {
    Yoyakku::DB::Model->new( +{ app => shift->app } );
};

has mainte => sub {
    Yoyakku::Model::Mainte->new( +{ app => shift->app } );
};

has setting => sub {
    Yoyakku::Model::Setting->new( +{ app => shift->app } );
};

has auth => sub {
    Yoyakku::Model::Auth->new( +{ app => shift->app } );
};

has calendar => sub {
    Yoyakku::Model::Calendar->new( +{ app => shift->app } );
};

has entry => sub {
    Yoyakku::Model::Entry->new( +{ app => shift->app } );
};

has profile => sub {
    Yoyakku::Model::Profile->new( +{ app => shift->app } );
};

has region => sub {
    Yoyakku::Model::Region->new( +{ app => shift->app } );
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
