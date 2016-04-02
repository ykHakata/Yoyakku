package Yoyakku::Model::Auth;
use Mojo::Base 'Yoyakku::Model::Base';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Auth - ログイン API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Auth version 0.0.1

=head1 SYNOPSIS (概要)

    認証関連の API を提供

=cut

=head2 logged_in

    セッション確認によるログイン機能

=cut

sub logged_in {
    my $self    = shift;
    my $session = shift;
    return   if !$session;
    return 1 if $session->{session_admin_id};
    return 1 if $session->{session_general_id};
    return 2 if $session->{root_id};
    return;
}

=head2 get_logged_in_row

    セッション確認からログイン情報取得

=cut

sub get_logged_in_row {
    my $self      = shift;
    my $session   = shift;
    my $logged_in = $self->logged_in($session);

    return if !$logged_in;

    my $teng       = $self->app->model->db->base->teng();
    my $admin_id   = $session->{session_admin_id};
    my $general_id = $session->{session_general_id};

    return if !$admin_id && !$general_id;

    my $table = 'admin';
    my $id    = $admin_id;

    if ($general_id) {
        $table = 'general';
        $id    = $general_id;
    }

    my $login_row = $teng->single( $table, +{ id => $id } );

    return if !$login_row;
    return $login_row;
}

=head2 login

    テキスト入力フォームによるログイン機能

=cut

sub login {
    my $self = shift;
    my $args = shift;
    my $teng = $self->app->model->db->base->teng();
    my $row  = $teng->single( $args->{table}, +{ login => $args->{login} } );

    # 不合格の場合 (DB検証 メルアド違い)
    return 1 if !$row;

    # 不合格の場合 (DB検証 パスワード違い)
    return 2 if $row->password ne $args->{password};
    return $row;
}

sub check_auth_validator_db {
    my $self   = shift;
    my $table  = shift;
    my $params = shift;

    my $valid_msg_db = +{};

    my $args = +{
        table => $table,
        %{$params},
    };

    my $row = $self->login($args);

    # 不合格の場合 (DB検証 メルアド違い)
    if ( ref $row eq '' && $row eq 1) {
        $valid_msg_db->{login} = 'メールアドレス違い';
        return $valid_msg_db;
    }

    # 不合格の場合 (DB検証 パスワード違い)
    if ( ref $row eq '' && $row eq 2) {
        $valid_msg_db->{password} = 'パスワードが違います';
        return $valid_msg_db;
    }

    my $search_column
        = $table eq 'general' ? 'general_id'
        : $table eq 'admin'   ? 'admin_id'
        :                       '';

    return;
}

sub get_session_id_with_routing {
    my $self   = shift;
    my $table  = shift;
    my $params = shift;

    my $args = +{
        table => $table,
        %{$params},
    };

    my $login_row   = $self->login($args);
    my $profile_row = $login_row->fetch_profile();

    my $redirect_to = 'profile';
    if ( $profile_row && $profile_row->status && $login_row->status ) {
        $redirect_to = 'index';
    }

    my $session_id_with_routing = +{
        session_id  => $login_row->id,
        redirect_to => $redirect_to,
    };

    return $session_id_with_routing;
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::Model>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
