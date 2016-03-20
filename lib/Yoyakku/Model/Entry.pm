package Yoyakku::Model::Entry;
use Mojo::Base 'Yoyakku::Model';
use Yoyakku::Util qw{now_datetime};
use Yoyakku::Master qw{$MAIL_SYSTEM};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Entry - 登録 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Entry version 0.0.1

=head1 SYNOPSIS (概要)

    Entry コントローラーのロジック API

=cut

=head2 get_header_stash_entry

    ヘッダー初期値取得

=cut

sub get_header_stash_entry {
    my $self = shift;
    my $switch_header = 2;
    return $self->get_header_stash_params( $switch_header );
}

=head2 check_entry_validator_db

    入力値データベースとのバリデートチェックに利用

=cut

sub check_entry_validator_db {
    my $self   = shift;
    my $params = shift;

    # ログインid(メルアド)存在確認 admin, general, 両方
    my $check_params = +{
        column => 'login',
        param  => $params->{mail_j},
        table  => $params->{select_usr},
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
    my $self   = shift;
    my $params = shift;
    my $type   = shift;

    my $auth_table = $params->{select_usr};

    my $create_auth_data = +{
        login     => $params->{mail_j},
        password  => 'yoyakku',
        status    => 0,
        create_on => now_datetime(),
        modify_on => now_datetime(),
    };

    my $args = +{
        table       => $auth_table,
        create_data => $create_auth_data,
        update_id   => undef,
        type        => $type,
    };

    # admin or general への新規作成
    my $insert_row = $self->writing_from_db($args);

    # 該当する profile の新規作成
    my $create_profile_data = +{
        general_id    => undef,
        admin_id      => undef,
        nick_name     => $params->{mail_j},
        full_name     => '',
        phonetic_name => '',
        tel           => '',
        mail          => $params->{mail_j},
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
        $mail_temp_entry->{admin_nick_name} = $params->{mail_j};
        $mail_temp_entry->{admin_mail}      = $params->{mail_j};
    }
    elsif ( $auth_table eq 'general' ) {
        $create_profile_data->{general_id}    = $insert_row->id;
        $mail_temp_entry->{general_nick_name} = $params->{mail_j};
        $mail_temp_entry->{general_mail}      = $params->{mail_j};
    }
    else {
        die 'not insert_id!';
    }

    $args = +{
        table       => 'profile',
        create_data => $create_profile_data,
        update_id   => undef,
        type        => $type,
    };

    $self->writing_from_db($args);
    $self->mail_temp($mail_temp_entry);

    my $mail_header_entry = +{
        from    => $MAIL_SYSTEM,
        to      => $params->{mail_j},
        subject => '[yoyakku]ID登録完了のお知らせ【' . now_datetime() . '】',
    };

    $self->mail_header($mail_header_entry);
    return;
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::Model>

=item * L<Yoyakku::Util>

=item * L<Yoyakku::Master>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
