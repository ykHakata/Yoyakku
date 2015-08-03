package Yoyakku::Model::Calendar;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model';
use Yoyakku::Util qw{switch_header_params get_fill_in_params};

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model::Calendar - オープニングカレンダー用 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Calendar version 0.0.1

=head1 SYNOPSIS (概要)

Calendar コントローラーのロジック API

=cut

=head2 get_header_stash_index

    ヘッダー初期値取得

=cut

sub get_header_stash_index {
    my $self  = shift;
    my $login = $self->check_auth_db_yoyakku();
    # return if !$login;

    return if !$self->switch_stash_index();
    return $self->switch_stash_index();
}

=head2 switch_stash_index

    index アクションログイン時の初期値作成

=cut

sub switch_stash_index {
    my $self = shift;

    my $table      = $self->login_table();
    my $login_row  = $self->login_row();
    my $login_name = $self->login_name();

    return if $login_row && !$login_row->status;

    my $switch_header = 2;

    if ( $table eq 'admin' ) {
        $switch_header = 4;
        if ( $self->storeinfo_row()->status eq 0 ) {
            $switch_header = 9;
        }
    }
    elsif ( $table eq 'general' ) {
        $switch_header = 3;
    }

    my $header_params = switch_header_params( $switch_header, $login_name );

    my $header_params_hash_ref = +{
        site_title_link        => $header_params->{site_title_link},
        header_heading_link    => $header_params->{header_heading_link},
        header_heading_name    => $header_params->{header_heading_name},
        header_navi_class_name => $header_params->{header_navi_class_name},
        header_navi_link_name  => $header_params->{header_navi_link_name},
        header_navi_row_name   => $header_params->{header_navi_row_name},
    };

    my $stash_profile = +{
        switch_header => $switch_header,    # 切替
        %{$header_params_hash_ref},         # ヘッダー各値
    };

    return $stash_profile;
}



1;

__END__
