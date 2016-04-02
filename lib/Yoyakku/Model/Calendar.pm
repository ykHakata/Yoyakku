package Yoyakku::Model::Calendar;
use Mojo::Base 'Yoyakku::Model::Base';
use Yoyakku::Util qw{chang_date_6 get_calendar};

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Model::Calendar - オープニングカレンダー用 API

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Model::Calendar version 0.0.1

=head1 SYNOPSIS (概要)

    Calendar コントローラーのロジック API

=cut

=head2 get_cal_info_ads_rows

    今月のイベント広告データ取得

=cut

sub get_cal_info_ads_rows {
    my $self      = shift;
    my $date_info = shift;
    my $rows      = $self->app->model->db->ads->cal_info_ads_rows($date_info);
    return $rows;
}

=head2 get_calendar_info

    カレンダー情報の取得

=cut

sub get_calendar_info {
    my $self          = shift;
    my $date_info     = shift;
    my $calendar_info = get_calendar( $date_info->mon, $date_info->year );
    return $calendar_info;
}

=head2 get_date_info

    カレンダー表示用の日付情報取得

=cut

sub get_date_info {
    my $self      = shift;
    my $date_type = shift;
    my $date_6    = chang_date_6();
    my $date_info = $date_6->{$date_type};
    return $date_info;
}

=head2 get_header_stash_index

    ヘッダー初期値取得

=cut

sub get_header_stash_index {
    my $self      = shift;
    my $login_row = shift;

    my $table;
    my $login_name;

    if ($login_row) {
        $login_name
            = $login_row->fetch_profile
            ? $login_row->fetch_profile->nick_name
            : undef;
        $table = $login_row->get_table_name;
    }

    my $switch_header = 2;

    return $self->get_header_stash_params( $switch_header, $login_name )
        if !$table;

    if ( $table eq 'admin' ) {
        $login_name = q{(admin)} . $login_name;
        $switch_header = 4;
        if ( $login_row->fetch_storeinfo->status eq 0 ) {
            $switch_header = 9;
        }
    }
    elsif ( $table eq 'general' ) {
        $switch_header = 3;
    }

    return $self->get_header_stash_params( $switch_header, $login_name );
}

1;

__END__

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<Mojo::Base>

=item * L<Yoyakku::Model>

=item * L<Yoyakku::Util>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
