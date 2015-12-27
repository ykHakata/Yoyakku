package Yoyakku::Model::Setting::Roominfo;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model::Setting';
use Yoyakku::Util qw{get_fill_in_params chenge_time_over};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Setting::Roominfo - 店舗管理 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Setting::Roominfo version 0.0.1

=head1 SYNOPSIS (概要)

    Setting::Roominfo コントローラーのロジック API

=cut

=head2 get_login_roominfo_ids

    ログイン id から roominfo の id 取得

=cut

sub get_login_roominfo_ids {
    my $self = shift;
    my $rows = $self->login_roominfo_rows();
    my $ids  = [ map { $_->id } @{$rows} ];
    $self->params( +{ id => $ids }, );
    return $ids;
}

=head2 get_init_valid_params_admin_reserv_edit

    バリデート用パラメータ初期値(admin_reserv_edit)

=cut

sub get_init_valid_params_admin_reserv_edit {
    my $self = shift;
    return $self->get_init_valid_params(
        [qw{name endingtime_on rentalunit pricescomments}] );
}

=head2 set_roominfo_params

    予約情報設定のためのパラメーター取得

=cut

sub set_roominfo_params {
    my $self = shift;
    my $rows = $self->login_roominfo_rows();

    my $roominfo_ref = +{};
    for my $row ( @{$rows} ) {
        my $change_time = chenge_time_over(
            +{  start_time => $row->starttime_on,
                end_time   => $row->endingtime_on,
            },
        );
        push @{ $roominfo_ref->{id} },             $row->id;
        push @{ $roominfo_ref->{name} },           $row->name;
        push @{ $roominfo_ref->{starttime_on} },   $change_time->{start_hour};
        push @{ $roominfo_ref->{endingtime_on} },  $change_time->{end_hour};
        push @{ $roominfo_ref->{time_change} },    $row->time_change;
        push @{ $roominfo_ref->{rentalunit} },     $row->rentalunit;
        push @{ $roominfo_ref->{pricescomments} }, $row->pricescomments;
        push @{ $roominfo_ref->{privatepermit} },  $row->privatepermit;
        push @{ $roominfo_ref->{privatepeople} },  $row->privatepeople;
        push @{ $roominfo_ref->{privateconditions} }, $row->privateconditions;
    }

    $self->params(
        +{  id                => $roominfo_ref->{id},
            name              => $roominfo_ref->{name},
            starttime_on      => $roominfo_ref->{starttime_on},
            endingtime_on     => $roominfo_ref->{endingtime_on},
            time_change       => $roominfo_ref->{time_change},
            rentalunit        => $roominfo_ref->{rentalunit},
            pricescomments    => $roominfo_ref->{pricescomments},
            privatepermit     => $roominfo_ref->{privatepermit},
            privatepeople     => $roominfo_ref->{privatepeople},
            privateconditions => $roominfo_ref->{privateconditions},
        },
    );
    return;
}

=head2 get_check_params_list

    roominfo バリデート用パラメータリスト作成

=cut

sub get_check_params_list {
    my $self = shift;

    my $check_params = [];

    my @keys  = keys $self->params();
    my $count = scalar @{ $self->params()->{ $keys[0] } };
    $count -= 1;
    for my $i ( 0 .. $count ) {
        my $param_hash = +{};
        for my $key (@keys) {
            $param_hash->{$key} = $self->params()->{$key}->[$i];
        }
        push @{$check_params}, $param_hash;
    }

    return $check_params;
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<parent>

=item * L<Yoyakku::Model::Setting>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
