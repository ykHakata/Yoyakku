package Yoyakku::Model::Mainte::Profile;
use Mojo::Base 'Yoyakku::Model::Mainte::Base';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Mainte::Profile - Profile テーブル管理用 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Mainte::Profile version 0.0.1

=head1 SYNOPSIS (概要)

    Profile コントローラーのロジック API

=cut

=head2 get_general_rows_all

    profile 入力画面セレクト用のログイン名表示

=cut

sub get_general_rows_all {
    my $self = shift;
    my $rows = $self->app->model->db->general->rows_all();
    return $rows;
}

=head2 get_admin_rows_all

    profile 入力画面セレクト用のログイン名表示

=cut

sub get_admin_rows_all {
    my $self = shift;
    my $rows = $self->app->model->db->admin->rows_all();
    return $rows;
}

=head2 check_profile_validator_db

    profile 入力値データベースとのバリデートチェックに利用

=cut

sub check_profile_validator_db {
    my $self   = shift;
    my $params = shift;

    my $valid_msg_profile_db = +{};

    # general_id, admin_id, 重複、既存の確認
    my $check_admin_and_general_msg
        = $self->_check_admin_and_general_id($params);

    if ($check_admin_and_general_msg) {
        $valid_msg_profile_db
            = +{ general_id => $check_admin_and_general_msg };
    }

    return $valid_msg_profile_db if $check_admin_and_general_msg;
    return;
}

sub _check_admin_and_general_id {
    my $self   = shift;
    my $params = shift;

    my $general_id = $params->{general_id};
    my $admin_id   = $params->{admin_id};
    my $profile_id = $params->{id};

    # admin_id, general_id の他のレコードでの重複利用をさける
    # 両方に id の指定が存在する場合 両方ない場合
    return '一般,管理どちらかにしてください'
        if ($admin_id && $general_id) || (!$admin_id && !$general_id);

    my $check_params = +{
        column => 'admin_id',
        param  => $admin_id,
        table  => 'profile',
        id     => $profile_id,
    };

    # 管理ユーザー
    return $self->check_table_column($check_params) if $admin_id;

    $check_params->{column} = 'general_id';
    $check_params->{param}  = $general_id;

    # 一般ユーザー
    return $self->check_table_column($check_params) if $general_id;
}

=head2 writing_profile

    profile テーブル書込み、新規、修正、両方に対応

=cut

sub writing_profile {
    my $self = shift;
    my $params = shift;
    my $type   = shift;

    my $create_data = $self->get_create_data( 'profile', $params );

    my $args = +{
        table       => 'profile',
        create_data => $create_data,
        update_id   => $params->{id},
        type        => $type,
    };
    return $self->writing_from_db($args);
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::Model::Mainte>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
