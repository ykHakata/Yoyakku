package Yoyakku::Controller::Mainte::Region;
use Mojo::Base 'Mojolicious::Controller';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Mainte::Region - region テーブルのコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Mainte::Region version 0.0.1

=head1 SYNOPSIS (概要)

    システム管理者 region 関連機能のリクエストをコントロール

=cut

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

sub index {
    my $self  = shift;
    my $model = $self->model_mainte_region;

    return $self->redirect_to('index')
        if ( uc $self->req->method ne 'GET' )
        && ( uc $self->req->method ne 'POST' );

    my $header_stash
        = $model->get_header_stash_auth_mainte( $self->session->{root_id} );
    return $self->redirect_to('index') if !$header_stash;

    $self->stash($header_stash);
    $self->stash->{params} = $self->req->params->to_hash;

    my $path = $self->req->url->path->to_abs_string;

    return $self->mainte_region_serch() if $path eq '/mainte_region_serch';
    return $self->redirect_to('mainte_list');
}

=head2 mainte_region_serch

    region テーブル登録情報の確認、検索

=cut

sub mainte_region_serch {
    my $self  = shift;
    my $model = $self->model_mainte_region();

    my $region_rows = $model->search_region_id_rows();

    $self->stash(
        class       => 'mainte_region_serch',
        region_rows => $region_rows,
        template    => 'mainte/mainte_region_serch',
        format      => 'html',
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

=item * L<Yoyakku::Model::Mainte::Region>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
