package Yoyakku::Model::Mainte::Profile;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model::Mainte';
use Yoyakku::Util qw{now_datetime get_fill_in_params};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Mainte::Profile - Profile テーブル管理用 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Mainte::Profile version 0.0.1

=head1 SYNOPSIS (概要)

    Profile コントローラーのロジック API

=cut

=head2 search_profile_id_rows

    profile テーブル一覧作成時に利用

=cut

sub search_profile_id_rows {
    my $self = shift;
    return $self->search_id_single_or_all_rows( 'profile',
        $self->params()->{profile_id} );
}

=head2 get_init_valid_params_profile

    profile 入力フォーム表示の際に利用

=cut

sub get_init_valid_params_profile {
    my $self = shift;
    return $self->get_init_valid_params(
        [qw{general_id admin_id nick_name full_name phonetic_name tel mail}]
    );
}

=head2 get_update_form_params_profile

    profile 修正用入力フォーム表示の際に利用

=cut

sub get_update_form_params_profile {
    my $self = shift;
    $self->get_update_form_params('profile');
    return $self;
}

=head2 get_general_rows_all

    profile 入力画面セレクト用のログイン名表示

=cut

sub get_general_rows_all {
    my $self = shift;
    my $teng = $self->teng();
    my @general_rows = $teng->search( 'general', +{}, );
    return \@general_rows;
}

=head2 get_admin_rows_all

    profile 入力画面セレクト用のログイン名表示

=cut

sub get_admin_rows_all {
    my $self = shift;
    my $teng = $self->teng();
    my @admin_rows = $teng->search( 'admin', +{}, );
    return \@admin_rows;
}

=head2 check_profile_validator

    profile 入力値バリデートチェックに利用

=cut

sub check_profile_validator {
    my $self = shift;

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
        'general_id.not_null' => '指定の形式で入力してください',
        'admin_id.not_null'   => '指定の形式で入力してください',
        'nick_name.length'    => '文字数!!',
        'full_name.length'    => '文字数!!',
        'phonetic_name.length' => '文字数!!',
        'tel.length'           => '文字数!!',
        'mail.email_loose'     => 'Eメールを入力してください',
    ];

    my $msg = $self->get_msg_validator( $check_params, $msg_params, );

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

=head2 check_profile_validator_db

    profile 入力値データベースとのバリデートチェックに利用

=cut

sub check_profile_validator_db {
    my $self = shift;

    my $valid_msg_profile_db = +{};

    # general_id, admin_id, 重複、既存の確認
    my $check_admin_and_general_msg = $self->_check_admin_and_general_id();

    if ($check_admin_and_general_msg) {
        $valid_msg_profile_db
            = +{ general_id => $check_admin_and_general_msg };
    }

    return $valid_msg_profile_db if $check_admin_and_general_msg;
    return;
}

sub _check_admin_and_general_id {
    my $self   = shift;
    my $params = $self->params();

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
    return $self->check_table_column($check_params) if $admin_id;

    $check_params->{column} = 'general_id';
    $check_params->{param}  = $general_id;

    # 一般ユーザー
    return $self->check_table_column($check_params) if $general_id;
}

=head2 writing_profile

    profile テーブル書込み、新規、修正、両方に対応

=cut

sub writing_profile {
    my $self = shift;

    my $create_data = +{
        general_id => $self->params()->{general_id} || undef,
        admin_id   => $self->params()->{admin_id}   || undef,
        nick_name  => $self->params()->{nick_name},
        full_name  => $self->params()->{full_name},
        phonetic_name => $self->params()->{phonetic_name},
        tel           => $self->params()->{tel},
        mail          => $self->params()->{mail},
        status        => $self->params()->{status},
        create_on     => now_datetime(),
        modify_on     => now_datetime(),
    };
    return $self->writing_db( 'profile', $create_data,
        $self->params()->{id} );
}

=head2 get_fill_in_profile

    表示用 html を生成

=cut

sub get_fill_in_profile {
    my $self   = shift;
    my $html   = $self->html();
    my $params = $self->params();
    my $output = get_fill_in_params( $html, $params );
    return $output;
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<parent>

=item * L<Yoyakku::Model::Mainte>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
