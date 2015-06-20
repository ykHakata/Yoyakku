package Yoyakku::Model::Mainte::Profile;
use strict;
use warnings;
use utf8;
use Yoyakku::Model qw{$teng};
use Yoyakku::Model::Mainte qw{
    search_id_single_or_all_rows
    get_init_valid_params
    get_update_form_params
    get_msg_validator
    writing_db
};
use Yoyakku::Util qw{now_datetime};
use Exporter 'import';
our @EXPORT_OK = qw{
    search_profile_id_rows
    get_init_valid_params_profile
    get_update_form_params_profile
    get_general_rows_all
    get_admin_rows_all
    check_profile_validator
    check_profile_validator_db
    writing_profile
};

sub search_profile_id_rows {
    my $profile_id = shift;
    return search_id_single_or_all_rows( 'profile', $profile_id );
}

sub get_init_valid_params_profile {
    my $valid_params
        = [
        qw{general_id admin_id nick_name full_name phonetic_name tel mail}];
    return get_init_valid_params($valid_params);
}

sub get_update_form_params_profile {
    my $params = shift;
    $params = get_update_form_params( $params, 'profile', );
    return $params;
}

sub get_general_rows_all {
    my @general_rows = $teng->search( 'general', +{}, );
    return \@general_rows;
}

sub get_admin_rows_all {
    my @admin_rows = $teng->search( 'admin', +{}, );
    return \@admin_rows;
}

sub check_profile_validator {
    my $params = shift;

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
    my $type   = shift;
    my $params = shift;

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

    my $check_profile_row;

    if ($admin_id) {
        $check_profile_row
            = $teng->single( 'profile', +{ admin_id => $admin_id }, );
    }

    if ($general_id) {
        $check_profile_row
            = $teng->single( 'profile', +{ general_id => $general_id }, );
    }

    # 新規
    return '既に利用されています'
        if $check_profile_row && !$profile_id;

    # 更新
    return '既に利用されています'
        if $check_profile_row
        && $profile_id
        && ( $profile_id ne $check_profile_row->id );

    return;
}

sub writing_profile {
    my $type   = shift;
    my $params = shift;

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

1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model::Mainte::Profile - Profile テーブル管理用 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Mainte::Profile version 0.0.1

=head1 SYNOPSIS (概要)

Profile コントローラーのロジック API

=head2 get_general_rows_all

    # 入力画面セレクト用の general ログイン名表示
    $self->stash(
        general_rows => $self->get_general_rows_all(),
    );

general テーブルの全てのレコードを row オブジェクトで返却

=head2 get_admin_rows_all

    # 入力画面セレクト用の admin ログイン名表示
    $self->stash(
        admin_rows => $self->get_admin_rows_all(),
    );

admin テーブルの全てのレコードを row オブジェクトで返却

=head2 check_admin_and_general_id

    use Yoyakku::Model::Mainte::Profile qw{check_admin_and_general_id};

    # general_id, admin_id, 重複、既存の確認
    my $check_admin_and_general_msg = $self->check_admin_and_general_id(
        $params->{general_id},
        $params->{admin_id},
        $params->{id},
    );

    # 入力値が重複や DB に既存の場合はメッセージ出力
    # 合格時は undef を返却

    if ($check_admin_and_general_msg) { # '既に利用されています'

        $self->stash->{general_id} = $check_admin_and_general_msg;

        return $self->_render_profile($params);
    }

profile テーブルに general_id, admin_id, 重複、既存の確認

=head2 search_profile_id_rows

    use Yoyakku::Model::Mainte::Profile qw{search_profile_id_rows};

    # 指定の id に該当するレコードを row オブジェクトを配列リファレンスで返却
    my $profile_rows = $self->search_profile_id_rows($profile_id);

    # 指定の id に該当するレコードなき場合 profile 全てのレコード返却

profile テーブル一覧作成時に利用

=head2 search_profile_id_row

    use Yoyakku::Model::Mainte::Profile qw{search_profile_id_row};

    # 指定の id に該当するレコードを row オブジェクト単体で返却
    my $profile_row = $self->search_profile_id_row( $params->{id} );

    # 指定の id に該当するレコードなき場合エラー発生

profile テーブル修正フォーム表示などに利用

=head2 writing_profile

    use Yoyakku::Model::Mainte::Profile qw{writing_profile};

    # profile テーブル新規レコード作成時
    $self->writing_profile( 'insert', $params );
    $self->flash( touroku => '登録完了' );

    # profile テーブルレコード修正時
    $self->writing_profile( 'update', $params );
    $self->flash( henkou => '修正完了' );

profile テーブル書込み、新規、修正、両方に対応

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
