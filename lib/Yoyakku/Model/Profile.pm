package Yoyakku::Model::Profile;
use Mojo::Base 'Yoyakku::Model::Base';
use Yoyakku::Util qw{now_datetime};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Profile - プロフィール用 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Profile version 0.0.1

=head1 SYNOPSIS (概要)

    profile コントローラーのロジック API

=cut

=head2 get_header_stash_profile

    ヘッダー初期値取得

=cut

sub get_header_stash_profile {
    my $self      = shift;
    my $login_row = shift;

    # login_row ないときは強制終了
    die 'not login_row!: ' if !$login_row;

    my $table      = $login_row->get_table_name;
    my $login_name = $login_row->get_login_name;

    # ヘッダーの切替(初期値 8 ステータスなし、承認されてない)
    my $switch_header = 8;

    # ステータスあり(admin 7, general 6)
    if ( $login_row->status ) {

        $switch_header
            = $table eq 'admin'   ? 7
            : $table eq 'general' ? 6
            :                       8;

        if ( $table eq 'admin' ) {
            my $storeinfo_row = $login_row->fetch_storeinfo;

            # 店舗ステータスなし(9)
            if ( $storeinfo_row && $storeinfo_row->status eq 0 ) {
                $switch_header = 9;
            }
        }
    }

    return $self->get_header_stash_params( $switch_header, $login_name );
}

=head2 set_form_params_profile

    入力フォーム表示の際に利用

=cut

sub set_form_params_profile {
    my $self      = shift;
    my $action    = shift;
    my $login_row = shift;

    my $profile_row = $login_row->fetch_profile;
    my $acting_name = $self->get_acting_name($login_row);
    my $acting_ids  = $self->get_acting_ids($login_row);

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
    };

    # general ログインの場合のみ acting の値を生成
    if ( $self->get_switch_acting($login_row) ) {
        $params->{acting_1} = $acting_name->{acting_1};
        $params->{acting_2} = $acting_name->{acting_2};
        $params->{acting_3} = $acting_name->{acting_3};
    }

    if ( $self->get_switch_acting($login_row) && $action eq 'profile' ) {
        $params->{acting_1} = $acting_ids->[0]->{storeinfo_id};
        $params->{acting_2} = $acting_ids->[1]->{storeinfo_id};
        $params->{acting_3} = $acting_ids->[2]->{storeinfo_id};
    }

    if ( $action eq 'profile' ) {
        $params->{password_2} = $login_row->password;
    }
    return $params;
}

=head2 get_switch_acting

    お気に入りリスト admin 非表示 general 表示

=cut

sub get_switch_acting {
    my $self      = shift;
    my $login_row = shift;

    die 'not $login_row' if !$login_row;

    my $switch_acting
        = $login_row->get_table_name eq 'admin'   ? undef
        : $login_row->get_table_name eq 'general' ? 1
        :                                           undef;

    return $switch_acting;
}

=head2 get_acting_name

    代行リストの該当店舗名取得

=cut

sub get_acting_name {
    my $self       = shift;
    my $login_row  = shift;
    my $teng       = $self->db->base->teng();
    my $acting_ids = $self->get_acting_ids($login_row);

    my $storeinfo_id_1 = $acting_ids->[0]->{storeinfo_id};
    my $storeinfo_id_2 = $acting_ids->[1]->{storeinfo_id};
    my $storeinfo_id_3 = $acting_ids->[2]->{storeinfo_id};

    my $acting_1 = $teng->single( 'storeinfo', +{ id => $storeinfo_id_1, } );
    my $acting_2 = $teng->single( 'storeinfo', +{ id => $storeinfo_id_2, } );
    my $acting_3 = $teng->single( 'storeinfo', +{ id => $storeinfo_id_3, } );

    my $acting_1_name = $acting_1 ? $acting_1->name : undef;
    my $acting_2_name = $acting_2 ? $acting_2->name : undef;
    my $acting_3_name = $acting_3 ? $acting_3->name : undef;

    my $get_acting_name = +{
        acting_1 => $acting_1_name,
        acting_2 => $acting_2_name,
        acting_3 => $acting_3_name,
    };

    return $get_acting_name;
}

=head2 get_acting_ids

    generel の場合は該当の acting テーブル ids

=cut

sub get_acting_ids {
    my $self      = shift;
    my $login_row = shift;

    die 'not $login_row' if !$login_row;

    my $get_acting_ids;

    return if $login_row->get_table_name ne 'general';

    for my $acting_row ( @{$login_row->fetch_actings} ) {
        push @{$get_acting_ids},
            +{
            id           => $acting_row->id,
            storeinfo_id => $acting_row->storeinfo_id,
            };
    }

    return $get_acting_ids;
}

=head2 writing_profile

    テーブル書込み、新規、修正、両方に対応

=cut

sub writing_profile {
    my $self      = shift;
    my $params    = shift;
    my $type      = shift;
    my $login_row = shift;

    my $teng = $self->db->base->teng();

    # 認証 admin or general
    my $auth_data = +{
        password  => $params->{password},
        status    => 1,
        modify_on => now_datetime(),
    };
    $login_row->update($auth_data);

    # admin の場合は storeinfo, roominfo 作成
    if ( $login_row->get_table_name eq 'admin' ) {
        my $admin_id = $login_row->id;
        $self->insert_admin_relation($admin_id);
    }

    # profile
    my $profile_data = +{
        nick_name     => $params->{nick_name},
        full_name     => $params->{full_name},
        phonetic_name => $params->{phonetic_name},
        tel           => $params->{tel},
        mail          => $params->{mail},
        status        => 1,
        modify_on     => now_datetime(),
    };

    if ( $type eq 'insert' && $login_row->get_table_name() eq 'admin' ) {
        $profile_data->{admin_id}  = $params->{id};
        $profile_data->{create_on} = now_datetime();
        $teng->insert( 'profile', $profile_data, );
    }
    elsif ( $type eq 'insert' && $login_row->get_table_name() eq 'general' ) {
        $profile_data->{general_id} = $params->{id};
        $profile_data->{create_on}  = now_datetime();
        $teng->insert( 'profile', $profile_data, );
    }
    else {
        $login_row->fetch_profile->update($profile_data);
    }

    return if $login_row->get_table_name() eq 'admin';

    # acting
    my $acting_common = +{
        general_id => $params->{id} || undef,
        status     => 1,
        modify_on  => now_datetime(),
    };

    my $acting_1 = +{
        %{$acting_common},
        storeinfo_id => $params->{acting_1} || undef,
    };

    my $acting_2 = +{
        %{$acting_common},
        storeinfo_id => $params->{acting_2} || undef,
    };

    my $acting_3 = +{
        %{$acting_common},
        storeinfo_id => $params->{acting_3} || undef,
    };

    my $acting_data = [ $acting_1, $acting_2, $acting_3, ];
    my $acting_rows = $login_row->fetch_actings;

    ACTING_UPDATE:
    for my $acting ( @{$acting_data} ) {
        my $acting_row = shift @{$acting_rows};
        if ($acting_row) {
            $acting_row->update($acting);
            next ACTING_UPDATE;
        }
        $acting->{create_on} = now_datetime();
        $teng->insert( 'acting', $acting, );
    }

    return;
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::Model>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
