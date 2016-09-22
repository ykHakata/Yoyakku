package Yoyakku::Controller::Tutorial;
use Mojo::Base 'Mojolicious::Controller';

=encoding utf8

=head1 NAME (モジュール名)

    Yoyakku::Controller::Tutorial - yoyakku 紹介ページ

=head1 VERSION (改定番号)

    This documentation referes to Yoyakku::Controller::Tutorial version 0.0.1

=head1 SYNOPSIS (概要)

    yoyakku アプリの紹介

=cut

=head2 index

    yoyakku アプリ概要の説明

=cut

sub index {
    my $self = shift;
    $self->stash(
        class    => 'tutorial',
        template => 'tutorial/tutorial',
        format   => 'html',
    );
    $self->render();
    return;
}

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
