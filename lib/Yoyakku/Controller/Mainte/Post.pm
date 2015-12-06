package Yoyakku::Controller::Mainte::Post;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Mainte::Post;

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Mainte::Post - post テーブルのコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Mainte::Post version 0.0.1

=head1 SYNOPSIS (概要)

    システム管理者 post 関連機能のリクエストをコントロール

=cut

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Mainte::Post->new();

    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session->{root_id} );

    my $header_stash = $model->get_header_stash_auth_mainte();

    return if !$header_stash;

    $self->stash($header_stash);

    return $model;
}

=head2 mainte_post_serch

    post テーブル登録情報の一覧、検索

=cut

sub mainte_post_serch {
    my $self  = shift;
    my $model = $self->_init();

    return $self->redirect_to('/index') if !$model;

    my $post_rows = $model->search_post_id_rows();

    $self->stash(
        class     => 'mainte_post_serch',
        post_rows => $post_rows,
    );

    return $self->render(
        template => 'mainte/mainte_post_serch',
        format   => 'html',
    );
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Mainte::Post>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
