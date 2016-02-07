package Yoyakku::Model::Mainte::Ads;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model::Mainte';
use Yoyakku::Util qw{now_datetime get_fill_in_params};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Mainte::Ads - ads テーブル管理用 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Mainte::Ads version 0.0.1

=head1 SYNOPSIS (概要)

    Ads コントローラーのロジック API

=cut

=head2 get_init_valid_params_ads

    入力フォーム表示の際に利用

=cut

sub get_init_valid_params_ads {
    my $self = shift;
    return $self->get_init_valid_params(
        [qw{url displaystart_on displayend_on name content event_date}] );
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

=head2 get_region_rows_pref

    地域ID情報、全国都道府県のみ row オブジェクトで取得

=cut

sub get_region_rows_pref {
    my $self = shift;
    my $teng = $self->teng();

    my $sql = q{
        SELECT id, name
        FROM region
        WHERE id REGEXP '(^[0-4][0-9])0{3}$'
        ORDER BY id ASC;
    };

    my @region_rows = $teng->search_named($sql);
    return \@region_rows;
}

=head2 check_ads_validator

    入力値バリデートチェックに利用

=cut

sub check_ads_validator {
    my $self = shift;

    my $check_params = [
        url             => [ 'NOT_NULL', 'HTTP_URL', ],
        displaystart_on => [ 'NOT_NULL', 'DATE', ],
        displayend_on   => [ 'NOT_NULL', 'DATE', ],
        name       => [ 'NOT_NULL', [ 'LENGTH', 0, 30, ], ],
        content    => [ 'NOT_NULL', [ 'LENGTH', 0, 140, ], ],
        event_date => [ 'NOT_NULL', [ 'LENGTH', 0, 30, ], ],
    ];

    my $msg_params = [
        'url.not_null'             => '必須入力',
        'displaystart_on.not_null' => '必須入力',
        'displayend_on.not_null'   => '必須入力',
        'name.not_null'            => '必須入力',
        'content.not_null'         => '必須入力',
        'event_date.not_null'      => '必須入力',
        'url.http_url' => '指定の形式で入力してください',
        'displaystart_on.date' =>
            '日付の形式で入力してください',
        'displayend_on.date' => '日付の形式で入力してください',
        'name.length'        => '文字数!!',
        'content.length'     => '文字数!!',
        'event_date.length'  => '文字数!!',
    ];

    my $msg = $self->get_msg_validator( $check_params, $msg_params, );

    return if !$msg;

    return +{
        url             => $msg->{url},
        displaystart_on => $msg->{displaystart_on},
        displayend_on   => $msg->{displayend_on},
        name            => $msg->{name},
        content         => $msg->{content},
        event_date      => $msg->{event_date},
    };
}

=head2 writing_ads

    テーブル書込み、新規、修正、両方に対応

=cut

sub writing_ads {
    my $self   = shift;
    my $params = shift;

    my $create_data = +{
        kind            => $params->{kind},
        storeinfo_id    => $params->{storeinfo_id},
        region_id       => $params->{region_id},
        url             => $params->{url},
        displaystart_on => $params->{displaystart_on},
        displayend_on   => $params->{displayend_on},
        name            => $params->{name},
        event_date      => $params->{event_date},
        content         => $params->{content},
        create_on       => now_datetime(),
        modify_on       => now_datetime(),
    };
    return $self->writing_db( 'ads', $create_data, $params->{id} );
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
