package WWW::AdServer;
$VERSION = 0.01;
use strict;
use Carp;
use vars qw ($VERSION);
use Apache;
use Apache::Constants qw( :common :http :remotehost );
use WWW::AdServer::Advert;
use WWW::AdServer::Displayer::IFrame;
use WWW::AdServer::Displayer::JScript;
use WWW::AdServer::Displayer::NonSSI;
use WWW::AdServer::Logger::DevNull;
use WWW::AdServer::Logger::Text;

sub handler
{
    my $r = shift;
    error($r,'can only accept GET requests') unless ($r->method eq 'GET');
    error($r,'please supply ADCONFIG') unless (defined $r->dir_config('ADCONFIG'));

    my $command = $r->path_info; 
    error($r,'no command') unless (defined $command);
    error ($r,'bad args') unless ($r->args =~ /^[a-zA-Z&,=0-9]+$/);
   
    if ($command =~ /^\/display/){
	display($r);
    } elsif ($command eq '/clickthru'){
	clickthru($r);
    } else {
	error($r,'odd command');
    }
}

sub error
{
    my ($r,$error) = @_;
    $r->status(404);
    $r->send_http_header('text/plain');
    $r->print("an error occurred!\n");
    $r->print("$error\n");
    $r->exit;
}

sub clickthru
{
    my $r = shift;
    my @in = $r->args;
    my %in;
    if ($#in % 2){
	%in = $r->args;
    } else {
	error($r,"non-even arguments");
    }

    my @zones;
    my $advert;
    if (exists $in{zones}){
	@zones = split /,/, $in{zones};
    } elsif (exists $in{advert}){
	$advert = $in{advert};
    } else {
	error($r,"must specify advert or zones");
    }

    my $displayer = WWW::AdServer::Displayer::NonSSI->new($r);
    my $logger = WWW::AdServer::Logger::Text->new($r);
    $advert = WWW::AdServer::Advert->new(
					 displayer => $displayer,
					 logger    => $logger,
					 zones     => \@zones,
					 advert    => $advert,
					 adconf    => $r->dir_config('ADCONFIG')
					 );
    error($r,'could not find advert, or ad-config is corrupt') unless defined $advert;
    $advert->log_clickthru;
    $advert->redirect;
}

sub display
{
    my $r = shift;
    my @in = $r->args;
    my %in;
    if ($#in % 2){
	%in = $r->args;
    } else {
	error($r,"non-even arguments");
    }

    my @zones;
    my $advert;
    if (exists $in{zones}){
	@zones = split /,/, $in{zones};
    } elsif (exists $in{advert}){
	$advert = $in{advert};
    } else {
	error($r,"must specify advert or zones");
	return;
    }

    my ($displayer,$logger);
    my $command = $r->path_info;
    if ($command eq '/display/iframe'){
	$displayer = WWW::AdServer::Displayer::IFrame->new($r);
	$logger = WWW::AdServer::Logger::DevNull->new($r);
    } elsif ($command eq '/display/jscript'){
	$displayer = WWW::AdServer::Displayer::JScript->new($r);
	$logger = WWW::AdServer::Logger::DevNull->new($r);
    } else {
	$displayer = WWW::AdServer::Displayer::NonSSI->new($r);
	$logger = WWW::AdServer::Logger::Text->new($r);
    }

    $advert = WWW::AdServer::Advert->new(
					 displayer => $displayer,
					 logger    => $logger,
					 zones     => \@zones,
					 advert    => $advert,
					 adconf    => $r->dir_config('ADCONFIG')
					 );
    error($r,'could not find advert, or ad-config is corrupt') unless defined $advert;
    $advert->log_impression;
    $advert->display;
}

1;
__END__
=head1 NAME

WWW::AdServer - a mod_perl banner ad server

=head1 SYNOPSIS

    <Location /foo/bar/adverts>

        PerlHandler WWW::AdServer

        PerlSetVar ADCONFIG '/path/to/config/directory'

    </Location>

=head1 DESCRIPTION

This is the ad server part of WWW::AdServer. You can install this on 
as many webservers as you wish, but you will also need to install 
WWW::AdServer::Admin on one machine that has secure-shell (ssh) 
access to all the ad servers. Note that you will need to download 
WWW::AdServer::Admin separately.

Before starting up your AdServer, you should make the config directory 
(mkdir /path/to/config/directory) and loosen the default access privileges 
(chmod 0777 /path/to/config/directory). You should realise that this 
allows anyone with a login shell on your server can tinker with your 
adverts. In the future, I hope to change this loophole, but for now I'm 
'releasing early, releasing often'. Using a web browser, a few refreshes 
on a non-existant advert should build the necessary config directory 
structure.

Next, download and install WWW:AdServer::Admin.

Note also that you can run WWW::AdServer through a CGI script if you 
have my Apache::Emulator module installed. Here's what your CGI script 
should look like:

  #!/path/to/your/perl -w
  use strict;
  use Apache::Emulator;

  Apache::Emulator->new( PerlHandler=>'WWW::AdServer', PerlSetVar=>{ADCONFIG=>'/path/to/config/directory'} );

=head2 EXPORT

None by default.

=head1 AUTHOR 

Nigel Wetters (nwetters@cpan.org)

=head1 COPYRIGHT 

Copyright (c) 2001, Nigel Wetters. All Rights Reserved. This module is free software. 
It may be used, redistributed and/or modified under the same terms as Perl itself. 
=cut
