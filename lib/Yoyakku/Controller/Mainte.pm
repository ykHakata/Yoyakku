package Yoyakku::Controller::Mainte;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Mainte;

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Mainte->new();

    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session->{root_id} );

    my $header_stash = $model->get_header_stash_auth_mainte();

    return $self->redirect_to('/index') if !$header_stash;

    $self->stash($header_stash);

    return $model;
}

sub mainte_list {
    my $self  = shift;
    my $model = $self->_init();

    my $login_data = $self->stash->{login_data};

    $self->stash(
        class => 'mainte_list',
        today => $login_data->{today},
    );

    return $self->render(
        template => 'mainte/mainte_list',
        format   => 'html',
    );
}

1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Controller::Mainte - システム管理者機能のコントローラー

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Controller::Mainte version 0.0.1

=head1 SYNOPSIS (概要)

システム管理者関連機能のリクエストをコントロール

=head2 mainte_list

    リクエスト
    URL: http:// ... /mainte_list
    METHOD: GET

    他詳細は調査、実装中

システム管理のオープニング画面

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Mainte>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
