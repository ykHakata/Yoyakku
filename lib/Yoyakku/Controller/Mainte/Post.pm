package Yoyakku::Controller::Mainte::Post;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Mainte::Post;

has( model_mainte_post => sub { Yoyakku::Model::Mainte::Post->new(); } );

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Mainte::Post - post テーブルのコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Mainte::Post version 0.0.1

=head1 SYNOPSIS (概要)

    システム管理者 post 関連機能のリクエストをコントロール

=cut

sub index {
    my $self  = shift;
    my $model = $self->model_mainte_post;

    return $self->redirect_to('index')
        if ( uc $self->req->method ne 'GET' )
        && ( uc $self->req->method ne 'POST' );

    my $header_stash
        = $model->get_header_stash_auth_mainte( $self->session->{root_id} );
    return $self->redirect_to('index') if !$header_stash;

    $self->stash($header_stash);
    $self->stash->{params} = $self->req->params->to_hash;

    my $path = $self->req->url->path->to_abs_string;

    return $self->mainte_post_serch() if $path eq '/mainte_post_serch';
    return $self->redirect_to('index');
}

=head2 mainte_post_serch

    post テーブル登録情報の一覧、検索

=cut

sub mainte_post_serch {
    my $self  = shift;
    my $model = $self->model_mainte_post();

    my $post_rows = $model->search_post_id_rows();

    $self->stash(
        class     => 'mainte_post_serch',
        post_rows => $post_rows,
        template  => 'mainte/mainte_post_serch',
        format    => 'html',
    );
    return $self->render();
}

1;

__END__

TODO MEMO:
    新規、修正の URL の設定はあるが実装がない

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Mainte::Post>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
