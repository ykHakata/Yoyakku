package Yoyakku::Model::Mainte::Acting;
use Mojo::Base 'Yoyakku::Model::Mainte';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Mainte::Acting - acting テーブル管理用 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Mainte::Acting version 0.0.1

=head1 SYNOPSIS (概要)

    Acting コントローラーのロジック API

=cut

=head2 get_general_rows_all

    一般ユーザー情報の全てを row オブジェクトで取得

=cut

sub get_general_rows_all {
    my $self         = shift;
    my $general_rows = $self->general_db_rows_all();
    return $general_rows;
}

=head2 check_acting_validator_db

    入力値データベースとのバリデートチェックに利用

=cut

sub check_acting_validator_db {
    my $self   = shift;
    my $params = shift;

    my $valid_msg_db = +{ general_id => '既に利用されています' };

    # general_id, storeinfo_id, 組み合わせの重複確認
    my $args = +{
        general_id   => $params->{general_id},
        storeinfo_id => $params->{storeinfo_id},
        status       => 1,
    };
    my $check_acting_row = $self->acting_db_overlap_id($args);

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
    my $type   = shift;

    my $create_data = $self->get_create_data( 'acting', $params );

    my $args = +{
        table       => 'acting',
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
