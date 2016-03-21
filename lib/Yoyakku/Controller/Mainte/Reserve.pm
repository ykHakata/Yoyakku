package Yoyakku::Controller::Mainte::Reserve;
use Mojo::Base 'Mojolicious::Controller';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Mainte::Reserve - reserve テーブルのコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Mainte::Reserve version 0.0.1

=head1 SYNOPSIS (概要)

    システム管理者 reserve 関連機能のリクエストをコントロール

=cut

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

sub index {
    my $self  = shift;
    my $model = $self->model->mainte->reserve;

    return $self->redirect_to('index')
        if ( uc $self->req->method ne 'GET' )
        && ( uc $self->req->method ne 'POST' );

    my $header_stash
        = $model->get_header_stash_auth_mainte( $self->session->{root_id} );
    return $self->redirect_to('index') if !$header_stash;

    $self->stash($header_stash);
    $self->stash->{params} = $self->req->params->to_hash;

    my $path = $self->req->url->path->to_abs_string;

    return $self->mainte_reserve_serch() if $path eq '/mainte_reserve_serch';
    return $self->mainte_reserve_new()   if $path eq '/mainte_reserve_new';
    return $self->redirect_to('mainte_list');
}

=head2 mainte_reserve_serch

    reserve テーブル登録情報の確認、検索

=cut

sub mainte_reserve_serch {
    my $self  = shift;
    my $model = $self->model->mainte->reserve();

    my $reserve_rows = $model->search_id_single_or_all_rows( 'reserve',
        $self->stash->{params}->{id} );

    $self->stash(
        class        => 'mainte_reserve_serch',
        reserve_rows => $reserve_rows,
        template     => 'mainte/mainte_reserve_serch',
        format       => 'html',
    );
    return $self->render();
}

=head2 mainte_reserve_new

    reserve テーブルに新規レコード追加、既存レコード修正

=cut

sub mainte_reserve_new {
    my $self  = shift;
    my $model = $self->model->mainte->reserve();

    return $self->redirect_to('/mainte_reserve_serch')
        if !$self->stash->{params}->{id}
        && !$self->stash->{params}->{roominfo_id};

    my $valid_params = $model->get_valid_params('mainte_reserve');

    my $input_support_values
        = $model->get_input_support( $self->stash->{params} );

    $self->stash(
        class    => 'mainte_reserve_new',
        template => 'mainte/mainte_reserve_new',
        format   => 'html',
        %{$valid_params}, %{$input_support_values},
    );

    return $self->_insert() if !$self->stash->{params}->{id};
    return $self->_update();
}

sub _insert {
    my $self  = shift;
    my $model = $self->model->mainte->reserve();

    return $self->_render_reserve() if 'GET' eq uc $self->req->method;

    $self->stash->{type} = 'insert';
    $self->flash( +{ touroku => '登録完了' } );

    return $self->_common();
}

sub _update {
    my $self  = shift;
    my $model = $self->model->mainte->reserve();

    if ( 'GET' eq uc $self->req->method() ) {
        $self->stash->{params}
            = $model->update_form_params( 'reserve', $self->stash->{params} );
        return $self->_render_reserve();
    }

    $self->stash->{type} = 'update';
    $self->flash( +{ henkou => '修正完了' } );
    return $self->_common();
}

sub _common {
    my $self  = shift;
    my $model = $self->model->mainte->reserve;

    my $valid_msg
        = $model->check_validator( 'reserve', $self->stash->{params} );

    return $self->stash($valid_msg), $self->_render_reserve()
        if $valid_msg;

    # 日付の形式に変換
    $self->stash->{params}
        = $model->change_format_datetime( $self->stash->{params} );

    # 既存データとのバリデーション DB 問い合わせ
    my $valid_msg_db
        = $model->check_reserve_validator_db( $self->stash->{params},
        $self->stash->{type} );

    return $self->stash($valid_msg_db), $self->_render_reserve()
        if $valid_msg_db;

    $model->writing_reserve( $self->stash->{params}, $self->stash->{type} );

    return $self->redirect_to('mainte_reserve_serch');
}

sub _render_reserve {
    my $self = shift;
    my $html = $self->render_to_string->to_string;
    my $args = +{
        html   => \$html,
        params => $self->stash->{params},
    };
    my $output = $self->model->mainte->reserve->set_fill_in_params($args);
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
