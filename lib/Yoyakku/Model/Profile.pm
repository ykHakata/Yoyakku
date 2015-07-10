package Yoyakku::Model::Profile;
use strict;
use warnings;
use utf8;
use Time::Piece;
use Time::Seconds;
use Yoyakku::Util qw{switch_header_params};
use Exporter 'import';
our @EXPORT_OK = qw{
    switch_stash_profile
};
use parent 'Yoyakku::Model';

sub _init {
    my $model = Yoyakku::Model::Profile->new();
    return $model;
}

# ログイン成功時に作成する初期値
sub switch_stash_profile {
    my $id    = shift;
    my $table = shift;

    my $model = _init();
    my $teng  = $model->teng();

    # id table ないとき強制終了
    die 'not id table!: ' if !$id || !$table;

    my $row = $teng->single( $table, +{ id => $id } );

    # row ないときは強制終了
    die 'not row!: ' if !$row;

    # ヘッダー表示用の名前
    my $table_id = $table . '_id';

    my $profile_row
        = $teng->single( 'profile', +{ $table_id => $id } );

    my $login_name = $profile_row->nick_name;

    if ($table eq 'admin') {
        $login_name = q{(admin)} . $login_name;
    }

    # ヘッダーの切替(初期値 8 ステータスなし、承認されてない)
    my $switch_header = 8;

    # ステータスあり(admin 7, general 6)
    if ( $row->status ) {

        $switch_header = $table eq 'admin'   ? 7
                       : $table eq 'general' ? 6
                       :                       8;

        if ($table eq 'admin') {
            my $storeinfo_row
                = $teng->single( 'storeinfo', +{ admin_id => $id } );

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
        login_data => +{    # 初期値表示のため
            login         => $table,            # ログイン種別識別
            login_row     => $row,              # ログイン者情報
            profile_row   => $profile_row,      # プロフィール情報
            login_name    => $login_name,       # ログイン名
            switch_header => $switch_header,    # 切替
        },
        %{$header_params_hash_ref},             # ヘッダー各値
    };

    return $stash_profile;
}

1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model::Profile - プロフィール用 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Profile version 0.0.1

=head1 SYNOPSIS (概要)

profile コントローラーのロジック API

=head2 switch_stash_profile

    use Yoyakku::Model::Profile qw{switch_stash_profile};

    # スタッシュに引き渡す値を作成
    my $stash_profile = switch_stash_profile( $id, $table, );

    $self->stash($stash_profile);

profile アクションログイン時の初期値作成

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<Time::Piece>

=item * L<Time::Seconds>

=item * L<Yoyakku::Model>

=item * L<Yoyakku::Util>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
