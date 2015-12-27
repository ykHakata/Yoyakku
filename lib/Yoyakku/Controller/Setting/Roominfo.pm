package Yoyakku::Controller::Setting::Roominfo;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Setting::Roominfo;

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Setting::Roominfo - 店舗管理のコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Setting::Roominfo version 0.0.1

=head1 SYNOPSIS (概要)

    店舗管理、関連機能のリクエストをコントロール

=cut

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Setting::Roominfo->new();
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

=head2 admin_reserv_edit

    予約部屋情報設定コントロール

=cut

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
        class      => 'admin_reserv_edit',
        switch_com => $switch_com,
        %{$init_valid_params_admin_reserv_edit},
    );

    $model->template('setting/admin_reserv_edit');

    if ( 'GET' eq $model->method() ) {
        $model->set_roominfo_params();
        return $self->_render_fill_in_form($model);
    }
    my $params = $model->params();
    return $self->_cancel($model) if $params->{cancel};
    return $self->_update($model);
}

sub _cancel {
    my $self  = shift;
    my $model = shift;
    $model->get_login_roominfo_ids();
    return $self->_render_fill_in_form($model);
}

sub _update {
    my $self  = shift;
    my $model = shift;

    my $check_params = $model->get_check_params_list();

    for my $check_param ( @{$check_params} ) {
        my $valid_msg = $model->check_validator( 'roominfo', $check_param );
        return $self->stash($valid_msg), $self->_render_fill_in_form($model)
            if $valid_msg;
    }

    return $self->redirect_to('up_admin_r_d_edit');
}

sub _render_fill_in_form {
    my $self  = shift;
    my $model = shift;

    my $html = $self->render_to_string(
        template => $model->template(),
        format   => 'html',
    )->to_string;

    $model->html( \$html );
    my $output = $model->set_fill_in_params();
    return $self->render( text => $output );
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Setting::Roominfo>

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




if (uc $self->req->method eq 'POST') {
    #submitボタン判定、キャンセルの時は空の値、完了の時バリデート

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
