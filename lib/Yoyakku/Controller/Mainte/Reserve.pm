package Yoyakku::Controller::Mainte::Reserve;
use Mojo::Base 'Mojolicious::Controller';
use HTML::FillInForm;
use Yoyakku::Controller::Mainte qw{check_login_mainte switch_stash};
use Yoyakku::Model::Mainte::Reserve qw{
    search_reserve_id_rows
    change_format_datetime
    writing_reserve
    search_reserve_id_row
    get_startend_day_and_time
    get_init_valid_params_reserve
    get_input_support
    check_reserve_validator
    check_reserve_validator_db
};
use Data::Dumper;

# 予約情報 一覧 検索
sub mainte_reserve_serch {
    my $self = shift;

    return $self->redirect_to('/index') if $self->check_login_mainte();

     # テンプレートbodyのクラス名を定義
    my $class = 'mainte_reserve_serch';
    $self->stash( class => $class );

    my $reserve_id = $self->param('reserve_id');

    my $reserve_rows = search_reserve_id_rows($reserve_id);

    $self->stash( reserve_rows => $reserve_rows );

    return $self->render(
        template => 'mainte/mainte_reserve_serch',
        format   => 'html',
    );
}

# 予約情報 新規 編集
sub mainte_reserve_new {
    my $self = shift;

    return $self->redirect_to('/index') if $self->check_login_mainte();

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    return $self->redirect_to('/mainte_reserve_serch')
        if ( $method ne 'GET' ) && ( $method ne 'POST' );

    return $self->redirect_to('/mainte_reserve_serch')
        if !$params->{id} && !$params->{roominfo_id};

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_reserve_new';
    $self->stash( class => $class );

    my $init_valid_params_reserve = get_init_valid_params_reserve();

    my $input_support_values
        = get_input_support( $params->{id}, $params->{roominfo_id}, );

    $self->stash( %{$init_valid_params_reserve}, %{$input_support_values}, );

    return $self->_insert() if !$params->{id};
    return $self->_update();
}

sub _insert {
    my $self = shift;

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    return $self->_render_reserve($params) if 'GET' eq $method;

    my $flash_msg = +{ touroku => '登録完了' };

    return $self->_common( 'insert', $flash_msg, );
}

sub _update {
    my $self = shift;

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    return $self->_render_update_form($params) if 'GET' eq $method;

    my $flash_msg = +{ henkou => '修正完了', };

    return $self->_common( 'update', $flash_msg, );
}

sub _common {
    my $self      = shift;
    my $type      = shift;
    my $flash_msg = shift;

    my $params = $self->req->params->to_hash;

    my $valid_msg = check_reserve_validator($params);

    return $self->stash($valid_msg), $self->_render_reserve($params)
        if $valid_msg;

    # 日付の形式に変換
    $params = change_format_datetime($params);

    # 既存データとのバリデーション DB 問い合わせ
    my $valid_msg_db = check_reserve_validator_db( $type, $params, );

    return $self->stash($valid_msg_db), $self->_render_reserve($params)
        if $valid_msg_db;

    writing_reserve( $type, $params );
    $self->flash($flash_msg);

    return $self->redirect_to('mainte_reserve_serch');
}

sub _render_update_form {
    my $self   = shift;
    my $params = shift;

    my $reserve_row       = search_reserve_id_row( $params->{id} );
    my $startend_day_time = get_startend_day_and_time($reserve_row);

    # 入力フォームフィルイン用
    $params = +{
        id                 => $reserve_row->id,
        roominfo_id        => $reserve_row->roominfo_id,
        getstarted_on_day  => $startend_day_time->{getstarted_on_day},
        getstarted_on_time => $startend_day_time->{getstarted_on_time},
        enduse_on_day      => $startend_day_time->{enduse_on_day},
        enduse_on_time     => $startend_day_time->{enduse_on_time},
        useform            => $reserve_row->useform,
        message            => $reserve_row->message,
        general_id         => $reserve_row->general_id,
        admin_id           => $reserve_row->admin_id,
        tel                => $reserve_row->tel,
        status             => $reserve_row->status,
        create_on          => $reserve_row->create_on,
        modify_on          => $reserve_row->modify_on,
    };

    return $self->_render_reserve($params);
}

# テンプレート画面のレンダリング
sub _render_reserve {
    my $self   = shift;
    my $params = shift;

    my $html = $self->render_to_string(
        template => 'mainte/mainte_reserve_new',
        format   => 'html',
    )->to_string;

    my $output = HTML::FillInForm->fill( \$html, $params );

    return $self->render( text => $output );
}

1;

__END__
