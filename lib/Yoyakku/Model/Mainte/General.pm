package Yoyakku::Model::Mainte::General;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model::Mainte';

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

=head2 writing_general

    general テーブル書込み、新規、修正、両方に対応

=cut

sub writing_general {
    my $self   = shift;
    my $params = shift;
    my $type   = shift;

    my $create_data = $self->get_create_data( 'general', $params );

    my $args = +{
        table       => 'general',
        create_data => $create_data,
        update_id   => $params->{id},
        type        => $type,
    };
    return $self->writing_from_db($args);
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

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
