package Yoyakku::Controller::Mainte::Region;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Mainte::Region;

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Mainte::Region - region テーブルのコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Mainte::Region version 0.0.1

=head1 SYNOPSIS (概要)

    システム管理者 region 関連機能のリクエストをコントロール

=cut

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Mainte::Region->new();

    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session->{root_id} );

    my $header_stash = $model->get_header_stash_auth_mainte();

    return if !$header_stash;

    $self->stash($header_stash);

    return $model;
}

=head2 mainte_region_serch

    region テーブル登録情報の一覧、検索

=cut

sub mainte_region_serch {
    my $self  = shift;
    my $model = $self->_init();

    return $self->redirect_to('/index') if !$model;

    my $region_rows = $model->search_region_id_rows();

    $self->stash(
        class       => 'mainte_region_serch',
        region_rows => $region_rows,
    );

    return $self->render(
        template => 'mainte/mainte_region_serch',
        format   => 'html',
    );
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Mainte::Region>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
