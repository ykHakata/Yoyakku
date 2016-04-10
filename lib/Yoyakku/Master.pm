package Yoyakku::Master;
use strict;
use warnings;
use utf8;
use Readonly;
use Exporter 'import';
our @EXPORT_OK = qw{
    $SPACE
    $NUMBER_CONVERSION
    $PRIVATE_COND_0 $PRIVATE_COND_1 $PRIVATE_COND_2 $PRIVATE_COND_3
    $PRIVATE_COND_4 $PRIVATE_COND_5 $PRIVATE_COND_6 $PRIVATE_COND_7
    $PRIVATE_COND_8 $PRIVATE_MIT_0 $PRIVATE_MIT_1
    $USEFORM_0 $USEFORM_1 $USEFORM_2
    $WEB_PUBLI_0 $WEB_PUBLI_1
    $WEB_RESERVE_0 $WEB_RESERVE_1 $WEB_RESERVE_2 $WEB_RESERVE_3
    $SELECT_ADMIN_ID $SELECT_GENERAL_ID
    $HOUR_00 $HOUR_01 $HOUR_02 $HOUR_03 $HOUR_04 $HOUR_05
    $HOUR_06 $HOUR_07 $HOUR_08 $HOUR_09 $HOUR_10 $HOUR_11
    $HOUR_12 $HOUR_13 $HOUR_14 $HOUR_15 $HOUR_16 $HOUR_17
    $HOUR_18 $HOUR_19 $HOUR_20 $HOUR_21 $HOUR_22 $HOUR_23
};

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model::Master - 定数表まとめ

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Master version 0.0.1

=head1 SYNOPSIS (概要)

    use Yoyakku::Model::Master qw{$PRIVATE_COND_0 $USEFORM_0};

    warn $PRIVATE_COND_0 # 当日予約

=cut

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

# 時間
Readonly our $HOUR_00 => 0;
Readonly our $HOUR_01 => 1;
Readonly our $HOUR_02 => 2;
Readonly our $HOUR_03 => 3;
Readonly our $HOUR_04 => 4;
Readonly our $HOUR_05 => 5;
Readonly our $HOUR_06 => 6;
Readonly our $HOUR_07 => 7;
Readonly our $HOUR_08 => 8;
Readonly our $HOUR_09 => 9;
Readonly our $HOUR_10 => 10;
Readonly our $HOUR_11 => 11;
Readonly our $HOUR_12 => 12;
Readonly our $HOUR_13 => 13;
Readonly our $HOUR_14 => 14;
Readonly our $HOUR_15 => 15;
Readonly our $HOUR_16 => 16;
Readonly our $HOUR_17 => 17;
Readonly our $HOUR_18 => 18;
Readonly our $HOUR_19 => 19;
Readonly our $HOUR_20 => 20;
Readonly our $HOUR_21 => 21;
Readonly our $HOUR_22 => 22;
Readonly our $HOUR_23 => 23;

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<Readonly>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
