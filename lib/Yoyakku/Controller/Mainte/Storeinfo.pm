package Yoyakku::Controller::Mainte::Storeinfo;
use Mojo::Base 'Mojolicious::Controller';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Mainte::Storeinfo - storeinfo テーブルのコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Mainte::Storeinfo version 0.0.1

=head1 SYNOPSIS (概要)

    システム管理者 storeinfo 関連機能のリクエストをコントロール

=cut

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

sub index {
    my $self  = shift;
    my $model = $self->model->mainte->storeinfo;

    return $self->redirect_to('index')
        if ( uc $self->req->method ne 'GET' )
        && ( uc $self->req->method ne 'POST' );

    my $header_stash
        = $model->get_header_stash_auth_mainte( $self->session->{root_id} );
    return $self->redirect_to('index') if !$header_stash;

    $self->stash($header_stash);
    $self->stash->{params} = $self->req->params->to_hash;

    my $path = $self->req->url->path->to_abs_string;

    return $self->mainte_storeinfo_serch()
        if $path eq '/mainte_storeinfo_serch';
    return $self->mainte_storeinfo_new() if $path eq '/mainte_storeinfo_new';
    return $self->redirect_to('mainte_list');
}

=head2 mainte_storeinfo_serch

    storeinfo テーブル登録情報の確認、検索

=cut

sub mainte_storeinfo_serch {
    my $self  = shift;
    my $model = $self->model->mainte->storeinfo();

    my $storeinfo_rows = $model->search_id_single_or_all_rows( 'storeinfo',
        $self->stash->{params}->{storeinfo_id} );

    $self->stash(
        class          => 'mainte_storeinfo_serch',
        storeinfo_rows => $storeinfo_rows,
        template       => 'mainte/mainte_storeinfo_serch',
        format         => 'html',
    );
    return $self->render();
}

=head2 mainte_storeinfo_new

    storeinfo テーブル指定のレコードの修正画面 (更新のみ、新規は admin 承認時)

=cut

sub mainte_storeinfo_new {
    my $self  = shift;
    my $model = $self->model->mainte->storeinfo();

    return $self->redirect_to('mainte_storeinfo_serch')
        if !$self->stash->{params}->{id};

    my $valid_params_storeinfo = $model->get_valid_params('mainte_storeinfo');

    $self->stash(
        class    => 'mainte_storeinfo_new',
        template => 'mainte/mainte_storeinfo_new',
        format   => 'html',
        %{$valid_params_storeinfo},
    );
    return $self->_update();
}

sub _update {
    my $self  = shift;
    my $model = $self->model->mainte->storeinfo;

    if ( 'GET' eq uc $self->req->method() ) {
        $self->stash->{params}
            = $model->update_form_params( 'storeinfo',
            $self->stash->{params} );
        return $self->_render_storeinfo();
    }

    # 郵便番号検索ボタンが押されたときの処理
    if (   $self->stash->{params}->{kensaku}
        && $self->stash->{params}->{kensaku} eq '検索する' )
    {
        $self->stash->{params}
            = $model->search_zipcode_for_address( $self->stash->{params} );
        return $self->_render_storeinfo();
    }

    $self->stash->{type} = 'update';
    $self->flash( +{ henkou => '修正完了' } );
    return $self->_common();
}

sub _common {
    my $self  = shift;
    my $model = $self->model->mainte->storeinfo();

    my $valid_msg
        = $model->check_validator( 'storeinfo', $self->stash->{params} );

    return $self->stash($valid_msg), $self->_render_storeinfo()
        if $valid_msg;

    $model->writing_storeinfo( $self->stash->{params}, $self->stash->{type} );

    return $self->redirect_to('mainte_storeinfo_serch');
}

sub _render_storeinfo {
    my $self = shift;
    my $html = $self->render_to_string->to_string;
    my $args = +{
        html   => \$html,
        params => $self->stash->{params},
    };
    my $output = $self->model->mainte->storeinfo->set_fill_in_params($args);
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
