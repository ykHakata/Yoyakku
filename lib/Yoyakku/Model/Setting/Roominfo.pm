package Yoyakku::Model::Setting::Roominfo;
use Mojo::Base 'Yoyakku::Model::Setting::Base';
use Yoyakku::Util qw{chenge_time_over join_time};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Setting::Roominfo - 店舗管理 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Setting::Roominfo version 0.0.1

=head1 SYNOPSIS (概要)

    Setting::Roominfo コントローラーのロジック API

=cut

=head2 set_admin_reserv_comp_params

    admin_reserv_comp 表示用パラメーター変換

=cut

sub set_admin_reserv_comp_params {
    my $self      = shift;
    my $login_row = shift;
    my $config    = $self->app->config;

    my $rows = $login_row->fetch_storeinfo->fetch_roominfos;

    my $roominfo_ref;
    for my $row ( @{$rows} ) {
        my $row_hash = $row->get_columns();
        my $split_t  = chenge_time_over(
            +{  start_time => $row->starttime_on,
                end_time   => $row->endingtime_on,
            },
        );
        ( $row_hash->{starttime_on}, $row_hash->{endingtime_on}, )
            = join_time( $split_t, 'none' );

        # 開始時刻 10:00:00 -> 10:00 starttime_on
        my ( $hour, $min, $sec ) = split ':', $row_hash->{starttime_on};
        $row_hash->{starttime_on} = $hour . ':' . $min;

        # 終了時刻 22:00:00 -> 22:00 endingtime_on
        ( $hour, $min, $sec ) = split ':', $row_hash->{endingtime_on};
        $row_hash->{endingtime_on} = $hour . ':' . $min;

        # 単位 1 -> 1h rentalunit
        $row_hash->{rentalunit} = $row_hash->{rentalunit} . 'h';

        # 個人練習 許可 0, 1 -> ○, ×, privatepermit
        if ( $row_hash->{privatepermit} eq 1 ) {
            $row_hash->{privatepermit} = $config->{constant}->{PRIVATE_MIT_1};
        }
        else {
            $row_hash->{privatepermit} = $config->{constant}->{PRIVATE_MIT_0};
        }

        # 個人練習 予約条件 1日前 ... privateconditions
        my $private = $row_hash->{privateconditions};
        my $val
            = ( $private eq 0 ) ? $config->{constant}->{PRIVATE_COND_0}
            : ( $private eq 1 ) ? $config->{constant}->{PRIVATE_COND_1}
            : ( $private eq 2 ) ? $config->{constant}->{PRIVATE_COND_2}
            : ( $private eq 3 ) ? $config->{constant}->{PRIVATE_COND_3}
            : ( $private eq 4 ) ? $config->{constant}->{PRIVATE_COND_4}
            : ( $private eq 5 ) ? $config->{constant}->{PRIVATE_COND_5}
            : ( $private eq 6 ) ? $config->{constant}->{PRIVATE_COND_6}
            : ( $private eq 7 ) ? $config->{constant}->{PRIVATE_COND_7}
            :                     $config->{constant}->{PRIVATE_COND_8};
        $row_hash->{privateconditions} = $val;

        # status が 0 無効のものは表示しない
        while ( my ( $key, $value ) = each %{$row_hash} ) {
            if ( $row_hash->{status} eq 0 ) {
                $value = '';
            }
            push @{ $roominfo_ref->{$key} }, $value;
        }
    }

    return $roominfo_ref;
}

=head2 set_roominfo_params

    予約情報設定のためのパラメーター取得

=cut

sub set_roominfo_params {
    my $self      = shift;
    my $login_row = shift;

    my $rows = $login_row->fetch_storeinfo->fetch_roominfos;

    my $roominfo_ref = +{};
    for my $row ( @{$rows} ) {
        my $row_hash = $row->get_columns();
        my $split_t  = chenge_time_over(
            +{  start_time => $row->starttime_on,
                end_time   => $row->endingtime_on,
            },
        );
        ( $row_hash->{starttime_on}, $row_hash->{endingtime_on}, )
            = join_time( $split_t, 'none' );

        while ( my ( $key, $value ) = each %{$row_hash} ) {
            push @{ $roominfo_ref->{$key} }, $value;
        }
    }

    my @keys = keys %{$roominfo_ref};
    # warn '$roominfo_ref',dumper($roominfo_ref);
    my $params = +{};
    for my $key (@keys) {
        $params->{$key} = $roominfo_ref->{$key};
    }
    return $params;
}

=head2 get_check_params_list

    roominfo バリデート用パラメータリスト作成

=cut

sub get_check_params_list {
    my $self   = shift;
    my $params = shift;

    my $check_params = [];

    my @keys  = keys %{ $params };
    my $count = scalar @{ $params->{ $keys[0] } };
    $count -= 1;
    for my $i ( 0 .. $count ) {
        my $param_hash = +{};
        for my $key (@keys) {
            $param_hash->{$key} = $params->{$key}->[$i];
        }
        push @{$check_params}, $param_hash;
    }

    return $check_params;
}

=head2 writing_admin_reserv

    roominfo テーブル書込み、修正に対応

=cut

sub writing_admin_reserv {
    my $self   = shift;
    my $params = shift;
    my $type   = shift;

    # 書き込む前に開始、終了時刻変換
    my $FIELD_SEPARATOR_TIME = q{:};
    my $FIELD_COUNT_TIME     = 3;

    my ( $start_hour, $start_minute, $start_second, )
        = split $FIELD_SEPARATOR_TIME, $params->{starttime_on},
        $FIELD_COUNT_TIME + 1;

    my ( $end_hour, $end_minute, $end_second, ) = split $FIELD_SEPARATOR_TIME,
        $params->{endingtime_on}, $FIELD_COUNT_TIME + 1;

    # 数字にもどす
    $start_hour += 0;
    $end_hour   += 0;

    # 時間の表示を変換
    if ( $start_hour >= 24 && $start_hour <= 30 ) {
        $start_hour -= 24;
    }

    if ( $end_hour >= 24 && $end_hour <= 30 ) {
        $end_hour -= 24;
    }

    $params->{starttime_on} = join ':', $start_hour, $start_minute,
        $start_second;
    $params->{endingtime_on} = join ':', $end_hour, $end_minute, $end_second;

    $params->{starttime_on}  = sprintf '%08s', $params->{starttime_on};
    $params->{endingtime_on} = sprintf '%08s', $params->{endingtime_on};

    my $create_data
        = $self->app->model->db->roominfo->get_create_data($params);

    # 不要なカラムを削除
    delete $create_data->{storeinfo_id};
    delete $create_data->{bookinglimit};
    delete $create_data->{cancellimit};
    delete $create_data->{remarks};
    delete $create_data->{webpublishing};
    delete $create_data->{webreserve};

    # name (部屋名) が存在するときだけ status 1 (利用可能)
    $create_data->{status} = 0;
    if ( $create_data->{name} ) {
        $create_data->{status} = 1;
    }

    # update 以外は禁止
    die 'update only' if !$type || ( $type && $type ne 'update' );

    my $args = +{
        table       => 'roominfo',
        create_data => $create_data,
        update_id   => $params->{id},
        type        => $type,
    };

    return $self->app->model->db->base->writing_db($args);
}

=head2 writing_up_admin_r_d_edit

    roominfo テーブル書込み、修正に対応

=cut

sub writing_up_admin_r_d_edit {
    my $self   = shift;
    my $params = shift;
    my $type   = shift;

    my $create_data
        = $self->app->model->db->roominfo->get_create_data($params);

    # 不要なカラムを削除
   delete $create_data->{storeinfo_id};
   delete $create_data->{starttime_on};
   delete $create_data->{endingtime_on};
   delete $create_data->{rentalunit};
   delete $create_data->{time_change};
   delete $create_data->{pricescomments};
   delete $create_data->{privatepermit};
   delete $create_data->{privatepeople};
   delete $create_data->{privateconditions};
   delete $create_data->{webpublishing};
   delete $create_data->{webreserve};
   delete $create_data->{status};

    # name (部屋名) が存在するときだけ status 1 (利用可能)
    $create_data->{status} = 0;
    if ( $create_data->{name} ) {
        $create_data->{status} = 1;
    }

    # update 以外は禁止
    die 'update only' if !$type || ( $type && $type ne 'update' );

    my $args = +{
        table       => 'roominfo',
        create_data => $create_data,
        update_id   => $params->{id},
        type        => $type,
    };

    return $self->app->model->db->base->writing_db($args);
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::Model::Setting>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
