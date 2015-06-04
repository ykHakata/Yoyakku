package Yoyakku::Model::Mainte::Profile;
use strict;
use warnings;
use utf8;
use Yoyakku::Model qw{$teng};
# use Yoyakku::Util qw{now_datetime};
use Exporter 'import';
our @EXPORT_OK = qw{
    search_profile_id_rows
    select_general_rows
    select_admin_rows
};

sub select_general_rows {
    my $self = shift;

    my @general_rows = $teng->search( 'general', +{}, );

    return \@general_rows;
}

sub select_admin_rows {
    my $self = shift;

    my @admin_rows = $teng->search( 'admin', +{}, );

    return \@admin_rows;
}

# sub check_general_login_name {
#     my $self  = shift;
#     my $login = shift;

#     my $general_row = $teng->single( 'general', +{ login => $login, }, );

#     return $general_row;
# }

sub search_profile_id_rows {
    my $self       = shift;
    my $profile_id = shift;

    my @profile_rows;

    if ( defined $profile_id ) {
        @profile_rows = $teng->search( 'profile', +{ id => $profile_id, }, );
        if ( !scalar @profile_rows ) {

            # id 検索しないときはテーブルの全てを出力
            @profile_rows = $teng->search( 'profile', +{}, );
        }
    }
    else {
        # id 検索しないときはテーブルの全てを出力
        @profile_rows = $teng->search( 'profile', +{}, );
    }

    return \@profile_rows;
}

# sub search_general_id_row {
#     my $self       = shift;
#     my $general_id = shift;

#     die 'not $general_id!!' if !$general_id;

#     my $general_row = $teng->single( 'general', +{ id => $general_id, }, );

#     die 'not $general_row!!' if !$general_row;

#     return $general_row;
# }

# sub writing_general {
#     my $self   = shift;
#     my $type   = shift;
#     my $params = shift;

#     my $create_data_general = +{
#         login     => $params->{login},
#         password  => $params->{password},
#         status    => $params->{status},
#         create_on => now_datetime(),
#         modify_on => now_datetime(),
#     };

#     my $insert_general_row;

#     if ($type eq 'insert') {

#         $insert_general_row = $teng->insert( 'general', $create_data_general, );

#     }
#     elsif ($type eq 'update') {

#         $insert_general_row
#             = $teng->single( 'general', +{ id => $params->{id} }, );

#         $insert_general_row->update($create_data_general);
#     }

#     die 'not $insert_general_row' if !$insert_general_row;

#     return;
# }


1;

__END__

=encoding utf8

=head1 NAME (モジュール名)

Yoyakku::Model::Mainte::Profile - Profile テーブル管理用 API

=head1 VERSION (改定番号)

This documentation referes to Yoyakku::Model::Mainte::Profile version 0.0.1

=head1 SYNOPSIS (概要)

Profile コントローラーのロジック API

=head1 DEPENDENCIES (依存モジュール)

=over

=item * L<strict>

=item * L<warnings>

=item * L<utf8>

=item * L<Yoyakku::Model>

=item * L<Yoyakku::Util>

=item * L<Exporter>

=back

=head1 SEE ALSO (参照)

L<Guides>

=cut
