package Yoyakku::Controller::Auth;
use Mojo::Base 'Mojolicious::Controller';

sub up_login {
    my $self = shift;

    # テンプレート用bodyのクラス名
    my $class = 'up_login';

    $self->stash( class => $class );

    $self->render( template => 'auth/up_login', format => 'html' );
}

1;

__END__

# up_login.html.ep
# ログインフォーム入り口========================================
get '/up_login' => sub {
    my $self = shift;
    # テンプレート用bodyのクラス名
    my $class = "up_login_admin";
    $self->stash(class => $class);

    $self->render('up_login');
};

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Controller::Auth - ログイン機能のコントローラー

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Controller::Auth version 0.0.1

=head1 SYNOPSIS (概要)

ログイン関連機能のリクエストをコントロール

=head2 up_login

    リクエスト
    URL: http:// ... /up_login
    METHOD: GET

    レスポンス
    CONTENT-TYPE: text/html;charset=UTF-8
    FILE: templates/auth/up_login

ログインフォーム入口画面の描写

=head1 DEPENDENCIES (依存モジュール)

=over 2

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=back

=head1 SEE ALSO (参照)

L<Yoyakku::Guides>
