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

=head2 search_acting_id_rows

    use Yoyakku::Model::Mainte::Acting;

    my $model = $self->_init();

    my $acting_rows = $model->search_acting_id_rows();

    テーブル一覧作成時に利用

=cut

sub search_acting_id_rows {
    my $self = shift;
    return $self->search_id_single_or_all_rows( 'acting',
        $self->params()->{id} );
}

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

=head2 get_storeinfo_rows_all

    店舗情報の全てを row オブジェクトで取得

=cut

sub get_storeinfo_rows_all {
    my $self           = shift;
    my $teng           = $self->teng();
    my @storeinfo_rows = $teng->search( 'storeinfo', +{}, );
    return \@storeinfo_rows;
}

=head2 get_update_form_params_acting

    修正用入力フォーム表示の際に利用

=cut

sub get_update_form_params_acting {
    my $self = shift;
    $self->get_update_form_params('acting');
    return $self;
}

=head2 check_acting_validator

    入力値バリデートチェックに利用

=cut

sub check_acting_validator {
    my $self = shift;

    my $check_params = [
        general_id   => [ 'NOT_NULL', ],
        storeinfo_id => [ 'NOT_NULL', ],
    ];

    my $msg_params = [
        'general_id.not_null'   => '両方を選んでください',
        'storeinfo_id.not_null' => '両方を選んでください',
    ];

    my $msg = $self->get_msg_validator( $check_params, $msg_params, );

    return if !$msg;

    return +{
        general_id   => $msg->{general_id},
        storeinfo_id => $msg->{storeinfo_id},
    };
}

=head2 check_acting_validator_db

    入力値データベースとのバリデートチェックに利用

=cut

sub check_acting_validator_db {
    my $self   = shift;
    my $teng   = $self->teng();
    my $params = $self->params();

    my $valid_msg_db = +{ general_id => '既に利用されています' };

    # general_id, storeinfo_id, 組み合わせの重複確認
    my $check_acting_row = $teng->single(
        'acting',
        +{  general_id   => $params->{general_id},
            storeinfo_id => $params->{storeinfo_id},
            status       => 1,
        },
    );

    return               if !$check_acting_row;
    return $valid_msg_db if !$params->{id};                           # 新規
    return $valid_msg_db if $params->{id} ne $check_acting_row->id;   # 更新
    return;
}

=head2 writing_acting

    テーブル書込み、新規、修正、両方に対応

=cut

sub writing_acting {
    my $self = shift;

    my $create_data = +{
        general_id   => $self->params()->{general_id}   || undef,
        storeinfo_id => $self->params()->{storeinfo_id} || undef,
        status       => $self->params()->{status},
        create_on    => now_datetime(),
        modify_on    => now_datetime(),
    };
    return $self->writing_db( 'acting', $create_data,
        $self->params()->{id} );
}

=head2 get_fill_in_acting

    表示用 html を生成

=cut

sub get_fill_in_acting {
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
