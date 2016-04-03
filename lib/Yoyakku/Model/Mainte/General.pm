package Yoyakku::Model::Mainte::General;
use Mojo::Base 'Yoyakku::Model::Mainte::Base';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Mainte::General - general テーブル管理用 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Mainte::General version 0.0.1

=head1 SYNOPSIS (概要)

    General コントローラーのロジック API

=cut

=head2 check_general_validator_db

    general 入力値データベースとのバリデートチェックに利用

=cut

sub check_general_validator_db {
    my $self   = shift;
    my $params = shift;

    my $valid_msg_general_db = +{};
    my $check_general_msg = $self->check_login_name( 'general', $params );

    if ($check_general_msg) {
        $valid_msg_general_db = +{ login => $check_general_msg };
    }
    return $valid_msg_general_db if $check_general_msg;
    return;
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::Model::Mainte>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
