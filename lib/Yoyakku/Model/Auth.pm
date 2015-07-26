package Yoyakku::Model::Auth;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model';
use Yoyakku::Util qw{get_fill_in_params};

sub check_login {
    my $self = shift;

    return 1
        if $self->session->{session_general_id}
        || $self->session->{session_admin_id};

    return;
}

sub check_logout {
    my $self = shift;

    return 1
        if !$self->session->{session_general_id}
        && !$self->session->{session_admin_id};

    return;
}

sub get_init_valid_params_auth {
    my $self = shift;
    return $self->get_init_valid_params( [qw{login password}] );
}

sub check_root_validator {
    my $self = shift;

    my $check_params = [
        login    => [ 'NOT_NULL', [ EQUAL => 'yoyakku' ] ],
        password => [ 'NOT_NULL', [ EQUAL => '0520' ] ],
    ];

    my $msg_params = [
        'login.not_null'    => '必須入力',
        'password.not_null' => '必須入力',
        'login.equal'       => 'ID違い',
        'password.equal'    => 'password違い',
    ];

    my $msg = $self->get_msg_validator( $check_params, $msg_params, );

    return if !$msg;

    my $valid_msg = +{
        login    => $msg->{login},
        password => $msg->{password},
    };

    return $valid_msg;
}

sub check_auth_validator {
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

    my $valid_msg = +{
        login    => $msg->{login},
        password => $msg->{password},
    };

    return $valid_msg;
}

sub check_auth_validator_db {
    my $self   = shift;
    my $table  = shift;
    my $params = $self->params();
    my $teng   = $self->teng();

    my $valid_msg_db = +{};

    my $row = $teng->single( $table, +{ login => $params->{login} } );

    # 不合格の場合 (DB検証 メルアド違い)
    if ( !$row ) {
        $valid_msg_db->{login} = 'メールアドレス違い';
        return $valid_msg_db;
    }

    # 不合格の場合 (DB検証 パスワード違い)
    if ( $row->password ne $params->{password} ) {
        $valid_msg_db->{password} = 'パスワードが違います';
        return $valid_msg_db;
    }

    my $search_column
        = $table eq 'general' ? 'general_id'
        : $table eq 'admin'   ? 'admin_id'
        :                       '';

    my $profile_row
        = $teng->single( 'profile', +{ $search_column => $row->id } );

    $self->login_row($row);
    $self->profile_row($profile_row);
    return;
}

sub get_session_id_with_routing {
    my $self        = shift;
    my $profile_row = $self->profile_row();

    my $redirect_to = 'profile';
    if ( $profile_row && $profile_row->status ) {
        $redirect_to = 'index';
    }

    my $session_id_with_routing = +{
        session_id  => $self->login_row()->id,
        redirect_to => $redirect_to,
    };

    return $session_id_with_routing;
}

sub get_fill_in_auth {
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

Yoyakku::Model::Auth - ログイン API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Auth version 0.0.1

=head1 SYNOPSIS (概要)

    use Yoyakku::Model::Auth qw{check_valid_login};

    my $check_valid = $self->check_valid_login($table, $params);

    # エラーメッセージ作成
    $self->stash->{login}    = $check_valid->{msg}->{login};
    $self->stash->{password} = $check_valid->{msg}->{password};

    # DB 検索のバリデーションエラー確認
    $check_valid->{error}; # undef or '1'

    # セッション書き込み用 id 提供
    $self->session( $session_name => $check_valid->{session_id} );

    # 検索結果の id の profile 情報の有無を確認、遷移先を指示
    $check_valid_login_routing->{redirect_to} = $check_valid->{check_profile};

    $check_valid->{check_profile}; # 'index' or 'profile'

認証関連の API を提供

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
