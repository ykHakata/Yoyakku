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
