package Yoyakku::Model::Master;

use strict;
use warnings;
use utf8;
use Readonly;
use Exporter 'import';
our @EXPORT_OK = qw{
    $SPACE
    $NUMBER_CONVERSION
    $PRIVATE_COND_0
    $PRIVATE_COND_1
    $PRIVATE_COND_2
    $PRIVATE_COND_3
    $PRIVATE_COND_4
    $PRIVATE_COND_5
    $PRIVATE_COND_6
    $PRIVATE_COND_7
    $PRIVATE_COND_8
    $PRIVATE_MIT_0
    $PRIVATE_MIT_1
    $USEFORM_0
    $USEFORM_1
    $USEFORM_2
    $WEB_PUBLI_0
    $WEB_PUBLI_1
    $WEB_RESERVE_0
    $WEB_RESERVE_1
    $WEB_RESERVE_2
    $WEB_RESERVE_3
    $SELECT_ADMIN_ID
    $SELECT_GENERAL_ID
    $WEB_RESERVE
};

Readonly our $SPACE             => q{ };
Readonly our $NUMBER_CONVERSION => 0;
Readonly our $PRIVATE_COND_0    => '当日予約';
Readonly our $PRIVATE_COND_1    => '１日前';
Readonly our $PRIVATE_COND_2    => '２日前';
Readonly our $PRIVATE_COND_3    => '３日前';
Readonly our $PRIVATE_COND_4    => '４日前';
Readonly our $PRIVATE_COND_5    => '５日前';
Readonly our $PRIVATE_COND_6    => '６日前';
Readonly our $PRIVATE_COND_7    => '７日前';
Readonly our $PRIVATE_COND_8    => '条件なし';
Readonly our $PRIVATE_MIT_0     => '○';
Readonly our $PRIVATE_MIT_1     => '×';
Readonly our $USEFORM_0         => 'バンド';
Readonly our $USEFORM_1         => '個人';
Readonly our $USEFORM_2         => '利用停止';
Readonly our $WEB_PUBLI_0       => '公開する';
Readonly our $WEB_PUBLI_1       => '公開しない';
Readonly our $WEB_RESERVE_0     => '今月のみ';
Readonly our $WEB_RESERVE_1     => '１ヶ月先';
Readonly our $WEB_RESERVE_2     => '２ヶ月先';
Readonly our $WEB_RESERVE_3     => '３ヶ月先';
Readonly our $SELECT_ADMIN_ID   => 72;
Readonly our $SELECT_GENERAL_ID => 1;

1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model::Master - 定数表まとめ

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Master version 0.0.1

=head1 SYNOPSIS (概要)

    use Yoyakku::Model::Master qw{$PRIVATE_COND_0 $USEFORM_0};

    warn $PRIVATE_COND_0 # 当日予約

=head1 DEPENDENCIES (依存モジュール)

=over 2

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<Readonly>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Yoyakku::Guides>
