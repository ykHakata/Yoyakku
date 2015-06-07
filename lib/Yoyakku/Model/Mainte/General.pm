package Yoyakku::Model::Mainte::General;
use strict;
use warnings;
use utf8;
use Yoyakku::Model qw{$teng};
use Yoyakku::Model::Mainte qw{
    search_id_single_or_all_rows
    get_single_row_search_id
    writing_db
};
use Yoyakku::Util qw{now_datetime};
use Exporter 'import';
our @EXPORT_OK = qw{
    search_general_id_rows
    search_general_id_row
    check_general_login_name
    writing_general
};

sub check_general_login_name {
    my $self  = shift;
    my $login = shift;

    my $general_row = $teng->single( 'general', +{ login => $login, }, );

    return $general_row;
}

sub search_general_id_rows {
    my $self       = shift;
    my $general_id = shift;

    return search_id_single_or_all_rows( 'general', $general_id );
}

sub search_general_id_row {
    my $self       = shift;
    my $general_id = shift;

   return get_single_row_search_id( 'general', $general_id );
}

sub writing_general {
    my $self   = shift;
    my $type   = shift;
    my $params = shift;

    my $create_data = +{
        login     => $params->{login},
        password  => $params->{password},
        status    => $params->{status},
        create_on => now_datetime(),
        modify_on => now_datetime(),
    };

    return writing_db( 'general', $type, $create_data, $params->{id} );
}

1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model::Mainte::General - general テーブル管理用 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Mainte::General version 0.0.1

=head1 SYNOPSIS (概要)

General コントローラーのロジック API

=head2 check_general_login_name

    use Yoyakku::Model::Mainte::General qw{check_general_login_name};

    # login の値、存在確認、存在しない場合は undef を返却
    my $check_general_row
        = $self->check_general_login_name( $req->param('login') );

login の値の重複登録をさけるために利用

=head2 search_general_id_rows

    use Yoyakku::Model::Mainte::General qw{search_general_id_rows};

    # 指定の id に該当するレコードを row オブジェクトを配列リファレンスで返却
    my $general_rows = $self->search_general_id_rows($general_id);

    # 指定の id に該当するレコードなき場合 general 全てのレコード返却

general テーブル一覧作成時に利用

=head2 search_general_id_row

    use Yoyakku::Model::Mainte::General qw{search_general_id_row};

    # 指定の id に該当するレコードを row オブジェクト単体で返却
    my $general_row = $self->search_general_id_row( $params->{id} );

    # 指定の id に該当するレコードなき場合エラー発生

general テーブル修正フォーム表示などに利用

=head2 writing_general

    use Yoyakku::Model::Mainte::General qw{writing_general};

    # general テーブル新規レコード作成時
    $self->writing_general( 'insert', $params );
    $self->flash( touroku => '登録完了' );

    # general テーブルレコード修正時
    $self->writing_general( 'update', $params );
    $self->flash( henkou => '修正完了' );

general テーブル書込み、新規、修正、両方に対応

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
