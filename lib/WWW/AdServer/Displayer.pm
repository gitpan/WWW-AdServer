package WWW::AdServer::Displayer;
$VERSION = '0.01';
use strict;
use vars qw ( $VERSION );
use Carp;

sub new
{
    my ($class, $r) = @_;
    croak ('Displayer strategies must be constructed with an Apache request object')
	unless (defined $r);
    my $self = bless \$r, $class;

    return $self;
}

sub display
{
    croak ('class has not implimented display method');
}

sub redirect
{
    croak ('class has not implimented redirect method');
}

1;
__END__
=head1 NAME

WWW::AdServer::Displayer - strategy class for displaying adverts

=head1 SYNOPSIS

  use WWW::AdServer::Displayer::Foo;

  my $displayer = WWW::AdServer::Displayer::Foo->new( r=>$r );

  $displayer->display($advert);

=head1 DESCRIPTION

Declares an interface common to all Displayer subclasses.

=head2 $displayer = WWW::AdServer::Displayer::Foo->new( $r );

Constructor for a Displayer strategy. Must be supplied with either an Apache request object, or an Apache::Emulator object (when using CGI).

=head2 $displayer->display($advert);

Outputs the advert to the client.

=head2 EXPORT

None by default.

=head1 AUTHOR 

Nigel Wetters (nwetters@cpan.org)

=head1 COPYRIGHT 

Copyright (c) 2001, Nigel Wetters. All Rights Reserved. This module is free software. 
It may be used, redistributed and/or modified under the same terms as Perl itself. 

=cut
