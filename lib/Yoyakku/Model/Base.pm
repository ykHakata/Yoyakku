package Yoyakku::Model::Base;
use Mojo::Base -base;
use Encode qw{encode};
use Email::Sender::Simple 'sendmail';
use Email::MIME;
use Email::Sender::Transport::SMTPS;
use Try::Tiny;
use HTML::FillInForm;
use Yoyakku::Util qw{now_datetime switch_header_params chenge_time_over
    next_day_ymd join_time join_date_time};
use Yoyakku::Master qw{$MAIL_USER $MAIL_PASS};
use Yoyakku::DB::Model;

has [qw{mail_temp mail_header mail_body app model_stash}];

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Base - データベース関連 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Base version 0.0.1

=head1 SYNOPSIS (概要)

    データベース接続関連の API を提供

=cut

=head2 change_format_datetime

    日付と時刻に分かれたものを datetime 形式にもどす

=cut

sub change_format_datetime {
    my $self   = shift;
    my $params = shift;

    my $start_date = $params->{getstarted_on_day};
    my $start_time = $params->{getstarted_on_time};
    my $end_date   = $params->{enduse_on_day};
    my $end_time   = $params->{enduse_on_time};

    # time 24:00 ~ 30:30 までの表示の場合 0:00 ~ 06:30 用に変換
    # 時間の表示を24:00表記にもどす
    my $split_t = chenge_time_over(
        +{ start_time => $start_time, end_time => $end_time, }, 'normal', );

    # 時間の表示を変換 日付を１日進める
    if ( $split_t->{start_hour} >= 0 && $split_t->{start_hour} < 6 ) {
        $start_date = next_day_ymd($start_date);
    }

    if ( $split_t->{end_hour} >= 0 && $split_t->{end_hour} <= 6 ) {
        $end_date = next_day_ymd($end_date);
    }

    ( $start_time, $end_time, ) = join_time($split_t);

    ( $params->{getstarted_on}, $params->{enduse_on}, ) = join_date_time(
        +{  start_date => $start_date,
            start_time => $start_time,
            end_date   => $end_date,
            end_time   => $end_time,
        },
    );

    return $params;
}

=head2 set_fill_in_params

    html パラメーターフィルインを設定

=cut

sub set_fill_in_params {
    my $self = shift;
    my $args = shift;

    my $html   = $args->{html};
    my $params = $args->{params};

    return HTML::FillInForm->fill( $html, $params );
}

=head2 get_calender_caps

    カレンダー表示用の曜日

=cut

sub get_calender_caps {
    my $self = shift;
    my $caps = [qw{日 月 火 水 木 金 土}];
    return $caps;
}

=head2 send_gmail

    メール送信(gmail)

=cut

sub send_gmail {
    my $self = shift;
    my $conf = $self->app->config;

    my $email = Email::MIME->create(
        header => [
            From    => encode( 'UTF-8', $self->mail_header()->{from} ),
            To      => encode( 'UTF-8', $self->mail_header()->{to} ),
            Subject => encode( 'UTF-8', $self->mail_header()->{subject} ),
        ],
        body       => encode( 'UTF-8', $self->mail_body() ),
        attributes => +{
            content_type => 'text/plain',
            charset      => 'UTF-8',
            encoding     => '7bit',
        },
    );

    my $transport = Email::Sender::Transport::SMTPS->new(
        +{  host          => 'smtp.gmail.com',
            ssl           => 'starttls',
            sasl_username => $MAIL_USER,
            sasl_password => $MAIL_PASS,
        }
    );

    try {
        if ( $conf->{mode} eq 'testing' ) {
            my $test_mail = [ $email, +{ transport => $transport } ];
            $self->model_stash($test_mail);
        }
        else {
            sendmail( $email, +{ transport => $transport } );
        }
    }
    catch {
        my $e = shift;
        warn "Error: $e";
    };

    return;
}

=head2 check_table_column

    指定パラメーターの存在確認

=cut

sub check_table_column {
    my $self         = shift;
    my $check_params = shift;

    my $teng = $self->app->model->db->base->teng();

    my $column = $check_params->{column};
    my $param  = $check_params->{param};
    my $table  = $check_params->{table};
    my $id     = $check_params->{id};

    my $row = $teng->single( $table, +{ $column => $param, }, );

    # 新規
    return '既に利用されています' if $row && !$id;

    # 更新
    return '既に利用されています'
        if $row && $id && ( $id ne $row->id );

    return;
}

=head2 get_header_stash_params

    header の stash の値を取得

=cut

sub get_header_stash_params {
    my $self          = shift;
    my $switch_header = shift;
    my $login_name    = shift;

    my $header_params = switch_header_params( $switch_header, $login_name );

    my $header_params_hash_ref = +{
        site_title_link        => $header_params->{site_title_link},
        header_heading_link    => $header_params->{header_heading_link},
        header_heading_name    => $header_params->{header_heading_name},
        header_navi_class_name => $header_params->{header_navi_class_name},
        header_navi_link_name  => $header_params->{header_navi_link_name},
        header_navi_row_name   => $header_params->{header_navi_row_name},
    };

    my $stash = +{
        switch_header => $switch_header,    # 切替
        %{$header_params_hash_ref},         # ヘッダー各値
    };

    return $stash;
}

=head2 get_valid_params

    各種バリデート用パラメータ取得

=cut

sub get_valid_params {
    my $self         = shift;
    my $class_name   = shift;
    my $valid_params = +{
        up_admin_r_d_edit => [qw{remarks}],
        admin_reserv_edit =>
            [qw{name endingtime_on rentalunit pricescomments}],
        admin_store_edit =>
            [ qw{name post state cities addressbelow tel mail remarks url} ],
        profile => [
            qw{password password_2 nick_name full_name phonetic_name tel mail
                acting_1}
        ],
        auth => [qw{login password}],
        mainte_roominfo =>
            [qw{name endingtime_on rentalunit pricescomments remarks}],
        mainte_storeinfo => [
            qw{name post state cities addressbelow tel mail remarks url
                locationinfor status}
        ],
        mainte_profile => [
            qw{general_id admin_id nick_name full_name phonetic_name tel mail}
        ],
        mainte_general => [qw{login password}],
        mainte_admin   => [qw{login password}],
        mainte_ads =>
            [qw{url displaystart_on displayend_on name content event_date}],
        mainte_acting  => [qw{general_id storeinfo_id}],
        mainte_reserve => [
            qw{id roominfo_id getstarted_on_day getstarted_on_time
                enduse_on_day enduse_on_time useform message general_id
                admin_id tel status}
        ],
    };

    my $valid_params_stash = +{};
    for my $param ( @{ $valid_params->{$class_name} } ) {
        $valid_params_stash->{$param} = '';
    }
    return $valid_params_stash;
}

=head2 get_init_valid_params

    バリデート用パラメータ初期値

=cut

sub get_init_valid_params {
    my $self         = shift;
    my $valid_params = shift;

    my $valid_params_stash = +{};
    for my $param ( @{$valid_params} ) {
        $valid_params_stash->{$param} = '';
    }
    return $valid_params_stash;
}

=head2 insert_admin_relation

    admin 有効の際の関連データ作成

=cut

sub insert_admin_relation {
    my $self         = shift;
    my $new_admin_id = shift;

    my $teng = $self->app->model->db->base->teng();

    my $storeinfo_row
        = $teng->single( 'storeinfo', +{ admin_id => $new_admin_id, }, );

    # storeinfo 見つからないときは新規にレコード作成
    if ( !$storeinfo_row ) {

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
            storeinfo_id      => $insert_storeinfo_row->id,
            name              => undef,
            starttime_on      => '10:00:00',
            endingtime_on     => '22:00:00',
            time_change       => 0,
            rentalunit        => 1,
            pricescomments    => '例）１時間２０００円より',
            privatepermit     => 0,
            privatepeople     => 2,
            privateconditions => 0,
            bookinglimit      => 0,
            cancellimit       => 8,
            remarks => '例）スタジオ内の飲食は禁止です。',
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

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::DB::Model::Base>

=item * L<Encode>

=item * L<Email::Sender::Simple>

=item * L<Email::MIME>

=item * L<Email::Sender::Transport::SMTPS>

=item * L<Try::Tiny>

=item * L<HTML::FillInForm>

=item * L<Yoyakku::Util>

=item * L<Yoyakku::Master>

=item * L<Yoyakku::Validator>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
