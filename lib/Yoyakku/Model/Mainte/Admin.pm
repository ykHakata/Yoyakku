package Yoyakku::Model::Mainte::Admin;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model::Mainte';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Mainte::Admin - admin テーブル管理用 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Mainte::Admin version 0.0.1

=head1 SYNOPSIS (概要)

    Admin コントローラーのロジック API

=cut

=head2 check_admin_validator_db

    admin 入力値データベースとのバリデートチェックに利用

=cut

sub check_admin_validator_db {
    my $self   = shift;
    my $params = shift;

    my $valid_msg_admin_db = +{};
    my $check_admin_msg = $self->check_login_name( 'admin', $params );

    if ($check_admin_msg) {
        $valid_msg_admin_db = +{ login => $check_admin_msg };
    }
    return $valid_msg_admin_db if $check_admin_msg;
    return;
}

=head2 writing_admin

    admin テーブル書込み、新規、修正、両方に対応

=cut

sub writing_admin {
    my $self   = shift;
    my $params = shift;
    my $type   = shift;

    my $create_data = $self->get_create_data( 'admin', $params );

    my $args = +{
        table       => 'admin',
        create_data => $create_data,
        update_id   => $params->{id},
        type        => $type,
    };

    my $insert_admin_row = $self->writing_from_db($args);

    die 'not $insert_admin_row' if !$insert_admin_row;

    # status: (0: 未承認, 1: 承認済み, 2: 削除済み)
    # 今作った管理者IDでステータスが1 (承認済み) で
    # storeinfo に今作った管理者 id が存在しないときは、
    # 新たに storeinfo にデータ作成し、
    # 今作った管理者 id を入力しておく
    # 作成時刻が一番新しい管理者 id を取得する
    # 今作った管理者 id の id とステータスを取り出し
    my $new_admin_id     = $insert_admin_row->id;
    my $new_admin_status = $insert_admin_row->status;

    # 承認済み 1 の場合該当の storeinfo のデータを検索
    if ( $new_admin_status eq '1' ) {
        $self->insert_admin_relation($new_admin_id);
    }

    return;
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
