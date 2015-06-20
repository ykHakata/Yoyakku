package Yoyakku::Model::Mainte::General;
use strict;
use warnings;
use utf8;
use Yoyakku::Model qw{$teng};
use Yoyakku::Model::Mainte qw{
    search_id_single_or_all_rows
    get_init_valid_params
    get_update_form_params
    get_msg_validator
    check_login_name
    writing_db
};
use Yoyakku::Util qw{now_datetime};
use Exporter 'import';
our @EXPORT_OK = qw{
    search_general_id_rows
    get_init_valid_params_general
    get_update_form_params_general
    check_general_validator
    check_general_validator_db
    writing_general
};

sub search_general_id_rows {
    my $general_id = shift;
    return search_id_single_or_all_rows( 'general', $general_id );
}

sub get_init_valid_params_general {
    my $valid_params = [qw{login password}];
    return get_init_valid_params($valid_params);
}

sub get_update_form_params_general {
    my $params = shift;
    $params = get_update_form_params( $params, 'general', );
    return $params;
}

sub check_general_validator {
    my $params = shift;

    my $check_params = [
        login    => [ 'NOT_NULL', ],
        password => [ 'NOT_NULL', ],
    ];

    my $msg_params = [
        'login.not_null'    => '必須入力',
        'password.not_null' => '必須入力',
    ];

    my $msg = get_msg_validator( $params, $check_params, $msg_params, );

    return if !$msg;

    my $valid_msg_general = +{
        login    => $msg->{login},
        password => $msg->{password},
    };

    return $valid_msg_general;
}

sub check_general_validator_db {
    my $type   = shift;
    my $params = shift;

    my $valid_msg_general_db = +{};
    my $check_general_msg = check_login_name( $params, 'general', );

    if ($check_general_msg) {
        $valid_msg_general_db = +{ login => $check_general_msg };
    }
    return $valid_msg_general_db if $check_general_msg;
    return;
}

sub writing_general {
    my $type   = shift;
    my $params = shift;

    my $create_data = +{
        login     => $params->{login},
        password  => $params->{password},
        status    => $params->{status},
        create_on => now_datetime(),
        modify_on => now_datetime(),
    };
    return writing_db( 'general', $type, $create_data, $params->{id} );
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

=head2 check_general_login_name

    use Yoyakku::Model::Mainte::General qw{check_general_login_name};

    # login の値、存在確認、存在しない場合は undef を返却
    my $check_general_row
        = $self->check_general_login_name( $req->param('login') );

login の値の重複登録をさけるために利用

=head2 search_general_id_rows

    use Yoyakku::Model::Mainte::General qw{search_general_id_rows};

    # 指定の id に該当するレコードを row オブジェクトを配列リファレンスで返却
    my $general_rows = $self->search_general_id_rows($general_id);

    # 指定の id に該当するレコードなき場合 general 全てのレコード返却

general テーブル一覧作成時に利用

=head2 search_general_id_row

    use Yoyakku::Model::Mainte::General qw{search_general_id_row};

    # 指定の id に該当するレコードを row オブジェクト単体で返却
    my $general_row = $self->search_general_id_row( $params->{id} );

    # 指定の id に該当するレコードなき場合エラー発生

general テーブル修正フォーム表示などに利用

=head2 writing_general

    use Yoyakku::Model::Mainte::General qw{writing_general};

    # general テーブル新規レコード作成時
    $self->writing_general( 'insert', $params );
    $self->flash( touroku => '登録完了' );

    # general テーブルレコード修正時
    $self->writing_general( 'update', $params );
    $self->flash( henkou => '修正完了' );

general テーブル書込み、新規、修正、両方に対応

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
