package Apache::Emulator::Test;
$VERSION = 0.01;
use strict;
use vars qw ($VERSION);
use Apache;
use Apache::Constants qw( :common :http :remotehost );

sub handler
{
    my $r = shift;
    $r->status(HTTP_OK);
    $r->send_http_header('text/plain');

    print ("CLIENT REQUEST METHODS\n");
    print ('[scalar] $r->args = '.(defined $r->args ? ('\''.$r->args.'\'') : 'undef').";\n");

    my %in = $r->args;
    if (%in){
	print ('$r->args = {'."\n");
	my $inkey;
	foreach $inkey (sort keys %in){
	    print ('            \''.$inkey.'\' => '.(defined $in{$inkey} ? ('\''.$in{$inkey}.'\'') : 'undef').",\n");
	}
	print ("           };\n");
    } else {
	print ('$r->args = undef;'."\n");
    }
    print ('$r->get_remote_host = '.(defined $r->get_remote_host ? ('\''.$r->get_remote_host.'\'') : 'undef').";\n");

    print ('$r->get_remote_host(REMOTE_HOST) = '.(defined $r->get_remote_host(REMOTE_HOST) ? $r->get_remote_host(REMOTE_HOST) : 'undef').";\n");

    print ('$r->get_remote_host(REMOTE_NAME) = '.(defined $r->get_remote_host(REMOTE_NAME) ? ('\''.$r->get_remote_host(REMOTE_NAME).'\'') : 'undef').";\n");

    print ('$r->get_remote_host(REMOTE_NOLOOKUP) = '.(defined $r->get_remote_host(REMOTE_NOLOOKUP) ? ('\''.$r->get_remote_host(REMOTE_NOLOOKUP).'\'') : 'undef').";\n");

    print ('$r->get_remote_host(REMOTE_DOUBLE_REV) = '.(defined $r->get_remote_host(REMOTE_DOUBLE_REV) ? ('\''.$r->get_remote_host(REMOTE_DOUBLE_REV).'\'') : 'undef').";\n");

    print ('$r->header_only = '.(defined $r->header_only ? ('\''.$r->header_only.'\'') : 'undef').";\n");

    print ('$r->method = '.(defined $r->method ? ('\''.$r->method.'\'') : 'undef').";\n");

    print ('$r->path_info = '.(defined $r->path_info ? ('\''.$r->path_info.'\'') : 'undef')."\n");
    print ('$r->protocol = '.$r->protocol()."\n");
    print ('$r->the_request = '.$r->the_request()."\n");
    print ('$r->uri = '.$r->uri()."\n");

    print ("\nSERVER RESPONSE METHODS\n");
    print ('$r->content_type() = '.$r->content_type()."\n");
    print ('$r->status() = '.$r->status()."\n");
    print ('$r->status_line() = '.$r->status_line()."\n");

    print ("\nSERVER CONFIGURATION METHODS\n");
    print ('$r->dir_config(\'CONFIG\') = '.(defined $r->dir_config('CONFIG') ? ('\''.$r->dir_config('CONFIG').'\'') : 'undef').";\n");

    print ("\nGLOBAL VARIABLES\n");
    print ('$ENV{MOD_PERL} = '.(defined $ENV{MOD_PERL} ? ('\''.$ENV{MOD_PERL}.'\'') : 'undef').";\n");
    print ('$ENV{GATEWAY_INTERFACE} = '.(defined $ENV{GATEWAY_INTERFACE} ? ('\''.$ENV{GATEWAY_INTERFACE}.'\'') : 'undef').";\n");
}

1;
