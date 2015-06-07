package Yoyakku::Controller::Mainte::Roominfo;
use Mojo::Base 'Mojolicious::Controller';
use FormValidator::Lite;
use HTML::FillInForm;
use Yoyakku::Controller::Mainte qw{check_login_mainte switch_stash};
use Yoyakku::Model::Mainte::Roominfo qw{
    search_storeinfo_id_for_roominfo_rows
    search_roominfo_id_row
    writing_roominfo
    check_start_and_end_on
    check_rentalunit
};

# 部屋情報 一覧 検索
sub mainte_roominfo_serch {
    my $self = shift;

    # ログイン確認する
    return $self->redirect_to('/index') if $self->check_login_mainte();

     # テンプレートbodyのクラス名を定義
    my $class = 'mainte_roominfo_serch';
    $self->stash( class => $class );

    # id検索時のアクション (該当の店舗を検索)
    my $storeinfo_id = $self->param('storeinfo_id');

    # id 検索時は指定のid検索して出力
    my $roominfo_rows
        = $self->search_storeinfo_id_for_roominfo_rows($storeinfo_id);

    $self->stash( roominfo_rows => $roominfo_rows );

    return $self->render(
        template => 'mainte/mainte_roominfo_serch',
        format   => 'html',
    );
}

# 部屋情報 新規 編集
sub mainte_roominfo_new {
    my $self = shift;

    # ログイン確認する
    return $self->redirect_to('/index') if $self->check_login_mainte();

    # 編集のみを許可
    return $self->redirect_to('/mainte_roominfo_serch')
        if !$self->param('id');

    # テンプレートbodyのクラス名を定義
    my $class = 'mainte_roominfo_new';
    $self->stash( class => $class );

    # バリデート用
    $self->stash(
        name           => '',
        endingtime_on  => '',
        rentalunit     => '',
        pricescomments => '',
        remarks        => '',
    );

    my $params = $self->req->params->to_hash;
    my $method = uc $self->req->method;

    # 新規作成画面表示用
    return $self->_render_roominfo($params)
        if !$params->{id} && ( 'POST' ne $method );

    if ( 'POST' ne $method ) {

        # 修正画面表示用
        my $roominfo_row = $self->search_roominfo_id_row( $params->{id} );

        my $starttime_on;
        my $endingtime_on;

        # 開始、終了時刻はデータを調整する00->24表示にする
        if ( $roominfo_row->starttime_on ) {
            $starttime_on = substr( $roominfo_row->starttime_on, 0, 2 );
            $starttime_on += 0;
            if ( $starttime_on =~ /^[0-5]$/ ) {
                $starttime_on += 24;
            }
        }

        if ( $roominfo_row->endingtime_on ) {
            $endingtime_on = substr( $roominfo_row->endingtime_on, 0, 2 );
            $endingtime_on += 0;
            if ( $endingtime_on =~ /^[0-6]$/ ) {
                $endingtime_on += 24;
            }
        }

        # 入力フォームフィルイン用
        $params = +{
            id                => $roominfo_row->id,
            storeinfo_id      => $roominfo_row->storeinfo_id,
            name              => $roominfo_row->name,
            starttime_on      => $starttime_on,
            endingtime_on     => $endingtime_on,
            rentalunit        => $roominfo_row->rentalunit,
            time_change       => $roominfo_row->time_change,
            pricescomments    => $roominfo_row->pricescomments,
            privatepermit     => $roominfo_row->privatepermit,
            privatepeople     => $roominfo_row->privatepeople,
            privateconditions => $roominfo_row->privateconditions,
            bookinglimit      => $roominfo_row->bookinglimit,
            cancellimit       => $roominfo_row->cancellimit,
            remarks           => $roominfo_row->remarks,
            webpublishing     => $roominfo_row->webpublishing,
            webreserve        => $roominfo_row->webreserve,
            status            => $roominfo_row->status,
            create_on         => $roominfo_row->create_on,
            modify_on         => $roominfo_row->modify_on,
        };
    }

    # テンプレート画面のレンダリング
    return $self->_render_roominfo($params) if 'POST' ne $method;

    # 入力フォームに値を入力して登録するボタン押した場合
    # バリデード実行
    my $validator = FormValidator::Lite->new($params);

    $validator->check(
        name              => [ [ 'LENGTH', 0, 20, ], ],
        starttime_on      => [ [ 'LENGTH', 0, 20, ], ],
        endingtime_on     => [ [ 'LENGTH', 0, 20, ], ],
        rentalunit        => [ 'INT', ],
        time_change       => [ 'INT', ],
        pricescomments    => [ [ 'LENGTH', 0, 200, ], ],
        privatepermit     => [ 'INT', ],
        privatepeople     => [ 'INT', ],
        privateconditions => [ 'INT', ],
        bookinglimit      => [ 'INT', ],
        cancellimit       => [ 'INT', ],
        remarks           => [ [ 'LENGTH', 0, 200, ], ],
        webpublishing     => [ 'INT', ],
        webreserve        => [ 'INT', ],
        status            => [ 'INT', ],
    );

    $validator->set_message(
        'name.length'          => '文字数!!',
        'starttime_on.length'  => '文字数!!',
        'endingtime_on.length' => '文字数!!',
        'rentalunit.int'  => '指定の形式で入力してください',
        'time_change.int' => '指定の形式で入力してください',
        'pricescomments.length' => '文字数!!',
        'privatepermit.int' => '指定の形式で入力してください',
        'privatepeople.int' => '指定の形式で入力してください',
        'privateconditions.int' =>
            '指定の形式で入力してください',
        'bookinglimit.int'  => '指定の形式で入力してください',
        'cancellimit.int'   => '指定の形式で入力してください',
        'remarks.length'    => '文字数!!',
        'webpublishing.int' => '指定の形式で入力してください',
        'webreserve.int'    => '指定の形式で入力してください',
        'status.int'        => '指定の形式で入力してください',
    );

    my @name_errors = $validator->get_error_messages_from_param('name');
    my @starttime_on_errors
        = $validator->get_error_messages_from_param('starttime_on');
    my @endingtime_on_errors
        = $validator->get_error_messages_from_param('endingtime_on');
    my @rentalunit_errors
        = $validator->get_error_messages_from_param('rentalunit');
    my @time_change_errors
        = $validator->get_error_messages_from_param('time_change');
    my @pricescomments_errors
        = $validator->get_error_messages_from_param('pricescomments');
    my @privatepermit_errors
        = $validator->get_error_messages_from_param('privatepermit');
    my @privatepeople_errors
        = $validator->get_error_messages_from_param('privatepeople');
    my @privateconditions_errors
        = $validator->get_error_messages_from_param('privateconditions');
    my @bookinglimit_errors
        = $validator->get_error_messages_from_param('bookinglimit');
    my @cancellimit_errors
        = $validator->get_error_messages_from_param('cancellimit');
    my @remarks_errors = $validator->get_error_messages_from_param('remarks');
    my @webpublishing_errors
        = $validator->get_error_messages_from_param('webpublishing');
    my @webreserve_errors
        = $validator->get_error_messages_from_param('webreserve');
    my @status_errors = $validator->get_error_messages_from_param('status');

    # バリデート用メッセージ
    $self->stash(
        name              => shift @name_errors,
        starttime_on      => shift @starttime_on_errors,
        endingtime_on     => shift @endingtime_on_errors,
        rentalunit        => shift @rentalunit_errors,
        time_change       => shift @time_change_errors,
        pricescomments    => shift @pricescomments_errors,
        privatepermit     => shift @privatepermit_errors,
        privatepeople     => shift @privatepeople_errors,
        privateconditions => shift @privateconditions_errors,
        bookinglimit      => shift @bookinglimit_errors,
        cancellimit       => shift @cancellimit_errors,
        remarks           => shift @remarks_errors,
        webpublishing     => shift @webpublishing_errors,
        webreserve        => shift @webreserve_errors,
        status            => shift @status_errors,
    );

    # 入力バリデート不合格の場合それ以降の作業はしない
    return $self->_render_roominfo($params) if $validator->has_error();

    if ( $params->{id} ) {
        # DB バリデート合格の場合 DB 書き込み(修正)

        # starttime_on, endingtime_on, 営業時間のバリデート
        my $check_start_and_end_msg = $self->check_start_and_end_on(
            $params->{starttime_on},
            $params->{endingtime_on},
        );

        if ($check_start_and_end_msg) {

            $self->stash->{endingtime_on} = $check_start_and_end_msg;
            return $self->_render_roominfo($params);
        }

        # starttime_on, endingtime_on, rentalunit, 貸出単位のバリデート
        my $check_rentalunit_msg = $self->check_rentalunit(
            $params->{starttime_on},
            $params->{endingtime_on},
            $params->{rentalunit},
        );

        if ($check_rentalunit_msg) {
            $self->stash->{rentalunit} = $check_rentalunit_msg;
            return $self->_render_roominfo($params);
        }

        $self->writing_roominfo( 'update', $params );
        $self->flash( henkou => '修正完了' );

        # sqlにデータ入力したので list 画面にリダイレクト
        return $self->redirect_to('mainte_roominfo_serch');
    }

    return _render_roominfo($params);
}

# テンプレート画面のレンダリング
sub _render_roominfo {
    my $self   = shift;
    my $params = shift;

    my $html = $self->render_to_string(
        template => 'mainte/mainte_roominfo_new',
        format   => 'html',
    )->to_string;

    my $output = HTML::FillInForm->fill( \$html, $params );

    return $self->render( text => $output );
}

1;

__END__

roominfoの入力フォームについて
select形式にする->開始時刻、終了時刻、貸出単位、個人練習許可設定、個人練習許可人数、
個人練習許可条件、予約制限、キャンセル制限、web公開設定、web予約受付、ステータス
内容を定義する
開始時刻、終了時刻
-> 開始 6:00-29:00 終了 7:00-30:00
貸出単位
-> 1時間、２時間、#
個人練習許可設定
-> 0 許可する 1 許可しない
個人練習許可人数
-> 1 1人まで 2 2人まで 3 3人まで
個人練習許可条件
-> 0 当日予約のみ 1 １日前より 2 ２日前より 3 ３日前より 4 ４日前より
  5 ５日前より 6 ６日前より 7 ７日前より 8 条件なし
予約制限(指定の時間になると予約不可)
-> 0 制限なし 1 １時間前 2 ２時間前 3 ３時間前
キャンセル制限(ネット上でキャンセルできる制限)
-> 0 当日不可 1 １日前不可 2 ２日前不可 3 ３日前不可 4 ４日前不可
  5 ５日前不可 6 ６日前不可 7 ７日前不可 8 制限なし
web公開設定
-> 0 公開する 1 公開しない
web予約受付
-> 0 今月のみ 1 １ヶ月先 2 ２ヶ月先 3 ３ヶ月先
ステータス
-> 0 利用停止 1 利用開始
管理ユーザーの承認が出来た時点で、
店舗id(storeinfo)１件と
部屋情報(roominfo)１０件を自動的に作った方がよい
そのスクリプトを考える
