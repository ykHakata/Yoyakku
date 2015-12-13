package Yoyakku::Controller::Admin;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Admin;

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Admin - 店舗管理のコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Admin version 0.0.1

=head1 SYNOPSIS (概要)

    店舗管理、関連機能のリクエストをコントロール

=cut

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Admin->new();
    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session );
    $model->check_auth_db_yoyakku();
    my $header_stash = $model->get_header_stash_admin();
    return $header_stash if $header_stash eq 'index';
    return $header_stash if $header_stash eq 'profile';
    $self->stash($header_stash);
    return $model;
}

=head2 admin_store_edit

    選択店舗情報確認コントロール

=cut

sub admin_store_edit {
    my $self = shift;

    my $model = $self->_init();
    return $self->redirect_to($model) if $model eq 'index';
    return $self->redirect_to($model) if $model eq 'profile';
    return $self->redirect_to('index')
        if ( $model->method() ne 'GET' ) && ( $model->method() ne 'POST' );

    my $init_valid_params_admin_store_edit
        = $model->get_init_valid_params_admin_store_edit();

    my $switch_com = $model->get_switch_com('admin_store_edit');
    $self->stash(
        class      => 'admin_store_edit',
        switch_com => $switch_com,
        %{$init_valid_params_admin_store_edit},
    );

    $model->template('admin/admin_store_edit');

    if ( 'GET' eq $model->method() ) {
        $model->get_login_storeinfo_params();
        return $self->_render_admin_store_edit($model);
    }
    my $params = $model->params();
    return $self->_cancel($model)      if $params->{cancel};
    return $self->_post_search($model) if $params->{post_search};
    return $self->_update($model);
}

sub _cancel {
    my $self  = shift;
    my $model = shift;
    $model->get_login_storeinfo_id();
    return $self->_render_admin_store_edit($model);
}

sub _post_search {
    my $self  = shift;
    my $model = shift;
    $model->get_post_search();
    return $self->_render_admin_store_edit($model);
}

sub _update {
    my $self  = shift;
    my $model = shift;
    $model->type('update');
    return $self->_common($model);
}

sub _common {
    my $self  = shift;
    my $model = shift;

    my $valid_msg = $model->check_admin_store_validator();

    return $self->stash($valid_msg), $self->_render_admin_store_edit($model)
        if $valid_msg;

    $model->writing_admin_store();

    return $self->redirect_to('admin_store_comp');
}

sub _render_admin_store_edit {
    my $self  = shift;
    my $model = shift;

    my $html = $self->render_to_string(
        template => $model->template(),
        format   => 'html',
    )->to_string;

    $model->html( \$html );
    my $output = $model->get_fill_in_admin();
    return $self->render( text => $output );
}

sub admin_store_comp {
    my $self = shift;

    my $model = $self->_init();
    return $self->redirect_to($model) if $model eq 'index';
    return $self->redirect_to($model) if $model eq 'profile';
    return $self->redirect_to('index')
        if ( $model->method() ne 'GET' ) && ( $model->method() ne 'POST' );

    my $switch_com = $model->get_switch_com('admin_store_comp');
    $self->stash(
        class         => 'admin_store_comp',
        switch_com    => $switch_com,
        storeinfo_row => $model->login_storeinfo_row,
    );
    $self->render( template => 'admin/admin_store_comp', format => 'html' );
    return;
}

sub admin_reserv_edit {
    my $self = shift;

    my $model = $self->_init();
    return $self->redirect_to($model) if $model eq 'index';
    return $self->redirect_to($model) if $model eq 'profile';
    return $self->redirect_to('index')
        if ( $model->method() ne 'GET' ) && ( $model->method() ne 'POST' );

    my $init_valid_params_admin_reserv_edit
        = $model->get_init_valid_params_admin_reserv_edit();

    my $switch_com = $model->get_switch_com('admin_reserv_edit');
    $self->stash(
        class         => 'admin_reserv_edit',
        switch_com    => $switch_com,
        %{$init_valid_params_admin_reserv_edit},
    );
    $model->set_roominfo_params();
    $model->template('admin/admin_reserv_edit');
    $self->_render_admin_store_edit($model);
    return;
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Admin>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut






#admin_reserv_edit.html.ep
#予約部屋情報設定コントロール-----------------------------
any '/admin_reserv_edit' => sub {
my $self = shift;
# テンプレートbodyのクラス名を定義
#my $class = "admin_store_comp";
my $class = "admin_reserv_edit";
$self->stash(class => $class);

##----------
#手順を考えてみる
#管理者ログインidを取得
##ログインidからstoreinfoのテーブルより該当テーブル抽出
my @storeinfo = $teng->single('storeinfo', {'admin_id' => $login_id });
my $storeinfo_id;
for my $storeinfo (@storeinfo) {# id検索、sql実行店舗id取得
    $storeinfo_id = $storeinfo->id ;
}
#店舗idから部屋idを１０件取得(管理者承認が終わった時点でデータできてる)
my @rows = $teng->search('roominfo', {'storeinfo_id' => $storeinfo_id },{order_by => 'id'});
#$self->stash(rows_ref => \@rows);
#sqlで該当roominfoをid若い順に取り出し、
    my (@id,@storeinfo_id,@name,@starttime_on,@endingtime_on,@time_change,@rentalunit,
        @pricescomments,@privatepermit,@privatepeople,@privateconditions,
        @bookinglimit,@cancellimit,@remarks,@webpublishing,@webreserve,@status,
        @create_on,@modify_on,);
#my @pricescomments;
        foreach my $row (@rows) {
            push (@id                , $row->id);
#            push (@storeinfo_id      , $row->storeinfo_id);
            push (@name              , $row->name);
            my $starttime_on = $row->starttime_on;
            #開始、終了時刻はデータを調整する00->24表示にする
            if ($starttime_on) {
                $starttime_on = substr($starttime_on,0,2);
                $starttime_on += 0;
                if ($starttime_on =~ /^[0-5]$/) {
                    $starttime_on += 24;
                }
            }
            push (@starttime_on      , $starttime_on);

            my $endingtime_on = $row->endingtime_on;
            if ($endingtime_on) {
                $endingtime_on = substr($endingtime_on,0,2);
                $endingtime_on += 0;
                if ($endingtime_on =~ /^[0-6]$/) {
                    $endingtime_on += 24;
                }
            }
            push (@endingtime_on     , $endingtime_on);
            push (@time_change       , $row->time_change);
            push (@rentalunit        , $row->rentalunit);
            push (@pricescomments    , $row->pricescomments);
            push (@privatepermit     , $row->privatepermit);
            push (@privatepeople     , $row->privatepeople);
            push (@privateconditions , $row->privateconditions);
            push (@bookinglimit      , $row->bookinglimit);
            push (@cancellimit       , $row->cancellimit);
            push (@remarks           , $row->remarks);
#            push (@webpublishing     , $row->webpublishing);
#            push (@webreserve        , $row->webreserve);
#            push (@status            , $row->status);
#            push (@create_on         , $row->create_on);
#            push (@modify_on         , $row->modify_on);
        }


#    #修正用フォーム、Fillinつかって表示 値はsqlより該当idのデータをつかう
    my $html = $self->render_partial()->to_string;
    $html = HTML::FillInForm->fill(
        \$html,{
            id                => \@id,
#            storeinfo_id      => \@storeinfo_id,
            name              => \@name,
            starttime_on      => \@starttime_on,
            endingtime_on     => \@endingtime_on,
            time_change       => \@time_change,
            rentalunit        => \@rentalunit,
            pricescomments    => \@pricescomments,
            privatepermit     => \@privatepermit,
            privatepeople     => \@privatepeople,
            privateconditions => \@privateconditions,
            bookinglimit      => \@bookinglimit,
            cancellimit       => \@cancellimit,
            remarks           => \@remarks,
#            webpublishing     => \@webpublishing,
#            webreserve        => \@webreserve,
#            status            => \@status,
#            create_on         => \@create_on,
#            modify_on         => \@modify_on
        },
    );

# バリデート、sqlへ入力、次の画面遷移までの手順を考えてみる
# post判定,getの場合、fillinでrender
if (uc $self->req->method eq 'POST') {
    #submitボタン判定、キャンセルの時は空の値、完了の時バリデート
    my $cancel = $self->param('cancel');
    #キャンセルボタンの場合
    if ($cancel) {
        #値をすべて空にする(idだけは残す)
        my @id = $self->param('id');
        my @name                  ;
        my @starttime_on          ;
        my @endingtime_on         ;
        my @time_change           ;
        my @rentalunit            ;
        my @pricescomments        ;
        my @privatepermit         ;
        my @privatepeople         ;
        my @privateconditions     ;
        my @bookinglimit          ;
        my @cancellimit           ;
        my @remarks               ;
        #修正用フォーム、Fillinつかって表示 値はsql空を送る
        my $html = $self->render_partial()->to_string;
        $html = HTML::FillInForm->fill(
            \$html,{
                id                => \@id                ,
                name              => \@name              ,
                starttime_on      => \@starttime_on      ,
                endingtime_on     => \@endingtime_on     ,
                time_change       => \@time_change       ,
                rentalunit        => \@rentalunit        ,
                pricescomments    => \@pricescomments    ,
                privatepermit     => \@privatepermit     ,
                privatepeople     => \@privatepeople     ,
                privateconditions => \@privateconditions ,
                bookinglimit      => \@bookinglimit      ,
                cancellimit       => \@cancellimit       ,
                remarks           => \@remarks           ,
            },
        );
        #Fillin画面表示実行returnなのでここでおしまい。
        return $self->render_text($html, format => 'html');
    }
    #完了ボタンの場合バリデーション実行
    else {
    #完了の場合バリデート実行
    my $validator = $self->create_validator;# バリデーション()

    $validator->field('name'          )->required(1)->callback(sub {
        my $value = shift;
        my @name = $self->param('name');

        for my $name (@name) {
            return (0, '空白文字は不可') if ( $name =~ m{ \s }xm   );
            return (0, '２文字まで'    ) if ( $name =~ m/.{3,}?/xm );
        }
        return 1 ;
    });


    #営業時間バリデート
    $validator->field('endingtime_on' )->callback(sub {
        my $value = shift;
        my @id            = $self->param('id');
        my @starttime_on  = $self->param('starttime_on');
        my @endingtime_on = $self->param('endingtime_on');

        for my $id (@id) {
            my $judg_starttime   = shift @starttime_on ;
            my $judg_endingtime  = shift @endingtime_on;
            if ($judg_starttime >= $judg_endingtime) {
                return (0, '開始時刻より遅くしてください');
            }
        }
        return 1 ;
    });
    #貸出単位のバリデート
    $validator->field('rentalunit'    )->callback(sub {
        my $value = shift;

        my @id            = $self->param('id');
        my @starttime_on  = $self->param('starttime_on');
        my @endingtime_on = $self->param('endingtime_on');
        my @rentalunit    = $self->param('rentalunit');

        for my $id (@id) {
            my $judg_starttime   = shift @starttime_on ;
            my $judg_endingtime  = shift @endingtime_on;
            my $judg_rentalunit  = shift @rentalunit;

            my $opening_hours      = $judg_endingtime - $judg_starttime;
            my $judg_opening_hours = $opening_hours % $judg_rentalunit;

            if ( $judg_opening_hours ) {
                return (0, '営業時間が割り切れません');
            die "hoge";
            }
        }
        return 1 ;
    });

    $validator->field('pricescomments')->required(1)->callback(sub {
        my $value = shift;
        my @id             = $self->param('id');
        my @pricescomments = $self->param('pricescomments');

        for my $id (1..4) {
            my $judg_pricescomments = shift @pricescomments ;
            return (0, '２０文字まで')
                if ( $judg_pricescomments =~ m/.{21,}?/xm );
        }
        return 1 ;
    });

    #mojoのコマンドでパラメーターをハッシュで取得入力した値をFIllin時に使うため、
    my $param_hash = $self->req->params->to_hash;
    $self->stash(param_hash => $param_hash);


    #入力検査合格、の時、修正アップロード実行
    if ( $self->validate($validator,$param_hash) ) {
        #入力値を全部受け取っておく念のために時刻取得
        my $today = localtime;
        # 入力フォームから受ける値変数
        my @id                = $self->param('id');
        #my @storeinfo_id      = $self->param('storeinfo_id');
        my @name              = $self->param('name');
        my @starttime_on      = $self->param('starttime_on');
        my @endingtime_on     = $self->param('endingtime_on');
        my @time_change       = $self->param('time_change');
        my @rentalunit        = $self->param('rentalunit');
        my @pricescomments    = $self->param('pricescomments');
        my @privatepermit     = $self->param('privatepermit');
        my @privatepeople     = $self->param('privatepeople');
        my @privateconditions = $self->param('privateconditions');
        #my @bookinglimit      = $self->param('bookinglimit');
        #my @cancellimit       = $self->param('cancellimit');
        #my @remarks           = $self->param('remarks');
#        my @webpublishing     = $self->param('webpublishing');
#        my @webreserve        = $self->param('webreserve');
#        my @status            = $self->param('status');
#        my @create_on         = $self->param('create_on');
#        my @modify_on         = $today->datetime(date => '-', T => ' ');
        # 修正日付の配列をつくる
        my $modify_on = $today->datetime(date => '-', T => ' ');
        my @modify_on;
        for my $i (@id) {
            push (@modify_on,$modify_on);
        }
        #nameに空白が含まれた場合取り除いておく
        my @s_name;
        foreach my $name (@name) {
            if ($name =~ /^\s+$/) {
                $name =~ s/\s+//;
                push (@s_name,$name);
            }
            elsif ($name =~ /\s+./) {
                $name =~ s/\s+//;
                push (@s_name,$name);
            }
            elsif ($name =~ /.\s+/) {
                $name =~ s/\s+//;
                push (@s_name,$name);
            }
            else {
                push (@s_name,$name);
            }
        }
        my @name = @s_name;

        #sql書き込む前に開始、終了時刻変換
        my @conver_starttime_on;
        foreach my $starttime_on (@starttime_on) {
            if ($starttime_on =~ /^[2][4-9]$/) {
                $starttime_on -= 24;
                $starttime_on .= ":00";
                push (@conver_starttime_on,$starttime_on);
            } else {
                $starttime_on .= ":00";
                push (@conver_starttime_on,$starttime_on);
            }
        }
        my @starttime_on = @conver_starttime_on;

        my @conver_endingtime_on;
        foreach my $endingtime_on (@endingtime_on) {
            if ($endingtime_on =~ /^[2][4-9]$|^[3][0]$/) {
                $endingtime_on -= 24;
                $endingtime_on .= ":00";
                push (@conver_endingtime_on,$endingtime_on);
            } else {
                $endingtime_on .= ":00";
                push (@conver_endingtime_on,$endingtime_on);
            }
        }
        my @endingtime_on = @conver_endingtime_on;

        my $name             ;
        my $starttime_on     ;
        my $endingtime_on    ;
        my $time_change      ;
        my $rentalunit       ;
        my $pricescomments   ;
        my $privatepermit    ;
        my $privatepeople    ;
        my $privateconditions;
        #my $bookinglimit     ;
        #my $cancellimit      ;
        #my $remarks          ;
        my $modify_on        ;
        # $idのあるだけ繰り返しsqlへアップデート
        foreach my $id (@id) {
            $name              = shift @name             ;
            $starttime_on      = shift @starttime_on     ;
            $endingtime_on     = shift @endingtime_on    ;
            $time_change       = shift @time_change      ;
            $rentalunit        = shift @rentalunit       ;
            $pricescomments    = shift @pricescomments   ;
            $privatepermit     = shift @privatepermit    ;
            $privatepeople     = shift @privatepeople    ;
            $privateconditions = shift @privateconditions;
            #$bookinglimit      = shift @bookinglimit     ;
            #$cancellimit       = shift @cancellimit      ;
            #$remarks           = shift @remarks          ;
            $modify_on         = shift @modify_on        ;
            #name(部屋名)が存在するときだけ書き込みするように
            if ($name) {
                my $count = $teng->update( #修正データをsqlへ送り込み,status->1(利用開始)
                    'roominfo' => {
                        #'storeinfo_id'      => $storeinfo_id,
                        'name'              => $name,
                        'starttime_on'      => $starttime_on,
                        'endingtime_on'     => $endingtime_on,
                        'time_change'       => $time_change,
                        'rentalunit'        => $rentalunit,
                        'pricescomments'    => $pricescomments,
                        'privatepermit'     => $privatepermit,
                        'privatepeople'     => $privatepeople,
                        'privateconditions' => $privateconditions,
                        #'bookinglimit'      => $bookinglimit,
                        #'cancellimit'       => $cancellimit,
                        #'remarks'           => $remarks,
                        #'webpublishing'     => $webpublishing,
                        #'webreserve'        => $webreserve,
                        'status'            => 1,
                        #'create_on'         => $create_on,
                        'modify_on'         => $modify_on,
                    },{
                        'id' => $id,
                    }
                );
            }
            #name無いときはstatus->0(利用不可)にしておく
            else {
                my $count = $teng->update(
                    'roominfo' => {
                        #'storeinfo_id'      => $storeinfo_id,
                        'name'              => $name,
                        'starttime_on'      => $starttime_on,
                        'endingtime_on'     => $endingtime_on,
                        'time_change'       => $time_change,
                        'rentalunit'        => $rentalunit,
                        'pricescomments'    => $pricescomments,
                        'privatepermit'     => $privatepermit,
                        'privatepeople'     => $privatepeople,
                        'privateconditions' => $privateconditions,
                        #'bookinglimit'      => $bookinglimit,
                        #'cancellimit'       => $cancellimit,
                        #'remarks'           => $remarks,
                        #'webpublishing'     => $webpublishing,
                        #'webreserve'        => $webreserve,
                        'status'            => 0,
                        #'create_on'         => $create_on,
                        'modify_on'         => $modify_on,
                    },{
                        'id' => $id,
                    }
                );
            }
        }
        #sqlにデータ入力したのでリダイレクト
        return $self->redirect_to('up_admin_r_d_edit');
        #リターンなのでここでおしまい。
    }
    #入力検査合格しなかった場合、もう一度入力フォーム表示Fillinにて
    my $html = $self->render_partial()->to_string;
    $html = HTML::FillInForm->fill(\$html, $self->req->params,);
    return $self->render_text($html, format => 'html');
    #リターンなのでここでおしまい。
    }
}
#get入力、そのままfillinでrender
else {
    #Fillin画面表示実行returnなのでここでおしまい。
    return $self->render_text($html, format => 'html');
}

};
