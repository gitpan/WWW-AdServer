package WWW::AdServer::Logger::Text;
$VERSION = '0.01';
use strict;
use vars qw ( $VERSION @ISA );
use Carp;
use WWW::AdServer::Logger;
@ISA = qw ( WWW::AdServer::Logger );

use Fcntl qw (:DEFAULT :flock);

sub log_impression
{
    my ($self, $advert) = @_;
    my $r = $$self;
    my $config = $r->dir_config('ADCONFIG');
    my $ad_log = $config.'/logs/'.$advert->get_advert.'.txt';
    my $lock   = $ad_log.'.lockfile';
    sysopen(LOGLOCK, $lock, O_RDONLY | O_CREAT)
	or croak "can't open $lock: $!";
    while (!(flock(LOGLOCK, LOCK_SH))){
	sleep 0.1;
    };
    sysopen(LOG, $ad_log, O_WRONLY | O_APPEND | O_CREAT)
	or croak "can't open log: $!";
    print LOG (time.' IMP '.$r->get_remote_host."\n");
    close LOG;
    if ((-M $lock > 1) or (-s $ad_log > 100000)){
	rename $ad_log, ($r->dir_config('ADCONFIG').'/admin/logs/'.$advert->get_advert.'.txt.'.time.'.'.int(rand 2**32));
	unlink $lock;
    }
    close LOGLOCK;
}

sub log_clickthru
{
    my ($self,$advert) = @_;
    my $r = $$self;
    my $config = $r->dir_config('ADCONFIG');
    my $ad_log = $config.'/logs/'.$advert->get_advert.'.txt';
    my $lock   = $ad_log.'.lockfile';
    sysopen(LOGLOCK, $lock, O_RDONLY | O_CREAT)
	or croak "can't open $lock: $!";
    while (!(flock(LOGLOCK, LOCK_SH))){
	sleep 0.1;
    };
    sysopen(LOG, $ad_log, O_WRONLY | O_APPEND | O_CREAT)
	or croak "can't open log: $!";
    print LOG (time.' CKT '.$r->get_remote_host."\n");
    close LOG;
    if ((-M $lock > 1) or (-s $ad_log > 100000)){
	rename $ad_log, ($r->dir_config('ADCONFIG').'/admin/logs/'.$advert->get_advert.'.txt.'.time.'.'.int(rand 2**32));
	unlink $lock;
    }
    close LOGLOCK;
}

1;
__END__
=head1 NAME

WWW::AdServer::Logger::Text - logs impressions / clickthrus to a text file

=head1 SYNOPSIS

  use WWW::AdServer::Logger::Text;

  my $logger = WWW::AdServer::Logger::Text->new( $r );

  $logger->log_impression($advert);

  $logger->log_clickthru($advert);

=head1 DESCRIPTION

=head2 $logger = WWW::AdServer::Logger::Text->new( $r );

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
