package Yoyakku::Controller::Mainte::Acting;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Mainte::Acting;

has( model_mainte_acting => sub { Yoyakku::Model::Mainte::Acting->new(); } );

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Mainte::Acting - acting テーブルのコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Mainte::Acting version 0.0.1

=head1 SYNOPSIS (概要)

    システム管理者 acting 関連機能のリクエストをコントロール

=cut

sub index {
    my $self  = shift;
    my $model = $self->model_mainte_acting;

    return $self->redirect_to('index')
        if ( uc $self->req->method ne 'GET' )
        && ( uc $self->req->method ne 'POST' );

    my $header_stash
        = $model->get_header_stash_auth_mainte( $self->session->{root_id} );
    return $self->redirect_to('index') if !$header_stash;

    $self->stash($header_stash);
    $self->stash->{params} = $self->req->params->to_hash;

    my $path = $self->req->url->path->to_abs_string;

    return $self->mainte_acting_serch() if $path eq '/mainte_acting_serch';
    return $self->mainte_acting_new()   if $path eq '/mainte_acting_new';
    return $self->redirect_to('mainte_list');
}

=head2 mainte_acting_serch

    acting テーブル登録情報の一覧、検索

=cut

sub mainte_acting_serch {
    my $self  = shift;
    my $model = $self->model_mainte_acting();

    my $acting_rows = $model->search_id_single_or_all_rows( 'acting',
        $self->stash->{params}->{id} );

    $self->stash(
        class       => 'mainte_acting_serch',
        acting_rows => $acting_rows,
        template    => 'mainte/mainte_acting_serch',
        format      => 'html',
    );
    return $self->render();
}

=head2 mainte_acting_new

    acting テーブルに新規レコード追加、既存レコード修正

=cut

sub mainte_acting_new {
    my $self  = shift;
    my $model = $self->model_mainte_acting();

    my $init_valid_params_acting = $model->get_init_valid_params_acting();

    $self->stash(
        class          => 'mainte_acting_new',
        general_rows   => $model->get_general_rows_all(),
        storeinfo_rows => $model->get_storeinfo_rows_all(),
        template       => 'mainte/mainte_acting_new',
        format         => 'html',
        %{$init_valid_params_acting},
    );

    return $self->_insert() if !$self->stash->{params}->{id};
    return $self->_update();
}

sub _insert {
    my $self  = shift;
    my $model = $self->model_mainte_acting();

    return $self->_render_acting() if 'GET' eq uc $self->req->method;

    $model->type('insert');
    $self->flash( +{ touroku => '登録完了' } );

    return $self->_common();
}

sub _update {
    my $self  = shift;
    my $model = $self->model_mainte_acting();

    if ( 'GET' eq uc $self->req->method() ) {
        $self->stash->{params}
            = $model->update_form_params( 'acting', $self->stash->{params} );
        return $self->_render_acting();
    }

    $model->type('update');
    $self->flash( +{ henkou => '修正完了' } );

    return $self->_common();
}

sub _common {
    my $self  = shift;
    my $model = $self->model_mainte_acting();

    my $valid_msg
        = $model->check_validator( 'acting', $self->stash->{params} );

    return $self->stash($valid_msg), $self->_render_acting() if $valid_msg;

    my $valid_msg_db
        = $model->check_acting_validator_db( $self->stash->{params} );

    return $self->stash($valid_msg_db), $self->_render_acting()
        if $valid_msg_db;

    $model->writing_acting( $self->stash->{params} );

    return $self->redirect_to('mainte_acting_serch');
}

sub _render_acting {
    my $self = shift;
    my $html = $self->render_to_string->to_string;
    my $args = +{
        html   => \$html,
        params => $self->stash->{params},
    };
    my $output = $self->model_mainte_acting->set_fill_in_params($args);
    return $self->render( text => $output );
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Mainte::Acting>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
