package Yoyakku::Controller::Calendar;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Calendar;

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Calendar - オープニングカレンダーのコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Calendar version 0.0.1

=head1 SYNOPSIS (概要)

    オープニングカレンダー関連機能のリクエストをコントロール

=cut

sub _init {
    my $self  = shift;
    my $model = $self->model_calendar();
    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    my $args = +{
        teng       => $model->teng(),
        admin_id   => $self->session('session_admin_id'),
        general_id => $self->session('session_general_id'),
    };
    $model->check_auth_db_yoyakku($args);
    my $header_stash = $model->get_header_stash_index();
    $self->stash($header_stash);
    return $model;
}

=head2 index

    オープニングカレンダー確認画面(今月)

=cut

sub index {
    my $self  = shift;
    my $model = $self->_init();

    my $now_date = $model->get_date_info('now_date');
    my $caps     = $model->get_calender_caps();
    my $cal_now  = $model->get_calendar_info($now_date);
    my $ads_rows = $model->get_cal_info_ads_rows($now_date);

    $self->stash(
        class    => 'index_this_m',
        now_date => $now_date,
        cal_now  => $cal_now,
        caps     => $caps,
        ads_rows => $ads_rows,
    );

    return $self->render( template => 'calendar/index', format => 'html', );
}

=head2 index_next_m

    オープニングカレンダー確認画面(1ヶ月後)

=cut

sub index_next_m {
    my $self  = shift;
    my $model = $self->_init();

    my $next1m_date = $model->get_date_info('next1m_date');
    my $caps        = $model->get_calender_caps();
    my $cal_next1m  = $model->get_calendar_info($next1m_date);
    my $ads_rows    = $model->get_cal_info_ads_rows($next1m_date);

    $self->stash(
        class       => 'index_next_m',
        next1m_date => $next1m_date,
        cal_next1m  => $cal_next1m,
        caps        => $caps,
        ads_rows    => $ads_rows,
    );

    return $self->render( template => 'calendar/index_next_m', format => 'html', );
}

=head2 index_next_two_m

    オープニングカレンダー確認画面(2ヶ月後)

=cut

sub index_next_two_m {
    my $self  = shift;
    my $model = $self->_init();

    my $next2m_date = $model->get_date_info('next2m_date');
    my $caps        = $model->get_calender_caps();
    my $cal_next2m  = $model->get_calendar_info($next2m_date);
    my $ads_rows    = $model->get_cal_info_ads_rows($next2m_date);

    $self->stash(
        class       => 'index_next_two_m',
        next2m_date => $next2m_date,
        cal_next2m  => $cal_next2m,
        caps        => $caps,
        ads_rows    => $ads_rows,
    );

    return $self->render( template => 'calendar/index_next_two_m', format => 'html', );
}

=head2 index_next_three_m

    オープニングカレンダー確認画面(3ヶ月後)

=cut

sub index_next_three_m {
    my $self  = shift;
    my $model = $self->_init();

    my $next3m_date = $model->get_date_info('next3m_date');
    my $caps        = $model->get_calender_caps();
    my $cal_next3m  = $model->get_calendar_info($next3m_date);
    my $ads_rows    = $model->get_cal_info_ads_rows($next3m_date);

    $self->stash(
        class       => 'index_next_three_m',
        next3m_date => $next3m_date,
        cal_next3m  => $cal_next3m,
        caps        => $caps,
        ads_rows    => $ads_rows,
    );

    return $self->render( template => 'calendar/index_next_three_m', format => 'html', );
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
