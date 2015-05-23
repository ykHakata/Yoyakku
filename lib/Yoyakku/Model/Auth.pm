package Yoyakku::Model::Auth;
use strict;
use warnings;
use utf8;
use Exporter 'import';
our @EXPORT_OK = qw{
    check_valid_login
};
use Yoyakku::Model qw{$teng};

sub check_valid_login {
    my $self   = shift;
    my $table  = shift;
    my $params = shift;

    die 'check_valid_login' if !$self || !$table || !$params;

    my $check_valid = +{
        error         => undef,
        session_id    => undef,
        check_profile => undef,
        msg           => +{
            login    => '',
            password => '',
        },
    };

    my $row = $teng->single( $table, +{ login => $params->{login} } );

    # 不合格の場合 (DB検証 メルアド違い)
    if ( !$row ) {
        $check_valid->{msg}->{login} = 'メールアドレス違い';
        $check_valid->{error} = 1;
    }

    return $check_valid if $check_valid->{error};

    # 不合格の場合 (DB検証 パスワード違い)
    if ( $row->password ne $params->{password} ) {
        $check_valid->{msg}->{password} = 'パスワードが違います';
        $check_valid->{error} = 1;
    }

    return $check_valid if $check_valid->{error};

    $check_valid->{session_id} = $row->id;

    # リダイレクト先を選択するための検証(profile テーブル)
    my $search_column
        = $table eq 'general' ? 'general_id'
        : $table eq 'admin'   ? 'admin_id'
        :                       '';

    my $profile_row
        = $teng->single( 'profile', +{ $search_column => $row->id } );

    if ( !$profile_row ) {
        $check_valid->{msg}->{login} = '管理者へ連絡ください';
        $check_valid->{error} = 1;
    }

    return $check_valid if $check_valid->{error};

    # profile の設定確認
    $check_valid->{check_profile} = 'profile';
    if ( $profile_row->status ) {
        $check_valid->{check_profile} = 'index';
    }

    return $check_valid;
}


1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model::Auth - ログイン API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Auth version 0.0.1

=head1 SYNOPSIS (概要)

    use Yoyakku::Model::Auth qw{check_valid_login};

    my $check_valid = $self->check_valid_login($table, $params);

    # エラーメッセージ作成
    $self->stash->{login}    = $check_valid->{msg}->{login};
    $self->stash->{password} = $check_valid->{msg}->{password};

    # DB 検索のバリデーションエラー確認
    $check_valid->{error}; # undef or '1'

    # セッション書き込み用 id 提供
    $self->session( $session_name => $check_valid->{session_id} );

    # 検索結果の id の profile 情報の有無を確認、遷移先を指示
    $check_valid_login_routing->{redirect_to} = $check_valid->{check_profile};

    $check_valid->{check_profile}; # 'index' or 'profile'

認証関連の API を提供

=head1 DEPENDENCIES (依存モジュール)

=over 2

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Yoyakku::Guides>
