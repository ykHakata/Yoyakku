package Yoyakku::Model::Mainte::Profile;
use strict;
use warnings;
use utf8;
use Yoyakku::Model qw{$teng};
use Yoyakku::Model::Mainte qw{
    get_header_stash_auth_mainte
    search_id_single_or_all_rows
    get_init_valid_params
    get_update_form_params
    get_msg_validator
    writing_db
    check_table_column
};
use Yoyakku::Util qw{now_datetime get_fill_in_params};

sub new {
    my $class  = shift;
    my $params = +{};
    my $self   = bless $params, $class;
    return $self;
}

sub params {
    my $self   = shift;
    my $params = shift;
    if ($params) {
        $self->{params} = $params;
    }
    return $self->{params};
}

sub session {
    my $self    = shift;
    my $session = shift;
    if ($session) {
        $self->{session} = $session;
    }
    return $self->{session};
}

sub method {
    my $self   = shift;
    my $method = shift;
    if ($method) {
        $self->{method} = $method;
    }
    return $self->{method};
}

sub type {
    my $self = shift;
    my $type = shift;
    if ($type) {
        $self->{type} = $type;
    }
    return $self->{type};
}

sub flash_msg {
    my $self      = shift;
    my $flash_msg = shift;
    if ($flash_msg) {
        $self->{flash_msg} = $flash_msg;
    }
    return $self->{flash_msg};
}

sub html {
    my $self = shift;
    my $html = shift;
    if ($html) {
        $self->{html} = $html;
    }
    return $self->{html};
}

sub check_auth_profile {
    my $self = shift;
    return get_header_stash_auth_mainte( $self->session() );
}

sub search_profile_id_rows {
    my $self = shift;
    return search_id_single_or_all_rows( 'profile',
        $self->params()->{profile_id} );
}

sub get_init_valid_params_profile {
    my $self = shift;
    my $valid_params
        = [
        qw{general_id admin_id nick_name full_name phonetic_name tel mail}];
    return get_init_valid_params($valid_params);
}

sub get_update_form_params_profile {
    my $self   = shift;
    my $params = $self->params();
    $params = get_update_form_params( $params, 'profile', );
    $self->params($params);
    return $self;
}

sub get_general_rows_all {
    my $self = shift;
    my @general_rows = $teng->search( 'general', +{}, );
    return \@general_rows;
}

sub get_admin_rows_all {
    my $self = shift;
    my @admin_rows = $teng->search( 'admin', +{}, );
    return \@admin_rows;
}

sub check_profile_validator {
    my $self   = shift;
    my $params = $self->params();

    my $check_params = [
        general_id    => [ 'INT', ],
        admin_id      => [ 'INT', ],
        nick_name     => [ [ 'LENGTH', 0, 20, ], ],
        full_name     => [ [ 'LENGTH', 0, 20, ], ],
        phonetic_name => [ [ 'LENGTH', 0, 20, ], ],
        tel           => [ [ 'LENGTH', 0, 20, ], ],
        mail          => [ 'EMAIL_LOOSE', ],
    ];

    my $msg_params = [
        'general_id.not_null'  => '指定の形式で入力してください',
        'admin_id.not_null'    => '指定の形式で入力してください',
        'nick_name.length'     => '文字数!!',
        'full_name.length'     => '文字数!!',
        'phonetic_name.length' => '文字数!!',
        'tel.length'           => '文字数!!',
        'mail.email_loose'     => 'Eメールを入力してください',
    ];

    my $msg = get_msg_validator( $params, $check_params, $msg_params, );

    return if !$msg;

    my $valid_msg_profile = +{
        general_id    => $msg->{general_id},
        admin_id      => $msg->{admin_id},
        nick_name     => $msg->{nick_name},
        full_name     => $msg->{full_name},
        phonetic_name => $msg->{phonetic_name},
        tel           => $msg->{tel},
        mail          => $msg->{mail},
    };

    return $valid_msg_profile;
}

sub check_profile_validator_db {
    my $self   = shift;
    my $type   = $self->type();
    my $params = $self->params();

    my $valid_msg_profile_db = +{};

    # general_id, admin_id, 重複、既存の確認
    my $check_admin_and_general_msg = _check_admin_and_general_id( $params );

    if ($check_admin_and_general_msg) {
        $valid_msg_profile_db
            = +{ general_id => $check_admin_and_general_msg };
    }

    return $valid_msg_profile_db if $check_admin_and_general_msg;
    return;
}

sub _check_admin_and_general_id {
    my $params = shift;

    my $general_id = $params->{general_id};
    my $admin_id   = $params->{admin_id};
    my $profile_id = $params->{id};

    # admin_id, general_id の他のレコードでの重複利用をさける
    # 両方に id の指定が存在する場合 両方ない場合
    return '一般,管理どちらかにしてください'
        if ($admin_id && $general_id) || (!$admin_id && !$general_id);

    my $check_params = +{
        column => 'admin_id',
        param  => $admin_id,
        table  => 'profile',
        id     => $profile_id,
    };

    # 管理ユーザー
    return check_table_column($check_params) if $admin_id;

    $check_params->{column} = 'general_id';
    $check_params->{param}  = $general_id;

    # 一般ユーザー
    return check_table_column($check_params) if $general_id;
}

sub writing_profile {
    my $self   = shift;
    my $type   = $self->type();
    my $params = $self->params();

    my $create_data = +{
        general_id    => $params->{general_id} || undef,
        admin_id      => $params->{admin_id} || undef,
        nick_name     => $params->{nick_name},
        full_name     => $params->{full_name},
        phonetic_name => $params->{phonetic_name},
        tel           => $params->{tel},
        mail          => $params->{mail},
        status        => $params->{status},
        create_on     => now_datetime(),
        modify_on     => now_datetime(),
    };
    return writing_db( 'profile', $type, $create_data, $params->{id} );
}

sub get_fill_in_profile {
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

Yoyakku::Model::Mainte::Profile - Profile テーブル管理用 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Mainte::Profile version 0.0.1

=head1 SYNOPSIS (概要)

Profile コントローラーのロジック API

=head2 check_auth_profile

    use Yoyakku::Model::Mainte::profile qw{check_auth_profile};

    # session からログインチェック、ヘッダー用の値を取得
    my $header_stash = check_auth_profile( $self->session->{root_id} );

    # session が不正な場合は undef を返却

ログイン確認

=head2 search_profile_id_rows

    use Yoyakku::Model::Mainte::Profile qw{search_profile_id_rows};

    # 指定の id に該当するレコードを row オブジェクトを配列リファレンスで返却
    my $profile_rows = search_profile_id_rows($profile_id);

    # 指定の id に該当するレコードなき場合 profile 全てのレコード返却

profile テーブル一覧作成時に利用

=head2 get_init_valid_params_profile

    use Yoyakku::Model::Mainte::Profile qw{get_init_valid_params_profile};

    # バリデートエラーメッセージ用パラメーター初期値
    my $init_valid_params_profile = get_init_valid_params_profile();
    $self->stash($init_valid_params_profile);

profile 入力フォーム表示の際に利用

=head2 get_update_form_params_profile

    use Yoyakku::Model::Mainte::Profile qw{get_update_form_params_profile};

    # 修正画面表示用のパラメーターを取得
    return $self->_render_profile( get_update_form_params_profile($params) )
        if 'GET' eq $method;

profile 修正用入力フォーム表示の際に利用

=head2 get_general_rows_all

    use Yoyakku::Model::Mainte::Profile qw{get_general_rows_all};

    # 入力画面セレクト用の general admin ログイン名表示
    $self->stash(
        general_rows => get_general_rows_all(),
    );

profile 入力画面セレクト用のログイン名表示

=head2 get_admin_rows_all

    use Yoyakku::Model::Mainte::Profile qw{get_admin_rows_all};

    # 入力画面セレクト用の general admin ログイン名表示
    $self->stash(
        admin_rows   => get_admin_rows_all(),
    );

profile 入力画面セレクト用のログイン名表示

=head2 check_profile_validator

    use Yoyakku::Model::Mainte::Profile qw{check_profile_validator};

    # バリデート不合格時はエラーメッセージ
    my $valid_msg = check_profile_validator($params);

    # バリデート合格時は undef を返却
    return $self->stash($valid_msg), $self->_render_profile($params)
        if $valid_msg;

profile 入力値バリデートチェックに利用

=head2 check_profile_validator_db

    use Yoyakku::Model::Mainte::Profile qw{check_profile_validator_db};

    # バリデート不合格時はエラーメッセージ
    my $valid_msg_db = check_profile_validator_db( $type, $params, );

    # バリデート合格時は undef を返却
    return $self->stash($valid_msg_db), $self->_render_profile($params)
        if $valid_msg_db;

profile 入力値データベースとのバリデートチェックに利用

=head2 writing_profile

    use Yoyakku::Model::Mainte::Profile qw{writing_profile};

    # profile レコード新規
    writing_profile( 'insert', $params );
    $self->flash( touroku => '登録完了' );

    # profile レコード修正
    writing_profile( 'update', $params );
    $self->flash( henkou => '修正完了' );

profile テーブル書込み、新規、修正、両方に対応

=head2 get_fill_in_profile

    use Yoyakku::Model::Mainte::Profile qw{get_fill_in_profile};

    # テンプレートの html と出力の params から表示用の html を生成
    my $output = get_fill_in_profile( \$html, $params );
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
