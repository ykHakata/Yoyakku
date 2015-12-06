package Yoyakku::Controller::Mainte::Reserve;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Mainte::Reserve;

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Mainte::Reserve - reserve テーブルのコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Mainte::Reserve version 0.0.1

=head1 SYNOPSIS (概要)

    システム管理者 reserve 関連機能のリクエストをコントロール

=cut

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Mainte::Reserve->new();

    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session->{root_id} );

    my $header_stash = $model->get_header_stash_auth_mainte();

    return if !$header_stash;

    $self->stash($header_stash);

    return $model;
}

=head2 mainte_reserve_serch

    reserve テーブル登録情報の一覧、検索

=cut

sub mainte_reserve_serch {
    my $self  = shift;
    my $model = $self->_init();

    return $self->redirect_to('/index') if !$model;

    my $reserve_rows = $model->search_reserve_id_rows();

    $self->stash(
        class        => 'mainte_reserve_serch',
        reserve_rows => $reserve_rows,
    );

    return $self->render(
        template => 'mainte/mainte_reserve_serch',
        format   => 'html',
    );
}

=head2 mainte_reserve_new

    reserve テーブルに新規レコード追加、既存レコード修正

=cut

sub mainte_reserve_new {
    my $self  = shift;
    my $model = $self->_init();

    return $self->redirect_to('/index') if !$model;

    return $self->redirect_to('/mainte_reserve_serch')
        if ( $model->method() ne 'GET' ) && ( $model->method() ne 'POST' );

    return $self->redirect_to('/mainte_reserve_serch')
        if !$model->params()->{id} && !$model->params()->{roominfo_id};

    my $init_valid_params_reserve = $model->get_init_valid_params_reserve();
    my $input_support_values      = $model->get_input_support();

    $self->stash(
        class => 'mainte_reserve_new',
        %{$init_valid_params_reserve}, %{$input_support_values},
    );

    return $self->_insert($model) if !$model->params()->{id};
    return $self->_update($model);
}

sub _insert {
    my $self  = shift;
    my $model = shift;

    return $self->_render_reserve($model) if 'GET' eq $model->method();

    $model->type('insert');
    $model->flash_msg( +{ touroku => '登録完了' } );

    return $self->_common($model);
}

sub _update {
    my $self  = shift;
    my $model = shift;

    return $self->_render_reserve( $model->get_update_form_params_reserve() )
        if 'GET' eq $model->method();

    $model->type('update');
    $model->flash_msg( +{ henkou => '修正完了' } );

    return $self->_common($model);
}

sub _common {
    my $self  = shift;
    my $model = shift;

    my $valid_msg = $model->check_reserve_validator();

    return $self->stash($valid_msg), $self->_render_reserve($model)
        if $valid_msg;

    # 日付の形式に変換
    $model->params( $model->change_format_datetime() );

    # 既存データとのバリデーション DB 問い合わせ
    my $valid_msg_db = $model->check_reserve_validator_db();

    return $self->stash($valid_msg_db), $self->_render_reserve($model)
        if $valid_msg_db;

    $model->writing_reserve();
    $self->flash( $model->flash_msg() );

    return $self->redirect_to('mainte_reserve_serch');
}

sub _render_reserve {
    my $self  = shift;
    my $model = shift;

    my $html = $self->render_to_string(
        template => 'mainte/mainte_reserve_new',
        format   => 'html',
    )->to_string;

    $model->html( \$html );
    my $output = $model->get_fill_in_reserve();
    return $self->render( text => $output );
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Mainte::Reserve>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
