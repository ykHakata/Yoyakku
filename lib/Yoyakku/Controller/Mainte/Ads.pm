package Yoyakku::Controller::Mainte::Ads;
use Mojo::Base 'Mojolicious::Controller';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Mainte::Ads - ads テーブルのコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Mainte::Ads version 0.0.1

=head1 SYNOPSIS (概要)

    システム管理者 ads 関連機能のリクエストをコントロール

=cut

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

sub index {
    my $self  = shift;
    my $model = $self->model->mainte->ads;

    return $self->redirect_to('index')
        if ( uc $self->req->method ne 'GET' )
        && ( uc $self->req->method ne 'POST' );

    my $header_stash
        = $model->get_header_stash_auth_mainte( $self->session->{root_id} );
    return $self->redirect_to('index') if !$header_stash;

    $self->stash($header_stash);
    $self->stash->{params} = $self->req->params->to_hash;

    my $path = $self->req->url->path->to_abs_string;

    return $self->mainte_ads_serch() if $path eq '/mainte_ads_serch';
    return $self->mainte_ads_new()   if $path eq '/mainte_ads_new';
    return $self->redirect_to('mainte_list');
}

=head2 mainte_ads_serch

    ads テーブル登録情報の確認、検索

=cut

sub mainte_ads_serch {
    my $self  = shift;
    my $model = $self->model->mainte->ads();

    my $ads_rows = $model->search_id_single_or_all_rows( 'ads',
        $self->stash->{params}->{id} );

    $self->stash(
        class    => 'mainte_ads_serch',
        ads_rows => $ads_rows,
        template => 'mainte/mainte_ads_serch',
        format   => 'html',
    );
    return $self->render();
}

=head2 mainte_ads_new

    ads テーブルに新規レコード追加、既存レコード修正

=cut

sub mainte_ads_new {
    my $self  = shift;
    my $model = $self->model->mainte->ads();

    my $valid_params = $model->get_valid_params('mainte_ads');

    $self->stash(
        class          => 'mainte_ads_new',
        storeinfo_rows => $self->model->db->storeinfo->rows_all(),
        region_rows    => $model->get_region_rows_pref(),
        template       => 'mainte/mainte_ads_new',
        format         => 'html',
        %{$valid_params},
    );

    return $self->_insert() if !$self->stash->{params}->{id};
    return $self->_update();
}

sub _insert {
    my $self  = shift;
    my $model = $self->model->mainte->ads();

    return $self->_render_ads() if 'GET' eq uc $self->req->method;

    $self->stash->{type} = 'insert';
    $self->flash( +{ touroku => '登録完了' } );

    return $self->_common();
}

sub _update {
    my $self  = shift;
    my $model = $self->model->mainte->ads();

    if ( 'GET' eq uc $self->req->method() ) {
        $self->stash->{params}
            = $model->update_form_params( 'ads', $self->stash->{params} );
        return $self->_render_ads();
    }

    $self->stash->{type} = 'update';
    $self->flash( +{ henkou => '修正完了' } );
    return $self->_common();
}

sub _common {
    my $self  = shift;
    my $model = $self->model->mainte->ads;

    my $valid_msg = $self->model->validator->check( 'ads', $self->stash->{params} );

    return $self->stash($valid_msg), $self->_render_ads() if $valid_msg;

    $self->model->db->ads->writing( $self->stash->{params},
        $self->stash->{type} );

    return $self->redirect_to('mainte_ads_serch');
}

sub _render_ads {
    my $self = shift;
    my $html = $self->render_to_string->to_string;
    my $args = +{
        html   => \$html,
        params => $self->stash->{params},
    };
    my $output = $self->model->mainte->ads->set_fill_in_params($args);
    return $self->render( text => $output );
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Mainte::Ads>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
