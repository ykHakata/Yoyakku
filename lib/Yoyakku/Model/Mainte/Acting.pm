package Yoyakku::Model::Mainte::Acting;
use strict;
use warnings;
use utf8;
use parent 'Yoyakku::Model::Mainte';
use Yoyakku::Util qw{now_datetime get_fill_in_params};

sub search_acting_id_rows {
    my $self = shift;
    return $self->search_id_single_or_all_rows( 'acting',
        $self->params()->{id} );
}

sub get_init_valid_params_acting {
    my $self = shift;
    return $self->get_init_valid_params( [qw{general_id storeinfo_id}] );
}

sub get_general_rows_all {
    my $self         = shift;
    my $teng         = $self->teng();
    my @general_rows = $teng->search( 'general', +{}, );
    return \@general_rows;
}

sub get_storeinfo_rows_all {
    my $self           = shift;
    my $teng           = $self->teng();
    my @storeinfo_rows = $teng->search( 'storeinfo', +{}, );
    return \@storeinfo_rows;
}

sub check_acting_validator {
    my $self = shift;

    my $check_params = [
        general_id   => [ 'NOT_NULL', ],
        storeinfo_id => [ 'NOT_NULL', ],
    ];

    my $msg_params = [
        'general_id.not_null'   => '両方を選んでください',
        'storeinfo_id.not_null' => '両方を選んでください',
    ];

    my $msg = $self->get_msg_validator( $check_params, $msg_params, );

    return if !$msg;

    return +{
        general_id   => $msg->{general_id},
        storeinfo_id => $msg->{storeinfo_id},
    };
}

sub check_acting_validator_db {
    my $self   = shift;
    my $teng   = $self->teng();
    my $params = $self->params();

    my $valid_msg_db = +{ general_id => '既に利用されています' };

    # general_id, storeinfo_id, 組み合わせの重複確認
    my $check_acting_row = $teng->single(
        'acting',
        +{  general_id   => $params->{general_id},
            storeinfo_id => $params->{storeinfo_id},
            status       => 1,
        },
    );

    return               if !$check_acting_row;
    return $valid_msg_db if !$params->{id};                           # 新規
    return $valid_msg_db if $params->{id} ne $check_acting_row->id;   # 更新
    return;
}

sub writing_acting {
    my $self = shift;

    my $create_data = +{
        general_id   => $self->params()->{general_id}   || undef,
        storeinfo_id => $self->params()->{storeinfo_id} || undef,
        status       => $self->params()->{status},
        create_on    => now_datetime(),
        modify_on    => now_datetime(),
    };
    return $self->writing_db( 'acting', $create_data,
        $self->params()->{id} );
}

sub get_fill_in_acting {
    my $self   = shift;
    my $html   = $self->html();
    my $params = $self->params();
    my $output = get_fill_in_params( $html, $params );
    return $output;
}

1;

__END__
