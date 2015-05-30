package Yoyakku::Model::Mainte;
use strict;
use warnings;
use utf8;
use Time::Piece;
use Yoyakku::Util qw{switch_header_params};
use Exporter 'import';
our @EXPORT_OK = qw{
    switch_stash_mainte_list
};

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

=over 2

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<Time::Piece>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Yoyakku::Guides>

=cut
