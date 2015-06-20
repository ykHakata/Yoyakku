package Yoyakku::Controller::Mainte::Reserve;
use Mojo::Base 'Mojolicious::Controller';
use HTML::FillInForm;
use Yoyakku::Controller::Mainte qw{check_login_mainte switch_stash};
use Yoyakku::Model::Mainte::Reserve qw{
    search_reserve_id_rows
    get_init_valid_params_reserve
    get_input_support
    change_format_datetime
    get_update_form_params_reserve
    check_reserve_validator
    check_reserve_validator_db
    writing_reserve
};

# 予約情報 一覧 検索
sub mainte_reserve_serch {
    my $self = shift;

    return $self->redirect_to('/index') if $self->check_login_mainte();

     # テンプレートbodyのクラス名を定義
    my $class = 'mainte_reserve_serch';
    $self->stash( class => $class );

    my $reserve_rows = search_reserve_id_rows( $self->param('reserve_id') );
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
    my $input_support_values      = get_input_support($params);

    $self->stash( %{$init_valid_params_reserve}, %{$input_support_values}, );

    return $self->_insert() if !$params->{id};
    return $self->_update();
}

sub _insert {
    my $self = shift;

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    return $self->_render_reserve($params) if 'GET' eq $method;

    return $self->_common( 'insert', +{ touroku => '登録完了' }, );
}

sub _update {
    my $self = shift;

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    return $self->_render_reserve( get_update_form_params_reserve($params) )
        if 'GET' eq $method;

    return $self->_common( 'update', +{ henkou => '修正完了', }, );
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
