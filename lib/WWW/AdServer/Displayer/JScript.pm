package WWW::AdServer::Displayer::JScript;
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
    $r->status(200);
    $r->header_out('Cache-Control','no-cache');
    $r->header_out('Pragma','no-cache');
    $r->header_out('Expires','Thu, 15 Nov 2001 11:59:59 GMT');
    $r->send_http_header('application/x-javascript');

    my $rand = int(rand 2**32);
    my $image = my $link = $r->uri;

    my $alt = $advert->get_alt;
    my $height = $advert->get_height;
    my $width = $advert->get_width;
    
    $image =~ s/\/jscript$//;
    $link  =~ s/display\/jscript$/clickthru/;

    $image .= '?advert='.$advert->get_advert.'&rand='.$rand;
    $link  .= '?advert='.$advert->get_advert.'&rand='.$rand;

    $r->print("document.write('");
    $r->print("<a href=\"$link\" target=\"_top\">");
    $r->print("<img src=\"$image\" height=\"$height\" width=\"$width\" alt=\"$alt\" border=\"0\">");
    $r->print("</a>");
    $r->print("');");

#    $r->print("<html>\n<head>\n</head>\n<body>\n<p><center>");
#    $r->print("<a href=\"$link\" target=\"_top\">");
#    $r->print("<img src=\"$image\" height=\"$height\" width=\"$width\" alt=\"$alt\" border=\"0\">");
#    $r->print("</center></p>\n</body>\n<html>\n");

    
}

1;
__END__
=head1 NAME

WWW::AdServer::Displayer::JScript - displays adverts using JavaScript

=head1 SYNOPSIS

  use WWW::AdServer::Displayer::JScript;

  my $displayer = WWW::AdServer::Displayer::JScript->new( $r );

  $displayer->display($advert);

=head1 DESCRIPTION

Displays adverts using JavaScript.

=head2 $displayer = WWW::AdServer::Displayer::JScript->new( $r );

Constructor for a JavaSCript Displayer. Must be supplied with either an Apache request object, or an Apache::Emulator object (when using CGI).

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
