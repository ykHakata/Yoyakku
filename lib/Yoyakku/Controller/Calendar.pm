package Yoyakku::Controller::Calendar;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Calendar;

sub _init {
    my $self  = shift;
    my $model = Yoyakku::Model::Calendar->new();
    $model->params( $self->req->params->to_hash );
    $model->method( uc $self->req->method );
    $model->session( $self->session );
    $model->check_auth_db_yoyakku();
    my $header_stash = $model->get_header_stash_index();
    $self->stash($header_stash);
    return $model;
}

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

    return $self->render( template => 'index', format => 'html', );
}

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

    return $self->render( template => 'index_next_m', format => 'html', );
}

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

    return $self->render( template => 'index_next_two_m', format => 'html', );
}

1;

__END__
