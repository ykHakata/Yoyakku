package Yoyakku::Controller::Mainte::Admin;
use Mojo::Base 'Mojolicious::Controller';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Mainte::Admin - admin テーブルのコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Mainte::Admin version 0.0.1

=head1 SYNOPSIS (概要)

    システム管理者 adimn 関連機能のリクエストをコントロール

=cut

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

sub index {
    my $self  = shift;
    my $model = $self->model->mainte->admin;

    return $self->redirect_to('index')
        if ( uc $self->req->method ne 'GET' )
        && ( uc $self->req->method ne 'POST' );

    my $header_stash
        = $model->get_header_stash_auth_mainte( $self->session->{root_id} );
    return $self->redirect_to('index') if !$header_stash;

    $self->stash($header_stash);
    $self->stash->{params} = $self->req->params->to_hash;

    my $path = $self->req->url->path->to_abs_string;

    return $self->mainte_registrant_serch()
        if $path eq '/mainte_registrant_serch';
    return $self->mainte_registrant_new()
        if $path eq '/mainte_registrant_new';
    return $self->redirect_to('mainte_list');
}

=head2 mainte_registrant_serch

    admin テーブル登録情報の確認、検索

=cut

sub mainte_registrant_serch {
    my $self  = shift;
    my $model = $self->model->mainte->admin();

    my $admin_rows = $model->search_id_single_or_all_rows( 'admin',
        $self->stash->{params}->{admin_id} );

    $self->stash(
        class      => 'mainte_registrant_serch',
        admin_rows => $admin_rows,
        template   => 'mainte/mainte_registrant_serch',
        format     => 'html',
    );
    return $self->render();
}

=head2 mainte_registrant_new

    admin テーブルに新規レコード追加、既存レコード修正

=cut

sub mainte_registrant_new {
    my $self  = shift;
    my $model = $self->model->mainte->admin();

    my $valid_params = $model->get_valid_params('mainte_admin');

    $self->stash(
        class    => 'mainte_registrant_new',
        template => 'mainte/mainte_registrant_new',
        format   => 'html',
        %{$valid_params},
    );

    return $self->_insert() if !$self->stash->{params}->{id};
    return $self->_update();
}

sub _insert {
    my $self  = shift;
    my $model = $self->model->mainte->admin();

    return $self->_render_registrant() if 'GET' eq uc $self->req->method();

    $self->stash->{type} = 'insert';
    $self->flash( +{ touroku => '登録完了' } );

    return $self->_common();
}

sub _update {
    my $self  = shift;
    my $model = $self->model->mainte->admin();

    if ( 'GET' eq uc $self->req->method() ) {
        $self->stash->{params}
            = $model->update_form_params( 'admin', $self->stash->{params} );
        return $self->_render_registrant();
    }

    $self->stash->{type} = 'update';
    $self->flash( +{ henkou => '修正完了' } );
    return $self->_common();
}

sub _common {
    my $self  = shift;
    my $model = $self->model->mainte->admin();

    my $valid_msg
        = $model->check_validator( 'admin', $self->stash->{params} );

    return $self->stash($valid_msg), $self->_render_registrant()
        if $valid_msg;

    my $valid_msg_db
        = $model->check_admin_validator_db( $self->stash->{params} );

    return $self->stash($valid_msg_db), $self->_render_registrant()
        if $valid_msg_db;

    $model->writing_admin( $self->stash->{params}, $self->stash->{type} );

    return $self->redirect_to('mainte_registrant_serch');
}

sub _render_registrant {
    my $self = shift;
    my $html = $self->render_to_string->to_string;
    my $args = +{
        html   => \$html,
        params => $self->stash->{params},
    };
    my $output = $self->model->mainte->admin->set_fill_in_params($args);
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
