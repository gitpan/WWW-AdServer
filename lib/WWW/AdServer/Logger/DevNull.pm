package WWW::AdServer::Logger::DevNull;
$VERSION = '0.01';
use strict;
use vars qw ( $VERSION @ISA );
use Carp;
use WWW::AdServer::Logger;
@ISA = qw ( WWW::AdServer::Logger );

sub log_impression
{
}

sub log_clickthru
{
}

1;
__END__
=head1 NAME

WWW::AdServer::Logger::DevNull - doesn't log (What a strategy!)

=head1 SYNOPSIS

  use WWW::AdServer::Logger::DevNull;

  my $logger = WWW::AdServer::Logger::DevNull;->new( $r );

  $logger->log_impression($advert);

  $logger->log_clickthru($advert);

=head1 DESCRIPTION

=head2 $logger = WWW::AdServer::Logger::DevNull->new( $r );

Constructor for a Logger strategy. Must be supplied with either an Apache request object or an Apache::Emulator object (if called through CGI).

=head2 $logger->log_impression($advert);

Logs (NOT!) a view of an advert.

=head2 $logger->log_clickthru($advert);

Logs (NOT!) a clickthru on an advert.

=head2 EXPORT

None by default.

=head1 AUTHOR 

Nigel Wetters (nwetters@cpan.org)

=head1 COPYRIGHT 

Copyright (c) 2001, Nigel Wetters. All Rights Reserved. This module is free software. 
It may be used, redistributed and/or modified under the same terms as Perl itself. 

=cut
