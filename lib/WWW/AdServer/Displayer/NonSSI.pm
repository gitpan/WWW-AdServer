package WWW::AdServer::Displayer::NonSSI;
$VERSION = '0.01';
use strict;
use vars qw ( $VERSION @ISA );
use Carp;
use WWW::AdServer::Displayer;
use CGI::Cookie;

@ISA = qw ( WWW::AdServer::Displayer );

use Apache::Constants qw( :http );

sub display
{
    my ($self,$advert) = @_;
    my $r = $$self;
    my $image = $advert->get_image;
    
    $r->status(301);
    $r->header_out('Cache-Control','no-cache');
    $r->header_out('Pragma','no-cache');
    $r->header_out('Location',$image);
    
    my @zones = $advert->get_zones;
    if (@zones){
	my $zones = join ",", @zones;
	my $ad_id = $advert->get_advert;
	my $cookie = CGI::Cookie->new(
				      -name    => "ADZONE$zones",
				      -value   => $ad_id,
				      -expires => '+1h'
				      );
	$r->header_out( 'Set-Cookie', $cookie );
    }
    $r->send_http_header();
}

sub redirect
{
    my ($self,$advert) = @_;
    my $r = $$self;
    
    my $raw_cookie = $r->header_in('Cookie');
    if (defined $raw_cookie){
	my @zones = $advert->get_zones;
	if (@zones){
	    my $zones = join ",", @zones;
	    my %cookies = CGI::Cookie->parse($r->header_in('Cookie'));
	    if (defined $cookies{"ADZONE$zones"}){
		my $ad_id = $cookies{"ADZONE$zones"}->value;
#		$r->print("Content-type: text/plain\n\n$zones - FOO! $ad_id\n");
		$advert->set_advert($ad_id);
	    }
	}
    }
    
    my $link = $advert->get_link;
    
    $r->status(301);
    $r->header_out('Cache-Control','no-cache');
    $r->header_out('Pragma','no-cache');
    $r->header_out('Location',$link);
    $r->header_out('Expires','Thu, 15 Nov 2001 11:59:59 GMT');
    $r->send_http_header();
}

1;
__END__
=head1 NAME

WWW::AdServer::Displayer::NonSSI - displays adverts using non-SSI method

=head1 SYNOPSIS

  use WWW::AdServer::Displayer::NonSSI;

  my $displayer = WWW::AdServer::Displayer::NonSSI->new( r=>$r );

  $displayer->display($advert);

=head1 DESCRIPTION

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
