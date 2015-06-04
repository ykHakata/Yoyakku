package Yoyakku::Controller::Mainte;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Mainte qw{switch_stash_mainte_list};
use Exporter 'import';
our @EXPORT_OK = qw{
    check_login_mainte
    switch_stash
};

# ログイン成功時に作成する初期値
sub switch_stash {
    my $self  = shift;
    my $id    = shift;
    my $table = shift;

    my $stash_mainte = switch_stash_mainte_list( $id, $table, );

    $self->stash($stash_mainte);

    return;
}

# ログインチェック
sub check_login_mainte {
    my $self = shift;

    my $login_id = $self->session->{root_id};

    # セッションないときは終了
    return 1 if !$login_id;

    return $self->switch_stash( $login_id, 'root' ) if $login_id;
}

# システム管理のオープニング画面
sub mainte_list {
    my $self = shift;

    # ログイン確認する
    return $self->redirect_to('/index') if $self->check_login_mainte();

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_list';
    $self->stash( class => $class );

    # ログイン確認時に取得したデータ取り出し
    my $login_data = $self->stash->{login_data};

    $self->stash( today => $login_data->{today} );

    return $self->render(
        template => 'mainte/mainte_list',
        format   => 'html',
    );
}

1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Controller::Mainte - システム管理者機能のコントローラー

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Controller::Mainte version 0.0.1

=head1 SYNOPSIS (概要)

システム管理者関連機能のリクエストをコントロール

=head2 mainte_list

    リクエスト
    URL: http:// ... /mainte_list
    METHOD: GET

    他詳細は調査、実装中

システム管理のオープニング画面

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Mainte>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
