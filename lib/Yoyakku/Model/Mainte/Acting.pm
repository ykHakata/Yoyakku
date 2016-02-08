package Yoyakku::Model::Mainte::Acting;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model::Mainte';
use Yoyakku::Util qw{now_datetime get_fill_in_params};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Mainte::Acting - acting テーブル管理用 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Mainte::Acting version 0.0.1

=head1 SYNOPSIS (概要)

    Acting コントローラーのロジック API

=cut

=head2 get_init_valid_params_acting

    入力フォーム表示の際に利用

=cut

sub get_init_valid_params_acting {
    my $self = shift;
    return $self->get_init_valid_params( [qw{general_id storeinfo_id}] );
}

=head2 get_general_rows_all

    一般ユーザー情報の全てを row オブジェクトで取得

=cut

sub get_general_rows_all {
    my $self         = shift;
    my $teng         = $self->teng();
    my @general_rows = $teng->search( 'general', +{}, );
    return \@general_rows;
}

=head2 check_acting_validator_db

    入力値データベースとのバリデートチェックに利用

=cut

sub check_acting_validator_db {
    my $self   = shift;
    my $params = shift;
    my $teng   = $self->teng();

    my $valid_msg_db = +{ general_id => '既に利用されています' };

    # general_id, storeinfo_id, 組み合わせの重複確認
    my $check_acting_row = $teng->single(
        'acting',
        +{  general_id   => $params->{general_id},
            storeinfo_id => $params->{storeinfo_id},
            status       => 1,
        },
    );

    return if !$check_acting_row;
    return $valid_msg_db if !$params->{id};    # 新規
    return $valid_msg_db
        if ( $params->{id} ne $check_acting_row->id )
        && ( $params->{status} eq 1 );    # 更新
    return;
}

=head2 writing_acting

    テーブル書込み、新規、修正、両方に対応

=cut

sub writing_acting {
    my $self   = shift;
    my $params = shift;

    my $create_data = +{
        general_id   => $params->{general_id}   || undef,
        storeinfo_id => $params->{storeinfo_id} || undef,
        status       => $params->{status},
        create_on    => now_datetime(),
        modify_on    => now_datetime(),
    };
    return $self->writing_db( 'acting', $create_data, $params->{id} );
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
