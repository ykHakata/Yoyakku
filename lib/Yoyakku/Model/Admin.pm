package Yoyakku::Model::Admin;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model';
use Yoyakku::Util qw{get_fill_in_params chenge_time_over};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Admin - 店舗管理 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Admin version 0.0.1

=head1 SYNOPSIS (概要)

    Admin コントローラーのロジック API

=cut

=head2 get_header_stash_admin

    ヘッダー初期値取得

=cut

sub get_header_stash_admin {
    my $self       = shift;
    my $table      = $self->login_table();
    my $login_row  = $self->login_row();
    my $login_name = $self->login_name();
    return 'index'   if !$login_row;
    return 'index'   if !$table;
    return 'index'   if $table ne 'admin';
    return 'profile' if !$login_row->status;
    my $switch_header = $self->storeinfo_row()->status() eq 0 ? 10 : 7;
    return $self->get_header_stash_params( $switch_header, $login_name );
}

=head2 get_switch_com

    左naviのコメント切替の為の変数

=cut

sub get_switch_com {
    my $self   = shift;
    my $action = shift;

    my $switch_com
        = $action eq 'admin_store_edit'  ? 1
        : $action eq 'admin_store_comp'  ? 2
        : $action eq 'admin_reserv_edit' ? 3
        :                                  1;

    return $switch_com;
}

=head2 get_fill_in_admin

    html パラメーターフィルイン

=cut

sub get_fill_in_admin {
    my $self   = shift;
    my $html   = $self->html();
    my $params = $self->params();
    my $output = get_fill_in_params( $html, $params );
    return $output;
}

=head2 get_login_storeinfo_params

    ログイン id から storeinfo のテーブルより該当レコード抽出

=cut

sub get_login_storeinfo_params {
    my $self   = shift;
    my $params = $self->login_storeinfo_row()->get_columns();
    $self->params($params);
    return $params;
}

=head2 get_login_storeinfo_id

    ログイン id から storeinfo の id 取得

=cut

sub get_login_storeinfo_id {
    my $self = shift;
    my $id   = $self->login_storeinfo_row()->id;
    $self->params( +{ id => $id } );
    return $id;
}

=head2 get_post_search

    郵便番号から住所検索

=cut

sub get_post_search {
    my $self   = shift;
    my $teng   = $self->teng();
    my $params = $self->params();
    my $row    = $teng->single( 'post', +{ post_id => $params->{post}, }, );
    if ($row) {
        $params->{post}      = $row->post_id;
        $params->{region_id} = $row->region_id;
        $params->{state}     = $row->state;
        $params->{cities}    = $row->cities;
    }
    else {
        $params->{region_id} = 0;
        $params->{state}     = '登録なし';
        $params->{cities}    = '登録なし';
    }
    $self->params($params);
    return;
}

=head2 get_init_valid_params_admin_store_edit

    バリデート用パラメータ初期値(admin_store_edit)

=cut

sub get_init_valid_params_admin_store_edit {
    my $self = shift;
    return $self->get_init_valid_params(
        [qw{name post state cities addressbelow tel mail remarks url }] );
}

=head2 get_init_valid_params_admin_reserv_edit

    バリデート用パラメータ初期値(admin_reserv_edit)

=cut

sub get_init_valid_params_admin_reserv_edit {
    my $self = shift;
    return $self->get_init_valid_params(
        [qw{name endingtime_on rentalunit pricescomments}] );
}

=head2 check_admin_store_validator

    バリデート処理(admin_store)

=cut

sub check_admin_store_validator {
    my $self         = shift;
    my $check_params = $self->get_check_params('storeinfo');
    my $msg_params   = $self->get_msg_params('storeinfo');
    my $msg = $self->get_msg_validator( $check_params, $msg_params, );
    return if !$msg;
    my $valid_msg = $self->get_valid_msg( $msg, 'storeinfo' );
    return $valid_msg;
}

=head2 writing_admin_store

    storeinfo テーブル書込み、修正に対応

=cut

sub writing_admin_store {
    my $self = shift;

    my $create_data = $self->get_create_data('storeinfo');

    # 不要なカラムを削除
    delete $create_data->{admin_id};
    delete $create_data->{locationinfor};
    delete $create_data->{status};

    # update 以外は禁止
    die 'update only'
        if !$self->type() || ( $self->type() && $self->type() ne 'update' );

    return $self->writing_db( 'storeinfo', $create_data,
        $self->params()->{id} );
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

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<parent>

=item * L<Yoyakku::Model>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
