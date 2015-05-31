package Yoyakku::Controller::Mainte;
use Mojo::Base 'Mojolicious::Controller';
use FormValidator::Lite;
use HTML::FillInForm;
use Yoyakku::Model::Mainte qw{switch_stash_mainte_list};
use Yoyakku::Model qw{$teng};
use Yoyakku::Util qw{now_datetime};

# ログイン成功時に作成する初期値
sub _switch_stash {
    my $self  = shift;
    my $id    = shift;
    my $table = shift;

    my $stash_mainte = switch_stash_mainte_list( $id, $table, );

    $self->stash($stash_mainte);

    return;
}

# ログインチェック
sub _check_login_mainte {
    my $self = shift;

    my $login_id = $self->session->{root_id};

    # セッションないときは終了
    return 1 if !$login_id;

    return $self->_switch_stash( $login_id, 'root' ) if $login_id;
}

# システム管理のオープニング画面
sub mainte_list {
    my $self = shift;

    # ログイン確認する
    return $self->redirect_to('/index') if $self->_check_login_mainte();

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

# 管理ユーザー(admin) registrant_serch.html.ep
sub mainte_registrant_serch {
    my $self = shift;

    # ログイン確認する
    return $self->redirect_to('/index') if $self->_check_login_mainte();

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_registrant_serch';
    $self->stash( class => $class );

    # id検索時のアクション
    my $admin_id = $self->param('admin_id');

    # id 検索時は指定のid検索して出力
    my $admin_rows = $self->_search_admin_rows($admin_id);

    $self->stash( admins_ref => $admin_rows );

    return $self->render(
        template => 'mainte/mainte_registrant_serch',
        format   => 'html',
    );
}

# 管理ユーザー 新規 編集 (admin) registrant_new.html.ep
sub mainte_registrant_new {
    my $self = shift;

    # ログイン確認する
    return $self->redirect_to('/index') if $self->_check_login_mainte();

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_registrant_new';
    $self->stash( class => $class );

    # バリデート用
    $self->stash(
        login    => '',
        password => '',
    );

    my $req    = $self->req;
    my $params = $req->params->to_hash;
    my $method = uc $req->method;

    # id 指定して編集する場合
    if ( 'GET' eq $method && $params->{id} ) {

        my $admin_row = $self->_search_admin_row( $params->{id} );

        # 入力フォームフィルイン用
        $params = +{
            id        => $admin_row->id,
            login     => $admin_row->login,
            password  => $admin_row->password,
            status    => $admin_row->status,
            create_on => $admin_row->create_on,
            modify_on => $admin_row->modify_on,
        };
    }

    # 入力フォームに値を入力して登録するボタン押した場合
    if ( 'POST' eq $method ) {

        # バリデード実行
        my $validator = FormValidator::Lite->new($req);

        $validator->check(
            login    => [ 'NOT_NULL', ],
            password => [ 'NOT_NULL', ],
        );

        $validator->set_message(
            'login.not_null'    => '必須入力',
            'password.not_null' => '必須入力',
        );

        my @login_errors = $validator->get_error_messages_from_param('login');
        my @pass_errors  = $validator->get_error_messages_from_param('password');

        $self->stash->{login}    = shift @login_errors;
        $self->stash->{password} = shift @pass_errors;

        # 入力バリデート不合格の場合それ以降の作業はしない
        if ( $validator->has_error() ) {

            # テンプレート画面のレンダリング
            my $html = $self->render_to_string(
                template => 'mainte/mainte_registrant_new',
                format   => 'html',
            )->to_string;

            my $output = HTML::FillInForm->fill( \$html, $params );

            return $self->render( text => $output );
        }

        # ログイン名(メルアド)の既存データとの照合
        # 既存データとの照合(DB バリデートチェック)
        if ( $params->{id} ) {
            # DB バリデート合格の場合 DB 書き込み(修正)
            $self->_writing_admin( 'update', $params );
            $self->flash( henkou => '修正完了' );
        }
        else {
            # DB バリデート合格の場合 DB 書き込み(新規)

            my $admin_row
                = $teng->single( 'admin',
                +{ login => $req->param('login'), }, );

            if ($admin_row) {

                # ログイン名がすでに存在している
                $self->stash->{login} = '既に使用されてます';

                # テンプレート画面のレンダリング
                my $html = $self->render_to_string(
                    template => 'mainte/mainte_registrant_new',
                    format   => 'html',
                )->to_string;

                my $output = HTML::FillInForm->fill( \$html, $params );

                return $self->render( text => $output );
            }

            $self->_writing_admin( 'insert', $params );
            $self->flash( touroku => '登録完了' );
        }

        # sqlにデータ入力したので list 画面にリダイレクト
        return $self->redirect_to('mainte_registrant_serch');
    }

    # テンプレート画面のレンダリング
    my $html = $self->render_to_string(
        template => 'mainte/mainte_registrant_new',
        format   => 'html',
    )->to_string;

    my $output = HTML::FillInForm->fill( \$html, $params );

    return $self->render( text => $output );
}

sub _writing_admin {
    my $self   = shift;
    my $type   = shift;
    my $params = shift;

    my $create_data_admin = +{
        login     => $params->{login},
        password  => $params->{password},
        status    => $params->{status},
        create_on => now_datetime(),
        modify_on => now_datetime(),
    };

    my $insert_admin_row;

    if ($type eq 'insert') {

        $insert_admin_row = $teng->insert( 'admin', $create_data_admin, );

    }
    elsif ($type eq 'update') {

        $insert_admin_row
            = $teng->single( 'admin', +{ id => $params->{id} }, );

        $insert_admin_row->update($create_data_admin);
    }

    die 'not $insert_admin_row' if !$insert_admin_row;

    # status: (0: 未承認, 1: 承認済み, 2: 削除済み)
    # 今作った管理者IDでステータスが1 (承認済み) で
    # storeinfo に今作った管理者 id が存在しないときは、
    # 新たに storeinfo にデータ作成し、
    # 今作った管理者 id を入力しておく
    # 作成時刻が一番新しい管理者 id を取得する
    # 今作った管理者 id の id とステータスを取り出し
    my $new_admin_id     = $insert_admin_row->id;
    my $new_admin_status = $insert_admin_row->status;

    # 承認済み 1 の場合該当の storeinfo のデータを検索
    if ($new_admin_status eq '1') {
        my $storeinfo_row
            = $teng->single( 'storeinfo',
            +{ admin_id => $new_admin_id, }, );

        # storeinfo 見つからないときは新規にレコード作成
        if (!$storeinfo_row) {

            my $create_data_storeinfo = +{
                admin_id  => $new_admin_id,
                status    => 1,
                create_on => now_datetime(),
                modify_on => now_datetime(),
            };

            my $insert_storeinfo_row
                = $teng->insert( 'storeinfo', $create_data_storeinfo, );

            # roominfo を 10 件作成
            my $create_data_roominfo = +{
                storeinfo_id   => $insert_storeinfo_row->id,
                name           => undef,
                starttime_on   => '10:00',
                endingtime_on  => '22:00',
                time_change    => 0,
                rentalunit     => 1,
                pricescomments => '例）１時間２０００円より',
                privatepermit  => 0,
                privatepeople  => 2,
                privateconditions => 0,
                bookinglimit      => 0,
                cancellimit       => 8,
                remarks =>
                    '例）スタジオ内の飲食は禁止です。',
                webpublishing => 1,
                webreserve    => 3,
                status        => 0,
                create_on     => now_datetime(),
                modify_on     => now_datetime(),
            };

            for my $i ( 1 .. 10 ) {
                $teng->fast_insert( 'roominfo', $create_data_roominfo, );
            }
        }
    }

    return;
}

sub _search_admin_rows {
    my $self     = shift;
    my $admin_id = shift;

    my @admin_rows;

    if ( defined $admin_id ) {
        @admin_rows = $teng->search( 'admin', +{ id => $admin_id, }, );
        if ( !scalar @admin_rows ) {

            # id 検索しないときはテーブルの全てを出力
            @admin_rows = $teng->search( 'admin', +{}, );
        }
    }
    else {
        # id 検索しないときはテーブルの全てを出力
        @admin_rows = $teng->search( 'admin', +{}, );
    }

    return \@admin_rows;
}

sub _search_admin_row {
    my $self     = shift;
    my $admin_id = shift;

    die 'not $admin_id!!' if !$admin_id;

    my $admin_row = $teng->single( 'admin', +{ id => $admin_id, }, );

    die 'not $admin_row!!' if !$admin_row;

    return $admin_row;
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

=over 2

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<FormValidator::Lite>

=item * L<HTML::FillInForm>

=item * L<Yoyakku::Model::Mainte>

=item * L<Yoyakku::Model>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Yoyakku::Guides>

=cut
