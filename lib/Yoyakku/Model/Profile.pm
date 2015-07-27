package Yoyakku::Model::Profile;
use strict;
use warnings;
use utf8;
use Yoyakku::Util qw{switch_header_params get_fill_in_params};
use parent 'Yoyakku::Model';

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model::Profile - プロフィール用 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Profile version 0.0.1

=head1 SYNOPSIS (概要)

profile コントローラーのロジック API

=cut

=head2 get_header_stash_auth_profile

    ログイン確認、ヘッダー初期値取得

=cut

sub get_header_stash_auth_profile {
    my $self  = shift;
    my $login = $self->check_auth_db_yoyakku();
    return if !$login;
    return $self->switch_stash_profile();
}

=head2 switch_stash_profile

    profile アクションログイン時の初期値作成

=cut

sub switch_stash_profile {
    my $self = shift;

    my $table      = $self->login_table();
    my $id         = $self->login_row()->id;
    my $login_row  = $self->login_row();
    my $login_name = $self->login_name();

    # id table ないとき強制終了
    die 'not id table!: ' if !$id || !$table;

    # login_row ないときは強制終了
    die 'not login_row!: ' if !$login_row;

    # ヘッダーの切替(初期値 8 ステータスなし、承認されてない)
    my $switch_header = 8;

    # ステータスあり(admin 7, general 6)
    if ( $login_row->status ) {

        $switch_header
            = $table eq 'admin'   ? 7
            : $table eq 'general' ? 6
            :                       8;

        if ( $table eq 'admin' ) {
            my $storeinfo_row = $self->storeinfo_row();

            # 店舗ステータスなし(9)
            if ( $storeinfo_row->status eq 0 ) {
                $switch_header = 9;
            }
        }
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


=head2 set_form_params_profile

    入力フォーム表示の際に利用

=cut

sub set_form_params_profile {
    my $self   = shift;
    my $action = shift;

    my $profile_row = $self->profile_row();
    my $login_row   = $self->login_row();
    my $acting_name = $self->get_acting_name();

    my $params = +{
        id            => $login_row->id,
        login         => $login_row->login,
        password      => $login_row->password,
        profile_id    => $profile_row ? $profile_row->id : undef,
        nick_name     => $profile_row ? $profile_row->nick_name : undef,
        full_name     => $profile_row ? $profile_row->full_name : undef,
        phonetic_name => $profile_row ? $profile_row->phonetic_name : undef,
        tel           => $profile_row ? $profile_row->tel : undef,
        mail          => $profile_row ? $profile_row->mail : undef,
        acting_1      => $acting_name->{acting_1},
        acting_2      => $acting_name->{acting_2},
        acting_3      => $acting_name->{acting_3},
    };

    if ( $action eq 'profile' ) {
        my $acting_params = $self->get_acting_params();

        $params->{password_2} = $login_row->password;
        $params->{acting_1}   = $acting_params->{acting_1};
        $params->{acting_2}   = $acting_params->{acting_2};
        $params->{acting_3}   = $acting_params->{acting_3};
    }

    $self->params($params);
    return;
}

=head2 get_init_valid_params_profile

    入力フォーム表示の際に利用

=cut

sub get_init_valid_params_profile {
    my $self = shift;
    return $self->get_init_valid_params(
        [   qw{password password_2 nick_name full_name
                phonetic_name tel mail acting_1}
        ]
    );
}

=head2 get_switch_acting

    お気に入りリスト admin 非表示 general 表示

=cut

sub get_switch_acting {
    my $self = shift;

    my $switch_acting
        = $self->login_table() eq 'admin'   ? undef
        : $self->login_table() eq 'general' ? 1
        :                                     undef;

    return $switch_acting;
}

=head2 get_acting_name

    代行リストの該当店舗名取得

=cut

sub get_acting_name {
    my $self        = shift;
    my $teng        = $self->teng();
    my $login_table = $self->login_table();
    my $login_row   = $self->login_row();

    my $get_acting_name;

    if ( $login_table && $login_table eq 'general' ) {
        my @actings
            = $teng->search( 'acting',
            +{ general_id => $login_row->id, status => 1, } );

        if ( scalar @actings ) {

            my $acting_1 = $teng->single( 'storeinfo',
                +{ id => $actings[0]->storeinfo_id, status => 1, } );
            my $acting_2 = $teng->single( 'storeinfo',
                +{ id => $actings[1]->storeinfo_id, status => 1, } );
            my $acting_3 = $teng->single( 'storeinfo',
                +{ id => $actings[2]->storeinfo_id, status => 1, } );

            $get_acting_name = +{
                acting_1 => $acting_1->name,
                acting_2 => $acting_2->name,
                acting_3 => $acting_3->name,
            };
        }
    }

    return $get_acting_name;
}

=head2 get_acting_params

    generel の場合は acting テーブル 代行リスト

=cut

sub get_acting_params {
    my $self        = shift;
    my $teng        = $self->teng();
    my $login_table = $self->login_table();
    my $login_row   = $self->login_row();

    my $get_acting_params;

    if ( $login_table && $login_table eq 'general' ) {
        my @actings
            = $teng->search( 'acting',
            +{ general_id => $login_row->id, status => 1, } );

        if ( scalar @actings ) {
            $get_acting_params = +{
                acting_1 => $actings[0]->storeinfo_id,
                acting_2 => $actings[1]->storeinfo_id,
                acting_3 => $actings[2]->storeinfo_id,
            };
        }
    }

    return $get_acting_params;
}

=head2 get_fill_in_profile

    表示用 html を生成

=cut

sub get_fill_in_profile {
    my $self   = shift;
    my $html   = $self->html();
    my $params = $self->params();
    my $output = get_fill_in_params( $html, $params );
    return $output;
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<Time::Piece>

=item * L<Time::Seconds>

=item * L<Yoyakku::Model>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
