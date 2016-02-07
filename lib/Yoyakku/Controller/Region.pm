package Yoyakku::Controller::Region;
use Mojo::Base 'Mojolicious::Controller';
use Yoyakku::Model::Region;

has( model_region => sub { Yoyakku::Model::Region->new(); } );

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Region - 予約のコントローラー

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Region version 0.0.1

=head1 SYNOPSIS (概要)

    予約、関連機能のリクエストをコントロール

=cut

sub index {
    my $self  = shift;
    my $model = $self->model_region;

    return $self->redirect_to('index')
        if ( uc $self->req->method ne 'GET' )
        && ( uc $self->req->method ne 'POST' );

    return $self->redirect_to('index')
        if !$model->check_auth_db_yoyakku( $self->session );

    $self->stash->{login_row} = $model->get_login_row( $self->session );

    my $redirect_mode
        = $model->get_redirect_mode_region( $self->stash->{login_row} );

    return $self->redirect_to('profile')
        if $redirect_mode && $redirect_mode eq 'profile';

    my $header_stash
        = $model->get_header_stash_region( $self->stash->{login_row} );

    $self->stash($header_stash);
    $self->stash->{params} = $self->req->params->to_hash;

    my $path = $self->req->url->path->to_abs_string;

    return $self->region_state() if $path eq '/region_state';
    return $self->redirect_to('index');
}

=head2 region_state

    予約の為のスタジオ検索(地域)

=cut

sub region_state {
    my $self   = shift;
    my $model  = $self->model_region;
    my $params = $model->get_cal_params( $self->stash->{params} );
    $self->stash(
        class              => 'state',
        adsReco_rows       => $model->get_ads_reco_rows(),
        adsOne_rows        => $model->get_ads_one_rows(),
        ads_rows           => $model->get_ads_rows(),
        adsNavi_rows       => $model->get_ads_navi_rows(),
        back_mon_val       => $params->{back_mon_val},
        select_date_ym     => $params->{select_date_ym},
        next_mon_val       => $params->{next_mon_val},
        switch_calnavi     => $model->get_switch_calnavi(),
        store_id           => $self->stash->{params}->{store_id},
        caps               => $model->get_calender_caps(),
        cal                => $params->{cal},
        select_date_day    => $params->{select_date_day},
        border_date_day    => $params->{border_date_day},
        select_date        => $params->{select_date},
        storeinfo_rows_ref => $model->get_storeinfo_rows_region_navi(),
        region_rows_ref    => $model->get_region_rows_region_navi(),
        template           => 'region/region_state',
        format             => 'html',
    );
    return $self->render();
}

1;

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Controller>

=item * L<Yoyakku::Model::Region>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut

__END__
