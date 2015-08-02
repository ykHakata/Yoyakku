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
    return $self->switch_stash_index();
}

=head2 switch_stash_index

    index アクションログイン時の初期値作成

=cut

sub switch_stash_index {
    my $self = shift;

    # my $table      = $self->login_table();
    # my $id         = $self->login_row()->id;
    # my $login_row  = $self->login_row();
    # my $login_name = $self->login_name();

    my $login_name;
    my $switch_header = 2;


# if ($admin_id) {
#     my $admin_ref   = $teng->single('admin', +{id => $admin_id});
#     my $profile_ref = $teng->single('profile', +{admin_id => $admin_id});
#        $login       = q{(admin)}.$profile_ref->nick_name;

#     my $status = $admin_ref->status;
#     if ($status) {
#         my $storeinfo_ref = $teng->single('storeinfo', +{admin_id => $admin_id});
#         if ($storeinfo_ref->status eq 0) {
#             $switch_header = 9;
#         }
#         else {
#             $switch_header = 4;
#         }
#     }
#     else {
#         #$switch_header = 8;
#         return $self->redirect_to('profile');
#     }
# }
# elsif ($general_id) {
#     my $general_ref  = $teng->single('general', +{id => $general_id});
#     #$login         = $general_ref->login;
#     my $profile_ref = $teng->single('profile', +{general_id => $general_id});
#     $login          = $profile_ref->nick_name;

#     my $status = $general_ref->status;
#     if ($status) {
#         $switch_header = 3;
#     }
#     else {
#         #$switch_header = 8;
#         return $self->redirect_to('profile');
#     }
# }
# else {

#     #return $self->redirect_to('index');
# }

# $self->stash(login => $login);# #ログイン名をヘッダーの右に表示させる
# # headerの切替
# $self->stash(switch_header => $switch_header);



    # # ヘッダーの切替(初期値 8 ステータスなし、承認されてない)
    # my $switch_header = 8;

    # # ステータスあり(admin 7, general 6)
    # if ( $login_row->status ) {

    #     $switch_header
    #         = $table eq 'admin'   ? 7
    #         : $table eq 'general' ? 6
    #         :                       8;

    #     if ( $table eq 'admin' ) {
    #         my $storeinfo_row = $self->storeinfo_row();

    #         # 店舗ステータスなし(9)
    #         if ( $storeinfo_row && $storeinfo_row->status eq 0 ) {
    #             $switch_header = 9;
    #         }
    #     }
    # }







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
