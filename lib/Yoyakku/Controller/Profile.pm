package Yoyakku::Controller::Profile;
use Mojo::Base 'Mojolicious::Controller';

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
    my $model = $self->model->profile;

    return $self->redirect_to('index')
        if ( uc $self->req->method ne 'GET' )
        && ( uc $self->req->method ne 'POST' );

    $self->stash->{login_row}
        = $self->model->auth->get_logged_in_row( $self->session );
    return $self->redirect_to('index') if !$self->stash->{login_row};

    my $header_stash
        = $model->get_header_stash_profile( $self->stash->{login_row} );

    $self->stash($header_stash);
    $self->stash->{params} = $self->req->params->to_hash;

    my $path = $self->req->url->path->to_abs_string;

    return $self->profile()      if $path eq '/profile';
    return $self->profile_comp() if $path eq '/profile_comp';
    return $self->redirect_to('index');
}

=head2 profile_comp

    プロフィール情報確認画面

=cut

sub profile_comp {
    my $self  = shift;
    my $model = $self->model->profile();

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
}

=head2 profile

    プロフィール登録画面

=cut

sub profile {
    my $self  = shift;
    my $model = $self->model->profile();

    my $valid_params = $self->model->profile->get_valid_params('profile');

    $self->stash(
        class          => 'profile',
        login          => $self->stash->{login_row}->get_login_name,
        storeinfo_rows => $model->get_storeinfo_rows_all(),
        switch_acting =>
            $model->get_switch_acting( $self->stash->{login_row} ),
        template => 'profile/profile',
        format   => 'html',
        %{$valid_params},
    );

    return $self->_insert() if !$self->stash->{login_row}->fetch_profile;
    return $self->_update();
}

sub _insert {
    my $self  = shift;
    my $model = $self->model->profile;

    if ( 'GET' eq uc $self->req->method ) {
        $self->stash->{params} = $model->set_form_params_profile( 'profile',
            $self->stash->{login_row} );
        return $self->_render_profile();
    }

    $self->stash->{type} = 'insert';
    $self->flash( +{ touroku => '登録完了' } );

    return $self->_common();
}

sub _update {
    my $self  = shift;
    my $model = $self->model->profile;

    if ( 'GET' eq uc $self->req->method ) {
        $self->stash->{params} = $model->set_form_params_profile( 'profile',
            $self->stash->{login_row} );
        return $self->_render_profile();
    }

    $self->stash->{type} = 'update';
    $self->flash( +{ henkou => '修正完了' } );

    return $self->_common();
}

sub _common {
    my $self  = shift;
    my $model = $self->model->profile;

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
}

sub _render_profile {
    my $self = shift;
    my $html = $self->render_to_string->to_string;
    my $args = +{
        html   => \$html,
        params => $self->stash->{params},
    };
    my $output = $self->model->profile->set_fill_in_params($args);
    return $self->render( text => $output );
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
