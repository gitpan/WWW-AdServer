package WWW::AdServer::Logger;
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

sub log_impression
{
    croak ('class has not implimented log method');
}

sub log_clickthru
{
    croak ('class has not implimented log method');
}

1;
__END__
=head1 NAME

WWW::AdServer::Logger - strategy class for logging impressions / clickthrus

=head1 SYNOPSIS

  use WWW::AdServer::Logger::Foo;

  my $logger = WWW::AdServer::Logger::Foo->new( $r );

  $logger->log_impression($advert);

  $logger->log_clickthru($advert);

=head1 DESCRIPTION

Declares an interface common to all Logger subclasses.

=head2 $logger = WWW::AdServer::Logger::Foo->new( $r );

Constructor for a Logger strategy. Must be supplied with either an Apache request object or an Apache::Emulator object (if called through CGI).

=head2 $logger->log_impression($advert);

Logs a view of an advert.

=head2 $logger->log_clickthru($advert);

Logs a clickthru on an advert.

=head2 EXPORT

None by default.

=head1 AUTHOR 

Nigel Wetters (nwetters@cpan.org)

=head1 COPYRIGHT 

Copyright (c) 2001, Nigel Wetters. All Rights Reserved. This module is free software. 
It may be used, redistributed and/or modified under the same terms as Perl itself. 

=cut
