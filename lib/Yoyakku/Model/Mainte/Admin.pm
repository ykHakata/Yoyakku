package Yoyakku::Model::Mainte::Admin;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model::Mainte';
use Yoyakku::Util qw{now_datetime get_fill_in_params};

sub search_admin_id_rows {
    my $self = shift;
    return $self->search_id_single_or_all_rows( 'admin',
        $self->params()->{admin_id} );
}

sub get_init_valid_params_admin {
    my $self = shift;
    return $self->get_init_valid_params( [qw{login password}] );
}

sub get_update_form_params_admin {
    my $self = shift;
    $self->get_update_form_params('admin');
    return $self;
}

sub check_admin_validator {
    my $self = shift;

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

    my $valid_msg_admin = +{
        login    => $msg->{login},
        password => $msg->{password},
    };

    return $valid_msg_admin;
}

sub check_admin_validator_db {
    my $self = shift;

    my $valid_msg_admin_db = +{};
    my $check_admin_msg    = $self->check_login_name('admin');

    if ($check_admin_msg) {
        $valid_msg_admin_db = +{ login => $check_admin_msg };
    }
    return $valid_msg_admin_db if $check_admin_msg;
    return;
}

sub writing_admin {
    my $self = shift;
    my $teng = $self->teng();

    my $create_data = +{
        login     => $self->params()->{login},
        password  => $self->params()->{password},
        status    => $self->params()->{status},
        create_on => now_datetime(),
        modify_on => now_datetime(),
    };

    my $insert_admin_row
        = $self->writing_db( 'admin', $create_data, $self->params()->{id} );

    die 'not $insert_admin_row' if !$insert_admin_row;

    # status: (0: 未承認, 1: 承認済み, 2: 削除済み)
    # 今作った管理者IDでステータスが1 (承認済み) で
    # storeinfo に今作った管理者 id が存在しないときは、
    # 新たに storeinfo にデータ作成し、
    # 今作った管理者 id を入力しておく
    # 作成時刻が一番新しい管理者 id を取得する
    # 今作った管理者 id の id とステータスを取り出し
    my $new_admin_id     = $insert_admin_row->id;
    my $new_admin_status = $insert_admin_row->status;

    # 承認済み 1 の場合該当の storeinfo のデータを検索
    if ( $new_admin_status eq '1' ) {
        $self->insert_admin_relation($new_admin_id);
    }

    return;
}

sub get_fill_in_registrant {
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

Yoyakku::Model::Mainte::Admin - admin テーブル管理用 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Mainte::Admin version 0.0.1

=head1 SYNOPSIS (概要)

Admin コントローラーのロジック API

=head2 check_auth_admin

    use Yoyakku::Model::Mainte::Admin qw{check_auth_admin};

    # session からログインチェック、ヘッダー用の値を取得
    my $header_stash = check_auth_admin( $self->session->{root_id} );

    # session が不正な場合は undef を返却

ログイン確認

=head2 search_admin_id_rows

    use Yoyakku::Model::Mainte::Admin qw{search_admin_id_rows};

    # 指定の id に該当するレコードを row オブジェクトを配列リファレンスで返却
    my $admin_rows = search_admin_id_rows($admin_id);

    # 指定の id に該当するレコードなき場合 admin 全てのレコード返却

admin テーブル一覧作成時に利用

=head2 get_init_valid_params_admin

    use Yoyakku::Model::Mainte::Admin qw{get_init_valid_params_admin};

    # バリデートエラーメッセージ用パラメーター初期値
    my $init_valid_params_admin = get_init_valid_params_admin();
    $self->stash($init_valid_params_admin);

admin 入力フォーム表示の際に利用

=head2 get_update_form_params_admin

    use Yoyakku::Model::Mainte::Admin qw{get_update_form_params_admin};

    # 修正画面表示用のパラメーターを取得
    return $self->_render_registrant( get_update_form_params_admin($params) )
        if 'GET' eq $method;

admin 修正用入力フォーム表示の際に利用

=head2 check_admin_validator

    use Yoyakku::Model::Mainte::Admin qw{check_admin_validator};

    # バリデート不合格時はエラーメッセージ
    my $valid_msg = check_admin_validator($params);

    # バリデート合格時は undef を返却
    return $self->stash($valid_msg), $self->_render_registrant($params)
        if $valid_msg;

admin 入力値バリデートチェックに利用

=head2 check_admin_validator_db

    use Yoyakku::Model::Mainte::Admin qw{check_admin_validator_db};

    # バリデート不合格時はエラーメッセージ
    my $valid_msg_db = check_admin_validator_db( $type, $params, );

    # バリデート合格時は undef を返却
    return $self->stash($valid_msg_db), $self->_render_registrant($params)
        if $valid_msg_db;

admin 入力値データベースとのバリデートチェックに利用

=head2 writing_admin

    use Yoyakku::Model::Mainte::Admin qw{writing_admin};

    # admin レコード新規
    writing_admin( 'insert', $params );
    $self->flash( touroku => '登録完了' );

    # admin レコード修正
    writing_admin( 'update', $params );
    $self->flash( henkou => '修正完了' );

admin テーブル書込み、新規、修正、両方に対応

=head2 get_fill_in_registrant

    use Yoyakku::Model::Mainte::Admin qw{get_fill_in_registrant};

    # テンプレートの html と出力の params から表示用の html を生成
    my $output = get_fill_in_registrant( \$html, $params );
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
