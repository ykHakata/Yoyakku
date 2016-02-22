package Yoyakku::Controller::Profile;
use Mojo::Base 'Mojolicious::Controller';
# use Yoyakku::Model::Profile;

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Profile - ユーザー個人情報のコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Profile version 0.0.1

=head1 SYNOPSIS (概要)

    プロフィール関連機能のリクエストをコントロール

=cut

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

sub index {
    my $self  = shift;
    my $model = $self->model_profile;

    return $self->redirect_to('index')
        if ( uc $self->req->method ne 'GET' )
        && ( uc $self->req->method ne 'POST' );

    return $self->redirect_to('index')
        if !$model->check_auth_db_yoyakku( $self->session );

    $self->stash->{login_row} = $model->get_login_row( $self->session );

    my $header_stash
        = $model->get_header_stash_profile( $self->stash->{login_row} );

    $self->stash($header_stash);
    $self->stash->{params} = $self->req->params->to_hash;

    my $path = $self->req->url->path->to_abs_string;

    return $self->profile()      if $path eq '/profile';
    return $self->profile_comp() if $path eq '/profile_comp';
    return $self->redirect_to('index');
}

# sub _init {
#     my $self  = shift;
#     my $model = Yoyakku::Model::Profile->new();

#     $model->params( $self->req->params->to_hash );
#     $model->method( uc $self->req->method );
#     $model->session( $self->session );

#     return if !$model->check_auth_db_yoyakku();

#     my $header_stash = $model->get_header_stash_profile();
#     $self->stash($header_stash);

#     return $model;
# }

=head2 profile_comp

    プロフィール情報確認画面

=cut

sub profile_comp {
    my $self  = shift;
    my $model = $self->model_profile();

    $self->stash(
        class => 'profile_comp',
        login => $self->stash->{login_row}->get_login_name,
        switch_acting =>
            $model->get_switch_acting( $self->stash->{login_row} ),
        template => 'profile/profile_comp',
        format   => 'html',
    );

    $self->stash->{params} = $model->set_form_params_profile( 'profile_comp',
        $self->stash->{login_row} );

    return $self->_render_profile();
    # my $self  = shift;
    # my $model = $self->_init();

    # return $self->redirect_to('/index') if !$model;

    # $self->stash(
    #     class         => 'profile_comp',
    #     login         => $model->login_name(),
    #     switch_acting => $model->get_switch_acting(),
    # );

    # $model->set_form_params_profile('profile_comp');
    # $model->template('profile/profile_comp');
    # return $self->_render_profile($model);
}

=head2 profile

    リクエスト
    URL: http:// ... /profile
    METHOD: GET

    他詳細は調査、実装中

    プロフィール登録画面

=cut

sub profile {
    my $self  = shift;
    my $model = $self->model_profile();

    my $valid_params = $self->model_profile->get_valid_params('profile');

    $self->stash(
        class          => 'profile',
        login          => $self->stash->{login_row}->get_login_name,
        storeinfo_rows => $model->get_storeinfo_rows_all(),
        switch_acting  => $model->get_switch_acting($self->stash->{login_row}),
        template       => 'profile/profile',
        format         => 'html',
        %{$valid_params},
    );

    return $self->_insert() if !$self->stash->{login_row}->fetch_profile;
    return $self->_update();

    # my $self  = shift;
    # my $model = $self->_init();

    # return $self->redirect_to('/index') if !$model;

    # my $init_valid_params_profile = $model->get_init_valid_params_profile();

    # $self->stash(
    #     class          => 'profile',
    #     login          => $model->login_name(),
    #     storeinfo_rows => $model->get_storeinfo_rows_all(),
    #     switch_acting  => $model->get_switch_acting(),
    #     %{$init_valid_params_profile},
    # );

    # $model->template('profile/profile');

    # return $self->_insert($model) if !$model->profile_row();
    # return $self->_update($model);
}

sub _insert {
    my $self  = shift;
    my $model = $self->model_profile;

    if ( 'GET' eq uc $self->req->method ) {
        $self->stash->{params} = $model->set_form_params_profile( 'profile',
            $self->stash->{login_row} );
        return $self->_render_profile();
    }

    $self->stash->{type} = 'insert';
    $self->flash( +{ touroku => '登録完了' } );

    return $self->_common();
    # my $self  = shift;
    # my $model = shift;

    # if ( 'GET' eq $model->method() ) {
    #     $model->set_form_params_profile('profile');
    #     return $self->_render_profile($model);
    # }

    # $model->type('insert');
    # $model->flash_msg( +{ touroku => '登録完了' } );

    # return $self->_common($model);
}

sub _update {
    my $self  = shift;
    my $model = $self->model_profile;

    if ( 'GET' eq uc $self->req->method ) {
        $self->stash->{params} = $model->set_form_params_profile( 'profile',
            $self->stash->{login_row} );
        return $self->_render_profile();
    }

    $self->stash->{type} = 'update';
    $self->flash( +{ henkou => '修正完了' } );
    return $self->_common();
    # my $self  = shift;
    # my $model = shift;

    # if ( 'GET' eq $model->method() ) {
    #     $model->set_form_params_profile('profile');
    #     return $self->_render_profile($model);
    # }

    # $model->type('update');
    # $model->flash_msg( +{ henkou => '修正完了' } );

    # return $self->_common($model);
}

sub _common {
    my $self  = shift;
    my $model = $self->model_profile;

    my $valid_msg = $model->check_validator( 'profile_with_auth',
        $self->stash->{params} );

    return $self->stash($valid_msg), $self->_render_profile()
        if $valid_msg;

    $model->writing_profile(
        $self->stash->{params},
        $self->stash->{type},
        $self->stash->{login_row},
    );

    return $self->redirect_to('profile_comp');
    # my $self  = shift;
    # my $model = shift;

    # my $valid_msg = $model->check_profile_with_auth_validator();

    # return $self->stash($valid_msg), $self->_render_profile($model)
    #     if $valid_msg;

    # $model->writing_profile();
    # $self->flash( $model->flash_msg() );
    # return $self->redirect_to('profile_comp');
}

sub _render_profile {
    my $self = shift;
    my $html = $self->render_to_string->to_string;
    my $args = +{
        html   => \$html,
        params => $self->stash->{params},
    };
    my $output = $self->model_profile->set_fill_in_params($args);
    return $self->render( text => $output );
    # my $self  = shift;
    # my $model = shift;

    # my $html = $self->render_to_string(
    #     template => $model->template(),
    #     format   => 'html',
    # )->to_string;

    # $model->html( \$html );
    # my $output = $model->get_fill_in_profile();
    # return $self->render( text => $output );
}

1;

__END__

TODO_MEMO:

    acting 機能についての注意
    acting (代行リスト) で選べる店舗 (storeinfo) は storeinfoの
    web 公開 (status) が 公開(0)、非公開(1)、どちらでも
    選べるようにしておく(当初そういう仕様になっている)
    店舗 (storeinfo) の status は、新規で作成されたときは status 1
    #admin_pub_edit.html.ep
    #予約部屋、web公開設定コントロール
    で、roominfoの公開設定が終了する時点で、 status 0 に切り替えられて
    店舗 (storeinfo) が有効 0: web公開 になる。
    ステータス (例: 0: web公開, 1: web非公開, 2: 削除)

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
