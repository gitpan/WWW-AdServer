package WWW::AdServer::Displayer::IFrame;
$VERSION = '0.01';
use strict;
use vars qw ( $VERSION @ISA );
use Carp;
use WWW::AdServer::Displayer;
@ISA = qw ( WWW::AdServer::Displayer );

use Apache::Constants qw( :http );

sub display
{
    my ($self,$advert) = @_;
    my $r = $$self;
    $r->status(HTTP_OK);
    $r->header_out('Cache-Control','no-cache');
    $r->header_out('Pragma','no-cache');
    $r->header_out('Expires','Thu, 15 Nov 2001 11:59:59 GMT');
    $r->send_http_header('text/html');

    my $rand = int(rand 2**32);
    my $image = my $link = $r->uri;

    my $alt = $advert->get_alt;
    my $height = $advert->get_height;
    my $width = $advert->get_width;
    
    $image =~ s/\/iframe$//;
    $link  =~ s/display\/iframe$/clickthru/;

    $image .= '?advert='.$advert->get_advert.'&rand='.$rand;
    $link  .= '?advert='.$advert->get_advert.'&rand='.$rand;

    $r->print("<html>\n<head>\n</head>\n<body>\n<p><center>");
    $r->print("<a href=\"$link\" target=\"_top\">");
    $r->print("<img src=\"$image\" height=\"$height\" width=\"$width\" alt=\"$alt\" border=\"0\">");
    $r->print("</a></center></p>\n</body>\n<html>\n");
}

1;
__END__
=head1 NAME

WWW::AdServer::Displayer::IFrame - displays adverts using IFRAME method

=head1 SYNOPSIS

  use WWW::AdServer::Displayer::IFrame;

  my $displayer = WWW::AdServer::Displayer::IFrame->new( $r );

  $displayer->display($advert);

=head1 DESCRIPTION

Declares an interface common to all Displayer subclasses.

=head2 $displayer = WWW::AdServer::Displayer::NonSSI->new( $r );

Constructor for a Non-SSI Displayer. Must be supplied with either an Apache request object, or an Apache::Emulator object (when using CGI).

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
