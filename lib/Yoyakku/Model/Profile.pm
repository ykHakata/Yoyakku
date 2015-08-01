package Yoyakku::Model::Profile;
use strict;
use warnings;
use utf8;
use Yoyakku::Util qw{now_datetime switch_header_params get_fill_in_params};
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
            if ( $storeinfo_row && $storeinfo_row->status eq 0 ) {
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
    my $acting_ids  = $self->get_acting_ids();


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
    if ( $self->get_switch_acting() ) {
        $params->{acting_1} = $acting_name->{acting_1};
        $params->{acting_2} = $acting_name->{acting_2};
        $params->{acting_3} = $acting_name->{acting_3};
    }

    if ( $self->get_switch_acting() && $action eq 'profile' ) {
        $params->{acting_1} = $acting_ids->[0]->{storeinfo_id};
        $params->{acting_2} = $acting_ids->[1]->{storeinfo_id};
        $params->{acting_3} = $acting_ids->[2]->{storeinfo_id};
    }

    if ( $action eq 'profile' ) {
        $params->{password_2} = $login_row->password;
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
    my $self       = shift;
    my $teng       = $self->teng();
    my $acting_ids = $self->get_acting_ids();

    my $storeinfo_id_1 = $acting_ids->[0]->{storeinfo_id};
    my $storeinfo_id_2 = $acting_ids->[1]->{storeinfo_id};
    my $storeinfo_id_3 = $acting_ids->[2]->{storeinfo_id};

    my $acting_1 = $teng->single( 'storeinfo',
        +{ id => $storeinfo_id_1, status => 1, } );
    my $acting_2 = $teng->single( 'storeinfo',
        +{ id => $storeinfo_id_2, status => 1, } );
    my $acting_3 = $teng->single( 'storeinfo',
        +{ id => $storeinfo_id_3, status => 1, } );

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
    my $self = shift;

    my $get_acting_ids;

    return if !$self->acting_rows();

    for my $acting_row ( @{$self->acting_rows()} ) {
        push @{$get_acting_ids},
            +{
            id           => $acting_row->id,
            storeinfo_id => $acting_row->storeinfo_id,
            };
    }

    return $get_acting_ids;
}

=head2 check_profile_with_auth_validator

    入力値バリデートチェックに利用

=cut

sub check_profile_with_auth_validator {
    my $self = shift;

    my $check_params = [

        # admin or general
        id         => [ 'NOT_NULL', ],
        login      => [ 'NOT_NULL', ],
        password   => [ 'NOT_NULL', ],
        password_2 => [ 'NOT_NULL', ],
        +{ passwords => [qw/password password_2/] } => ['DUPLICATION'],

        # profile
        profile_id    => [ 'INT', ],
        nick_name     => [ 'NOT_NULL', [ 'LENGTH', 0, 20, ], ],
        full_name     => [ [ 'LENGTH', 0, 20, ], ],
        phonetic_name => [ [ 'LENGTH', 0, 20, ], ],
        tel           => [ [ 'LENGTH', 0, 20, ], ],
        mail          => [ 'EMAIL_LOOSE', ],

        # acting
        acting_1 => [ 'INT', ],
        acting_2 => [ 'INT', ],
        acting_3 => [ 'INT', ],
    ];

    my $msg_params = [
        'id.not_null'         => '必須入力',
        'login.not_null'      => '必須入力',
        'password.not_null'   => '必須入力',
        'password_2.not_null' => '必須入力',
        'passwords.duplication' =>
            '入力したパスワードが違います',
        'profile_id.int'     => '指定の形式で入力してください',
        'nick_name.length'   => '文字数!!',
        'nick_name.not_null' => '必須入力',
        'full_name.length'   => '文字数!!',
        'phonetic_name.length' => '文字数!!',
        'tel.length'           => '文字数!!',
        'mail.email_loose'     => 'Eメールを入力してください',
        'acting_1.int' => '指定の形式で入力してください',
        'acting_2.int' => '指定の形式で入力してください',
        'acting_3.int' => '指定の形式で入力してください',
    ];

    my $msg = $self->get_msg_validator( $check_params, $msg_params, );

    # acting(storeinfo_id) 選択しなくてもよいが、重複不可
    my $acting_1 = $self->params()->{acting_1};
    my $acting_2 = $self->params()->{acting_2};
    my $acting_3 = $self->params()->{acting_3};

    my $acting_msg
        = $acting_1 && $acting_1 eq $acting_2 ? '同じものは入力不可'
        : $acting_1 && $acting_1 eq $acting_3 ? '同じものは入力不可'
        : $acting_2 && $acting_2 eq $acting_1 ? '同じものは入力不可'
        : $acting_2 && $acting_2 eq $acting_3 ? '同じものは入力不可'
        : $acting_3 && $acting_3 eq $acting_1 ? '同じものは入力不可'
        : $acting_3 && $acting_3 eq $acting_2 ? '同じものは入力不可'
        :                                       undef;

    if ($acting_msg) {
        $msg->{acting_1} = $acting_msg;
    }

    return if !$msg;

    return +{
        nick_name     => $msg->{nick_name},
        password      => $msg->{password},
        password_2    => $msg->{password_2} || $msg->{passwords},
        full_name     => $msg->{full_name},
        phonetic_name => $msg->{phonetic_name},
        tel           => $msg->{tel},
        mail          => $msg->{mail},
        acting_1      => $msg->{acting_1},
    };
}

=head2 writing_profile

    テーブル書込み、新規、修正、両方に対応

=cut

sub writing_profile {
    my $self = shift;
    my $teng = $self->teng();

    # 認証 admin or general
    my $auth_data = +{
        password  => $self->params()->{password},
        status    => 1,
        modify_on => now_datetime(),
    };
    $self->login_row()->update($auth_data);

    # admin の場合は storeinfo, roominfo 作成
    if ( $self->login_table eq 'admin' ) {
        my $admin_id = $self->login_row()->id;
        $self->insert_admin_relation($admin_id);
    }

    # profile
    my $profile_data = +{
        nick_name  => $self->params()->{nick_name},
        full_name  => $self->params()->{full_name},
        phonetic_name => $self->params()->{phonetic_name},
        tel           => $self->params()->{tel},
        mail          => $self->params()->{mail},
        status        => 1,
        modify_on     => now_datetime(),
    };

    if ( $self->type() eq 'insert' && $self->login_table() eq 'admin' ) {
        $profile_data->{admin_id}  = $self->params()->{id};
        $profile_data->{create_on} = now_datetime();
        $teng->insert( 'profile', $profile_data, );
    }
    elsif ( $self->type() eq 'insert' && $self->login_table() eq 'general' ) {
        $profile_data->{general_id} = $self->params()->{id};
        $profile_data->{create_on}  = now_datetime();
        $teng->insert( 'profile', $profile_data, );
    }
    else {
        $self->profile_row()->update($profile_data);
    }

    return if $self->login_table() eq 'admin';

    # acting
    my $acting_common = +{
        general_id => $self->params()->{id} || undef,
        status     => 1,
        modify_on  => now_datetime(),
    };

    my $acting_1 = +{
        %{$acting_common},
        storeinfo_id => $self->params()->{acting_1} || undef,
    };

    my $acting_2 = +{
        %{$acting_common},
        storeinfo_id => $self->params()->{acting_2} || undef,
    };

    my $acting_3 = +{
        %{$acting_common},
        storeinfo_id => $self->params()->{acting_3} || undef,
    };

    my $acting_data = [ $acting_1, $acting_2, $acting_3, ];
    my $acting_rows = $self->acting_rows();

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
