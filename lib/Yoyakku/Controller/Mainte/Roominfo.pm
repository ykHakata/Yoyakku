package Yoyakku::Controller::Mainte::Roominfo;
use Mojo::Base 'Mojolicious::Controller';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Mainte::Roominfo - roominfo テーブルのコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Mainte::Roominfo version 0.0.1

=head1 SYNOPSIS (概要)

    システム管理者 roominfo 関連機能のリクエストをコントロール

=cut

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

sub index {
    my $self  = shift;
    my $model = $self->model_mainte_roominfo;

    return $self->redirect_to('index')
        if ( uc $self->req->method ne 'GET' )
        && ( uc $self->req->method ne 'POST' );

    my $header_stash
        = $model->get_header_stash_auth_mainte( $self->session->{root_id} );
    return $self->redirect_to('index') if !$header_stash;

    $self->stash($header_stash);
    $self->stash->{params} = $self->req->params->to_hash;

    my $path = $self->req->url->path->to_abs_string;

    return $self->mainte_roominfo_serch() if $path eq '/mainte_roominfo_serch';
    return $self->mainte_roominfo_new()   if $path eq '/mainte_roominfo_new';
    return $self->redirect_to('mainte_list');
}

=head2 mainte_roominfo_serch

    roominfo テーブル登録情報の確認、検索

=cut

sub mainte_roominfo_serch {
    my $self  = shift;
    my $model = $self->model_mainte_roominfo();

    my $roominfo_rows = $model->search_id_single_or_all_rows( 'roominfo',
        $self->stash->{params}->{storeinfo_id} );

    $self->stash(
        class         => 'mainte_roominfo_serch',
        roominfo_rows => $roominfo_rows,
        template      => 'mainte/mainte_roominfo_serch',
        format        => 'html',
    );
    return $self->render();
}

=head2 mainte_roominfo_new

    roominfo テーブル指定のレコードの修正画面 (更新のみ、新規は storeinfo)

=cut

sub mainte_roominfo_new {
    my $self  = shift;
    my $model = $self->model_mainte_roominfo();

    return $self->redirect_to('mainte_roominfo_serch')
        if !$self->stash->{params}->{id};

    my $valid_params_roominfo = $model->get_valid_params('mainte_roominfo');

    $self->stash(
        class    => 'mainte_roominfo_new',
        template => 'mainte/mainte_roominfo_new',
        format   => 'html',
        %{$valid_params_roominfo},
    );

    return $self->_update();
}

sub _update {
    my $self  = shift;
    my $model = $self->model_mainte_roominfo;

    if ( 'GET' eq uc $self->req->method() ) {
        $self->stash->{params}
            = $model->update_form_params( 'roominfo',
            $self->stash->{params} );
        return $self->_render_roominfo();
    }
    $self->stash->{type} = 'update';
    $self->flash( +{ henkou => '修正完了' } );
    return $self->_common();
}

sub _common {
    my $self  = shift;
    my $model = $self->model_mainte_roominfo();

    my $valid_msg
        = $model->check_validator( 'roominfo', $self->stash->{params} );

    return $self->stash($valid_msg), $self->_render_roominfo()
        if $valid_msg;

    $model->writing_roominfo( $self->stash->{params}, $self->stash->{type} );

    return $self->redirect_to('mainte_roominfo_serch');
}

sub _render_roominfo {
    my $self = shift;
    my $html = $self->render_to_string->to_string;
    my $args = +{
        html   => \$html,
        params => $self->stash->{params},
    };
    my $output = $self->model_mainte_roominfo->set_fill_in_params($args);
    return $self->render( text => $output );
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
