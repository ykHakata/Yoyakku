package Yoyakku::Controller::Profile;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Profile;

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Profile->new();

    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session );

    return if !$model->check_auth_db_yoyakku();

    my $header_stash = $model->get_header_stash_profile();
    $self->stash($header_stash);

    return $model;
}

sub profile_comp {
    my $self  = shift;
    my $model = $self->_init();

    return $self->redirect_to('/index') if !$model;

    $self->stash(
        class         => 'profile_comp',
        login         => $model->login_name(),
        switch_acting => $model->get_switch_acting(),
    );

    $model->set_form_params_profile('profile_comp');
    $model->template('profile_comp');
    return $self->_render_profile($model);
}

sub profile {
    my $self  = shift;
    my $model = $self->_init();

    return $self->redirect_to('/index') if !$model;

    my $init_valid_params_profile = $model->get_init_valid_params_profile();

    $self->stash(
        class          => 'profile',
        login          => $model->login_name(),
        storeinfo_rows => $model->get_storeinfo_rows_all(),
        switch_acting  => $model->get_switch_acting(),
        %{$init_valid_params_profile},
    );

    $model->template('profile');

    return $self->_insert($model) if !$model->profile_row();
    return $self->_update($model);
}

sub _insert {
    my $self  = shift;
    my $model = shift;

    if ( 'GET' eq $model->method() ) {
        $model->set_form_params_profile('profile');
        return $self->_render_profile($model);
    }

    $model->type('insert');
    $model->flash_msg( +{ touroku => '登録完了' } );

    return $self->_common($model);
}

sub _update {
    my $self  = shift;
    my $model = shift;

    if ( 'GET' eq $model->method() ) {
        $model->set_form_params_profile('profile');
        return $self->_render_profile($model);
    }

    $model->type('update');
    $model->flash_msg( +{ henkou => '修正完了' } );

    return $self->_common($model);
}

sub _common {
    my $self  = shift;
    my $model = shift;

    my $valid_msg = $model->check_profile_with_auth_validator();

    return $self->stash($valid_msg), $self->_render_profile($model)
        if $valid_msg;

    $model->writing_profile();
    $self->flash( $model->flash_msg() );
    return $self->redirect_to('profile_comp');
}

sub _render_profile {
    my $self  = shift;
    my $model = shift;

    my $html = $self->render_to_string(
        template => $model->template(),
        format   => 'html',
    )->to_string;

    $model->html( \$html );
    my $output = $model->get_fill_in_profile();
    return $self->render( text => $output );
}

1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Controller::Profile - ユーザー個人情報のコントローラー

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Controller::Profile version 0.0.1

=head1 SYNOPSIS (概要)

プロフィール関連機能のリクエストをコントロール

=head2 profile_comp

    プロフィール情報確認画面

=head2 profile

    リクエスト
    URL: http:// ... /profile
    METHOD: GET

    他詳細は調査、実装中

    プロフィール登録画面

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Profile>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
