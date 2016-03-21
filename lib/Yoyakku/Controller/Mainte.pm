package Yoyakku::Controller::Mainte;
use Mojo::Base 'Mojolicious::Controller';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Mainte - システム管理者機能のコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Mainte version 0.0.1

=head1 SYNOPSIS (概要)

    システム管理者関連機能のリクエストをコントロール

=cut

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

sub index {
    my $self  = shift;
    my $model = $self->model->mainte->base;

    return $self->redirect_to('index')
        if ( uc $self->req->method ne 'GET' )
        && ( uc $self->req->method ne 'POST' );

    my $header_stash
        = $model->get_header_stash_auth_mainte( $self->session->{root_id} );
    return $self->redirect_to('index') if !$header_stash;

    $self->stash($header_stash);
    $self->stash->{params} = $self->req->params->to_hash;

    my $path = $self->req->url->path->to_abs_string;

    return $self->mainte_list() if $path eq '/mainte_list';
    return $self->redirect_to('index');
}

=head2 mainte_list

    システム管理のオープニング画面

=cut

sub mainte_list {
    my $self = shift;

    my $login_data = $self->stash->{login_data};

    $self->stash(
        class    => 'mainte_list',
        today    => $login_data->{today},
        template => 'mainte/mainte_list',
        format   => 'html',
    );
    return $self->render();
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
