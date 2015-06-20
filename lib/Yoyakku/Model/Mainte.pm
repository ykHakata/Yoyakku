package Yoyakku::Model::Mainte;
use strict;
use warnings;
use utf8;
use Time::Piece;
use FormValidator::Lite;
use Yoyakku::Util qw{switch_header_params};
use Yoyakku::Model qw{$teng};
use Exporter 'import';
our @EXPORT_OK = qw{
    switch_stash_mainte_list
    search_id_single_or_all_rows
    get_single_row_search_id
    writing_db
    get_update_form_params
    get_msg_validator
};

# 入力値バリデート処理
sub get_msg_validator {
    my $params       = shift;
    my $check_params = shift;
    my $msg_params   = shift;

    my $validator = FormValidator::Lite->new($params);

    $validator->check( @{$check_params} );
    $validator->set_message( @{$msg_params} );

    my $error_params = [ map {$_} keys %{ $validator->errors() } ];

    my $msg = +{};
    for my $error_param ( @{$error_params} ) {
        $msg->{$error_param}
            = $validator->get_error_messages_from_param($error_param);
        $msg->{$error_param} = shift @{ $msg->{$error_param} };
    }

    return $msg if $validator->has_error();
    return;
}

# update 用フィルインパラメーター作成
sub get_update_form_params {
    my $params  = shift;
    my $table   = shift;
    my $columns = shift;

    my $row = get_single_row_search_id( $table, $params->{id} );

    for my $param ( @{$columns} ) {
        $params->{$param} = $row->$param;
    }
    return $params;
}

# データベースへの書き込み
sub writing_db {
    my $table     = shift;
    my $type      = shift;
    my $params    = shift;
    my $update_id = shift;

    my $insert_row;

    if ( $type eq 'insert' ) {

        $insert_row = $teng->insert( $table, $params, );

    }
    elsif ( $type eq 'update' ) {

        $insert_row = $teng->single( $table, +{ id => $update_id }, );

        $insert_row->update($params);
    }

    die 'not $insert_row' if !$insert_row;

    return;
}

# レコード更新の為の情報取得
sub get_single_row_search_id {
    my $table     = shift;
    my $search_id = shift;

    my $row = $teng->single( $table, +{ id => $search_id, }, );

    die 'not row!!' if !$row;

    return $row;
}

# テーブル一覧表示の為の検索
sub search_id_single_or_all_rows {
    my $table     = shift;
    my $search_id = shift;

    my @rows;

    if ( defined $search_id ) {
        @rows = $teng->search( $table, +{ id => $search_id, }, );
        if ( !scalar @rows ) {

            # id 検索しないときはテーブルの全てを出力
            @rows = $teng->search( $table, +{}, );
        }
    }
    else {
        # id 検索しないときはテーブルの全てを出力
        @rows = $teng->search( $table, +{}, );
    }

    return \@rows;
}

# ログイン成功時に作成する初期値
sub switch_stash_mainte_list {
    my $id    = shift;
    my $table = shift;

    # id table ないとき強制終了
    die 'not id table!: ' if !$id || !$table;

    # ヘッダー表示用の名前
    my $login_name = $id;

    # ヘッダーの切替(システム管理者用)
    my $switch_header = 1;

    my $header_params = switch_header_params( $switch_header, $login_name );

    my $header_params_hash_ref = +{
        site_title_link        => $header_params->{site_title_link},
        header_heading_link    => $header_params->{header_heading_link},
        header_heading_name    => $header_params->{header_heading_name},
        header_navi_class_name => $header_params->{header_navi_class_name},
        header_navi_link_name  => $header_params->{header_navi_link_name},
        header_navi_row_name   => $header_params->{header_navi_row_name},
    };

    # Time::Piece オブジェクト
    my $today = localtime;

    my $stash_mainte = +{
        login_data => +{    # 初期値表示のため
            today => $today,    # アクセス時刻表示
        },
        %{$header_params_hash_ref},    # ヘッダー各値
    };

    return $stash_mainte;
}

1;

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model::Mainte - システム管理者用 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Mainte version 0.0.1

=head1 SYNOPSIS (概要)

Mainte コントローラーのロジック API

=head2 switch_stash_mainte_list

    use Yoyakku::Model::Mainte qw{switch_stash_mainte_list};

    # スタッシュに引き渡す値を作成
    my $stash_mainte = switch_stash_mainte_list( $id, $table, );

    $self->stash($stash_mainte);

Mainte アクションログイン時の初期値作成

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<Time::Piece>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
