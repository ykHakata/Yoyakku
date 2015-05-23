package Yoyakku::Model;
use strict;
use warnings;
use utf8;
use Teng::Schema::Loader;
use Exporter 'import';
our @EXPORT_OK = qw{
    $teng
};

our $teng = Teng::Schema::Loader->load(
    connect_info => [ 'dbi:SQLite:./db/yoyakku.db', '', '' ],
    namespace    => 'yoyakku_table',
);

1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model - データベース関連 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model version 0.0.1

=head1 SYNOPSIS (概要)

    use Yoyakku::Model qw{$teng};

    # 指定のテーブルから該当のレコードを１件取得 row オブジェクト変換
    my $row = $teng->single( $table, +{ login => $params->{login} } );

    # teng 関連のメソッドは teng ドキュメント参照

データベース接続関連の API を提供

=head1 DEPENDENCIES (依存モジュール)

=over 2

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<Teng::Schema::Loader>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Yoyakku::Guides>
