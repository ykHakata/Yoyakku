package Yoyakku::Model::Mainte::General;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model::Mainte';
use Yoyakku::Util qw{now_datetime get_fill_in_params};

sub search_general_id_rows {
    my $self = shift;
    return $self->search_id_single_or_all_rows( 'general',
        $self->params()->{general_id} );
}

sub get_init_valid_params_general {
    my $self = shift;
    return $self->get_init_valid_params( [qw{login password}] );
}

sub get_update_form_params_general {
    my $self = shift;
    $self->get_update_form_params('general');
    return $self;
}

sub check_general_validator {
    my $self   = shift;

    my $check_params = [
        login    => [ 'NOT_NULL', ],
        password => [ 'NOT_NULL', ],
    ];

    my $msg_params = [
        'login.not_null'    => '必須入力',
        'password.not_null' => '必須入力',
    ];

    my $msg = $self->get_msg_validator( $check_params, $msg_params, );

    return if !$msg;

    my $valid_msg_general = +{
        login    => $msg->{login},
        password => $msg->{password},
    };

    return $valid_msg_general;
}

sub check_general_validator_db {
    my $self = shift;

    my $valid_msg_general_db = +{};
    my $check_general_msg    = $self->check_login_name('general');

    if ($check_general_msg) {
        $valid_msg_general_db = +{ login => $check_general_msg };
    }
    return $valid_msg_general_db if $check_general_msg;
    return;
}

sub writing_general {
    my $self = shift;

    my $create_data = +{
        login     => $self->params()->{login},
        password  => $self->params()->{password},
        status    => $self->params()->{status},
        create_on => now_datetime(),
        modify_on => now_datetime(),
    };
    return $self->writing_db( 'general', $create_data,
        $self->params()->{id} );
}

sub get_fill_in_general {
    my $self   = shift;
    my $html   = $self->html();
    my $params = $self->params();
    my $output = get_fill_in_params( $html, $params );
    return $output;
}

1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model::Mainte::General - general テーブル管理用 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Mainte::General version 0.0.1

=head1 SYNOPSIS (概要)

General コントローラーのロジック API

=head2 check_auth_general

    use Yoyakku::Model::Mainte::General qw{check_auth_general};

    # session からログインチェック、ヘッダー用の値を取得
    my $header_stash = check_auth_general( $self->session->{root_id} );

    # session が不正な場合は undef を返却

ログイン確認

=head2 search_general_id_rows

    use Yoyakku::Model::Mainte::General qw{search_general_id_rows};

    # 指定の id に該当するレコードを row オブジェクトを配列リファレンスで返却
    my $general_rows = search_general_id_rows($general_id);

    # 指定の id に該当するレコードなき場合 general 全てのレコード返却

general テーブル一覧作成時に利用

=head2 get_init_valid_params_general

    use Yoyakku::Model::Mainte::General qw{get_init_valid_params_general};

    # バリデートエラーメッセージ用パラメーター初期値
    my $init_valid_params_general = get_init_valid_params_general();
    $self->stash($init_valid_params_general);

general 入力フォーム表示の際に利用

=head2 get_update_form_params_general

    use Yoyakku::Model::Mainte::General qw{get_update_form_params_general};

    # 修正画面表示用のパラメーターを取得
    return $self->_render_general( get_update_form_params_general($params) )
        if 'GET' eq $method;

general 修正用入力フォーム表示の際に利用

=head2 check_general_validator

    use Yoyakku::Model::Mainte::General qw{check_general_validator};

    # バリデート不合格時はエラーメッセージ
    my $valid_msg = check_general_validator($params);

    # バリデート合格時は undef を返却
    return $self->stash($valid_msg), $self->_render_general($params)
        if $valid_msg;

general 入力値バリデートチェックに利用

=head2 check_general_validator_db

    use Yoyakku::Model::Mainte::General qw{check_general_validator_db};

    # バリデート不合格時はエラーメッセージ
    my $valid_msg_db = check_general_validator_db( $type, $params, );

    # バリデート合格時は undef を返却
    return $self->stash($valid_msg_db), $self->_render_general($params)
        if $valid_msg_db;

general 入力値データベースとのバリデートチェックに利用

=head2 writing_general

    use Yoyakku::Model::Mainte::General qw{writing_general};

    # general レコード新規
    writing_general( 'insert', $params );
    $self->flash( touroku => '登録完了' );

    # general レコード修正
    writing_general( 'update', $params );
    $self->flash( henkou => '修正完了' );

general テーブル書込み、新規、修正、両方に対応

=head2 get_fill_in_general

    use Yoyakku::Model::Mainte::General qw{get_fill_in_general};

    # テンプレートの html と出力の params から表示用の html を生成
    my $output = get_fill_in_general( \$html, $params );
    return $self->render( text => $output );

表示用 html を生成

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<Yoyakku::Model>

=item * L<Yoyakku::Model::Mainte>

=item * L<Yoyakku::Util>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
