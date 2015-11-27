package Yoyakku::Model::Entry;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model';
use Yoyakku::Util qw{now_datetime get_fill_in_params};
use Yoyakku::Master qw{$MAIL_SYSTEM};

=head2 get_header_stash_entry

    ヘッダー初期値取得

=cut

sub get_header_stash_entry {
    my $self = shift;
    my $switch_header = 2;
    return $self->get_header_stash_params( $switch_header );
}

=head2 check_entry_validator

    入力値バリデートチェックに利用

=cut

sub check_entry_validator {
    my $self = shift;

    my $check_params = [
        mail_j   => [ 'NOT_NULL', 'EMAIL_LOOSE' ],
    ];

    my $msg_params = [
        'mail_j.email_loose' => 'Eメールを入力してください',
        'mail_j.not_null'    => '必須入力',
    ];

    my $msg = $self->get_msg_validator( $check_params, $msg_params, );

    return if !$msg;

    return +{ mail_j => $msg->{mail_j}, };
}

=head2 check_entry_validator_db

    入力値データベースとのバリデートチェックに利用

=cut

sub check_entry_validator_db {
    my $self = shift;

    # ログインid(メルアド)存在確認 admin, general, 両方
    my $check_params = +{
        column => 'login',
        param  => $self->params()->{mail_j},
        table  => $self->params()->{select_usr},
    };
    my $check_entry = $self->check_table_column($check_params);
    my $valid_msg_db = +{ mail_j => $check_entry };
    return $valid_msg_db if $check_entry;
    return;
}

=head2 writing_entry

    テーブル書込み、新規、修正、両方に対応

=cut

sub writing_entry {
    my $self = shift;

    my $auth_table = $self->params()->{select_usr};

    my $create_auth_data = +{
        login     => $self->params()->{mail_j},
        password  => 'yoyakku',
        status    => 0,
        create_on => now_datetime(),
        modify_on => now_datetime(),
    };

    # admin or general への新規作成
    my $insert_row = $self->writing_db( $auth_table, $create_auth_data, );

    # 該当する profile の新規作成
    my $create_profile_data = +{
        general_id    => undef,
        admin_id      => undef,
        nick_name     => $self->params()->{mail_j},
        full_name     => '',
        phonetic_name => '',
        tel           => '',
        mail          => $self->params()->{mail_j},
        status        => 0,
        create_on     => now_datetime(),
        modify_on     => now_datetime(),
    };

    # 登録完了メール
    my $mail_temp_entry = +{
        admin_nick_name   => '',
        general_nick_name => '',
        general_mail      => '',
        admin_mail        => '',
    };

    if ( $auth_table eq 'admin' ) {
        $create_profile_data->{admin_id}    = $insert_row->id;
        $mail_temp_entry->{admin_nick_name} = $self->params()->{mail_j};
        $mail_temp_entry->{admin_mail}      = $self->params()->{mail_j};
    }
    elsif ( $auth_table eq 'general' ) {
        $create_profile_data->{general_id}    = $insert_row->id;
        $mail_temp_entry->{general_nick_name} = $self->params()->{mail_j};
        $mail_temp_entry->{general_mail}      = $self->params()->{mail_j};
    }
    else {
        die 'not insert_id!';
    }

    $self->writing_db( 'profile', $create_profile_data, );
    $self->mail_temp($mail_temp_entry);

    my $mail_header_entry = +{
        from    => $MAIL_SYSTEM,
        to      => $self->params()->{mail_j},
        subject => '[yoyakku]ID登録完了のお知らせ【' . now_datetime() . '】',
    };

    $self->mail_header($mail_header_entry);
    return;
}

=head2 get_fill_in_entry

    表示用 html を生成

=cut

sub get_fill_in_entry {
    my $self   = shift;
    my $html   = $self->html();
    my $params = $self->params();
    my $output = get_fill_in_params( $html, $params );
    return $output;
}

1;

__END__
