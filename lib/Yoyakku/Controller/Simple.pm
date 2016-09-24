package Yoyakku::Controller::Simple;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Util qw{chang_date_6 calendar_move chang_datetime_24for29};
use Data::Dumper;

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Simple - スマホに特化した予約確認画面

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Simple version 0.0.1

=head1 SYNOPSIS (概要)

    スマホに特化した予約確認画面

=cut

=head2 index

    予約状況だけを表示する画面

=cut

sub index {
    my $self = shift;

    my $chang_date_ref = chang_date_6();

    my $now_date    = $chang_date_ref->{now_date};
    my $next1m_date = $chang_date_ref->{next1m_date};
    my $next2m_date = $chang_date_ref->{next2m_date};
    my $next3m_date = $chang_date_ref->{next3m_date};

    my $date_ref = {
        now   => $chang_date_ref->{now_date},
        next1 => $chang_date_ref->{next1m_date},
        next2 => $chang_date_ref->{next2m_date},
        next3 => $chang_date_ref->{next3m_date},
    };

    my $calender_move_ref = calendar_move( $date_ref, 'this' );

    if ( $self->req->method eq 'POST' ) {
        my $params = $self->req->params->to_hash;

        my $next_date   = $params->{next_submit};
        my $back_date   = $params->{back_submit};
        my $select_date = $params->{select_date};

        if ($select_date) {
            $calender_move_ref
                = calendar_move( $date_ref, 'select', $select_date );
        }

        if ( $next_date || $back_date ) {

            my $select_date_ym;

            if ($next_date) {
                $select_date_ym = $params->{next_date};
            }
            elsif ($back_date) {
                $select_date_ym = $params->{back_date};
            }

            #１ヶ月後の場合
            if ( $next1m_date->strftime('%Y-%m') eq $select_date_ym ) {
                $calender_move_ref = calendar_move( $date_ref, 'next_1' );
            }

            #２ヶ月後の場合
            if ( $next2m_date->strftime('%Y-%m') eq $select_date_ym ) {
                $calender_move_ref = calendar_move( $date_ref, 'next_2' );
            }

            #３ヶ月後の場合
            if ( $next3m_date->strftime('%Y-%m') eq $select_date_ym ) {
                $calender_move_ref = calendar_move( $date_ref, 'next_3' );
            }
        }
    }

    # 表示する為の店舗情報を指定して取得
    my $teng = $self->model->db->base->teng;
    my $storeinfo_row = $teng->single( 'storeinfo', +{ id => 1 } );

    # 部屋情報取得
    my $args = +{ status => 1 };
    my $roominfo_rows = $storeinfo_row->search_roominfos($args);

    my $roominfo_names = [];
    for my $roominfo_row ( @{$roominfo_rows} ) {
        push @{$roominfo_names}, $roominfo_row->name;
    }

    my $start_time = $calender_move_ref->{look_date_ymd} . q{ 06:00:00};
    my $end_time   = $calender_move_ref->{tomorrow}->date . " 06:00:00";

    # 表示するための、予約情報データ
    my @reserves = $teng->search_named(
        q{
            select roominfo.name,
            reserve.roominfo_id,
            reserve.getstarted_on,
            reserve.enduse_on
            from roominfo join reserve on roominfo.id = reserve.roominfo_id
            where reserve.getstarted_on >= :start_time
            and reserve.getstarted_on < :end_time
            and reserve.status = '0'
            order by reserve.getstarted_on asc;
        },
        { start_time => $start_time, end_time => $end_time }
    );

    my $res_hash = +{};
    for my $reserve_ref (@reserves) {
        my $chang_datetime_ref
            = chang_datetime_24for29( $reserve_ref->getstarted_on,
            $reserve_ref->enduse_on );

        my $start_time_key = $chang_datetime_ref->{datetime_start_hour};
        my $end_time_key   = $chang_datetime_ref->{datetime_end_hour};

        my $room_name   = $reserve_ref->name;
        my $res_comment = $chang_datetime_ref->{datetime_start_min};

        my $start_key = $start_time_key;
        my $stop_key  = $end_time_key - 1;

        for my $time_key ( $start_key .. $stop_key ) {
            $res_hash->{ $room_name . $time_key } = $res_comment;
        }
    }

    $self->stash(
        storeinfo_name => $storeinfo_row->name,
        roominfo_name  => $roominfo_names,
        reserves       => \@reserves,
        res_hash       => $res_hash,
    );

    $self->stash(
        look_date_ymd  => $calender_move_ref->{look_date_ymd},
        look_date_ym   => $calender_move_ref->{look_date_ym},
        look_date_wday => $calender_move_ref->{look_date_wday},
        select_date_d  => $calender_move_ref->{select_date_d},
        past_date_d    => $calender_move_ref->{past_date_d},
        next_date_ym   => $calender_move_ref->{next_date_ym},
        back_date_ym   => $calender_move_ref->{back_date_ym},
        cal_now        => $calender_move_ref->{cal_now},
        caps           => $calender_move_ref->{caps},
    );

    $self->stash(
        class    => '',
        template => 'simple/simple_res',
        format   => 'html',
    );

    $self->render();
    return;
};

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
