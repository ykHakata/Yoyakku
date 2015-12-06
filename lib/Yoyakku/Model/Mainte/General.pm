package Yoyakku::Model::Mainte::General;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model::Mainte';
use Yoyakku::Util qw{now_datetime get_fill_in_params};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Mainte::General - general テーブル管理用 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Mainte::General version 0.0.1

=head1 SYNOPSIS (概要)

    General コントローラーのロジック API

=cut

=head2 search_general_id_rows

    general テーブル一覧作成時に利用

=cut

sub search_general_id_rows {
    my $self = shift;
    return $self->search_id_single_or_all_rows( 'general',
        $self->params()->{general_id} );
}

=head2 get_init_valid_params_general

    general 入力フォーム表示の際に利用

=cut

sub get_init_valid_params_general {
    my $self = shift;
    return $self->get_init_valid_params( [qw{login password}] );
}

=head2 get_update_form_params_general

    general 修正用入力フォーム表示の際に利用

=cut

sub get_update_form_params_general {
    my $self = shift;
    $self->get_update_form_params('general');
    return $self;
}

sub check_general_validator {
    my $self   = shift;

    my $check_params = [
        login    => [ 'NOT_NULL', ],
        password => [ 'NOT_NULL', ],
    ];

    my $msg_params = [
        'login.not_null'    => '必須入力',
        'password.not_null' => '必須入力',
    ];

    my $msg = $self->get_msg_validator( $check_params, $msg_params, );

    return if !$msg;

    my $valid_msg_general = +{
        login    => $msg->{login},
        password => $msg->{password},
    };

    return $valid_msg_general;
}

=head2 check_general_validator_db

    general 入力値データベースとのバリデートチェックに利用

=cut

sub check_general_validator_db {
    my $self = shift;

    my $valid_msg_general_db = +{};
    my $check_general_msg    = $self->check_login_name('general');

    if ($check_general_msg) {
        $valid_msg_general_db = +{ login => $check_general_msg };
    }
    return $valid_msg_general_db if $check_general_msg;
    return;
}

=head2 writing_general

    general テーブル書込み、新規、修正、両方に対応

=cut

sub writing_general {
    my $self = shift;

    my $create_data = +{
        login     => $self->params()->{login},
        password  => $self->params()->{password},
        status    => $self->params()->{status},
        create_on => now_datetime(),
        modify_on => now_datetime(),
    };
    return $self->writing_db( 'general', $create_data,
        $self->params()->{id} );
}

=head2 get_fill_in_general

    表示用 html を生成

=cut

sub get_fill_in_general {
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

=item * L<parent>

=item * L<Yoyakku::Model::Mainte>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
