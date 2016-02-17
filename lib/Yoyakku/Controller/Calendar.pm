package Yoyakku::Controller::Calendar;
use Mojo::Base 'Mojolicious::Controller';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Calendar - オープニングカレンダーのコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Calendar version 0.0.1

=head1 SYNOPSIS (概要)

    オープニングカレンダー関連機能のリクエストをコントロール

=cut

=head2 index

    コントローラー内のルーティング、セッション確認

=cut

sub index {
    my $self  = shift;
    my $model = $self->model_calendar;

    return $self->redirect_to('index')
        if ( uc $self->req->method ne 'GET' )
        && ( uc $self->req->method ne 'POST' );

    $model->check_auth_db_yoyakku( $self->session );

    $self->stash->{login_row} = $model->get_login_row( $self->session );

    my $header_stash
        = $model->get_header_stash_index( $self->stash->{login_row} );

    $self->stash($header_stash);
    $self->stash->{params} = $self->req->params->to_hash;

    my $path = $self->req->url->path->to_abs_string;

    return $self->this_month()         if $path eq '/';
    return $self->this_month()         if $path eq '/index';
    return $self->index_next_m()       if $path eq '/index_next_m';
    return $self->index_next_two_m()   if $path eq '/index_next_two_m';
    return $self->index_next_three_m() if $path eq '/index_next_three_m';
    return $self->redirect_to('index');
}

=head2 this_month

    オープニングカレンダー確認画面(今月)

=cut

sub this_month {
    my $self     = shift;
    my $model    = $self->model_calendar();
    my $now_date = $model->get_date_info('now_date');
    $self->stash(
        class    => 'index_this_m',
        now_date => $now_date,
        cal_now  => $model->get_calendar_info($now_date),
        caps     => $model->get_calender_caps(),
        ads_rows => $model->get_cal_info_ads_rows($now_date),
        template => 'calendar/index',
        format   => 'html',
    );
    return $self->render();
}

=head2 index_next_m

    オープニングカレンダー確認画面(1ヶ月後)

=cut

sub index_next_m {
    my $self        = shift;
    my $model       = $self->model_calendar();
    my $next1m_date = $model->get_date_info('next1m_date');
    $self->stash(
        class       => 'index_next_m',
        next1m_date => $next1m_date,
        cal_next1m  => $model->get_calendar_info($next1m_date),
        caps        => $model->get_calender_caps(),
        ads_rows    => $model->get_cal_info_ads_rows($next1m_date),
        template    => 'calendar/index_next_m',
        format      => 'html',
    );
    return $self->render();
}

=head2 index_next_two_m

    オープニングカレンダー確認画面(2ヶ月後)

=cut

sub index_next_two_m {
    my $self        = shift;
    my $model       = $self->model_calendar();
    my $next2m_date = $model->get_date_info('next2m_date');
    $self->stash(
        class       => 'index_next_two_m',
        next2m_date => $next2m_date,
        cal_next2m  => $model->get_calendar_info($next2m_date),
        caps        => $model->get_calender_caps(),
        ads_rows    => $model->get_cal_info_ads_rows($next2m_date),
        template    => 'calendar/index_next_two_m',
        format      => 'html',
    );
    return $self->render();
}

=head2 index_next_three_m

    オープニングカレンダー確認画面(3ヶ月後)

=cut

sub index_next_three_m {
    my $self        = shift;
    my $model       = $self->model_calendar();
    my $next3m_date = $model->get_date_info('next3m_date');
    $self->stash(
        class       => 'index_next_three_m',
        next3m_date => $next3m_date,
        cal_next3m  => $model->get_calendar_info($next3m_date),
        caps        => $model->get_calender_caps(),
        ads_rows    => $model->get_cal_info_ads_rows($next3m_date),
        template    => 'calendar/index_next_three_m',
        format      => 'html',
    );
    return $self->render();
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Calendar>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
