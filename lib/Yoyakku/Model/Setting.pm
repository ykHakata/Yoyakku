package Yoyakku::Model::Setting;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model';
use Yoyakku::Util qw{get_fill_in_params chenge_time_over};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Setting - 店舗管理 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Setting version 0.0.1

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