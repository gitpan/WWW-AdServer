package Apache::Emulator;
$VERSION = 0.03;
use strict;
use Carp;
use Apache::Emulator::Constants;
use Apache;
use Apache::Constants;

#-----------------------------------------------------------------------

=head1 NAME

Apache::Emulator - Emulates the mod_perl request object from CGI

=head1 VERSION

This document refers to version 0.03 of Apache::Emulator, released 
November 20, 2001.

=head1 SYNOPSIS

use Apache::Emulator;

my $r = Apache::Emulator->new( %config );

=head1 DESCRIPTION

I work in a firm that uses Netscape as its front-line webserver, but I
prefer to code my Perl using mod_perl rather than CGI. I also have an 
account on an internal Apache server running mod_perl, but I don't have
admin rights to restart the webserver while I'm developing code [nor am
I allowed to run my own copy of Apache]. I also like to develop web 
applications that *will* run on a CGI platform, but will run *very
fast* on a mod_perl platform.

The solution? Emulate mod_perl within the CGI environment. It's slower
than traditional CGI, but you can develop for both platforms and deploy
to mod_perl once your code is finished. No more apache restarts!

I've added functionality as I've gone along, so don't expect every
Apache method call to work. If it's documented below, it exists. If it
isn't documented, it doesn't exist, and you should send me the code to
implement the function. That's the way open source works.

Much of the documentation is a straight copy from the Apache pods.
If a method doesn't work as documented, tell me. Even if you don't have
a fix, telling me that there's a problem will usually elicit the right
response.

Some stuff will never work. Subrequests are likely to be in this
category. I don't use them very often, so I'm not too bothered.

=cut

#-----------------------------------------------------------------------

=head1 CONSTRUCTOR


use Apache::Emulator;

my $r = Apache::Emulator->new( PerlHandler => 'Your::ModPerl::Module' );

my $r = Apache::Emulator->new( PerlHandler => 'Your::ModPerl::Module', 
PerlSetVar => { MYCONFIG => '/var/myapp.conf', ADMIN => 
'nigel:dave:jon' });

After you've constructed your Apache::Emulator object, pass it into the
handler subroutine of your mod_perl module. Everything should work 
perfectly. Maybe.

=cut

#-----------------------------------------------------------------------

sub new
{
    my ($caller, %conf) = @_;

    my $r;

    my $PerlHandler = $conf{PerlHandler} || die ('Please supply a PerlHandler in the constructor');
    eval('require '.$PerlHandler);
    die ($@."\n") if $@;

    $r = Apache->request( %conf );

    my $eval_string = $PerlHandler.'::handler($r)';
    eval($eval_string);
    die ($@."\n") if $@;

    return $r;
}

package Apache;
use strict;
use HTTP::Status;

sub request
{
    my ($caller, %conf) = @_;

    my $caller_is_obj = ref($caller);
    my $class = $caller_is_obj || $caller;

    my $r = bless {}, $class;
    $r->{conf} = \%conf;
    $ENV{MOD_PERL} = 'mod_perl/1.24';
    $ENV{GATEWAY_INTERFACE} = 'CGI-Perl/1.1';
    return $r;
}

#-----------------------------------------------------------------------

=head1 CLIENT REQUEST METHODS

=cut

#-----------------------------------------------------------------------

=head2 $r->args()

The $r->args method will return the contents of the URI query string. 
When called in a scalar context, the entire string is returned. When 
called in a list context, a list of parsed key => value pairs are 
returned, i.e. it can be used like this:

$query = $r->args;

%in = $r->args;

=cut

#-----------------------------------------------------------------------

sub ARGS {
    my($r, $val) = @_;
    my $args = @_ > 1 ? $r->query_string($val) : $r->query_string;
    return $args unless wantarray;
    parse_args(1, $args);
}

*args = \&ARGS unless defined &args;

#-----------------------------------------------------------------------

=head2 $r->get_remote_host()

Lookup the client's DNS hostname. Don't expect double-reverse lookups
to work.

=cut

#-----------------------------------------------------------------------

sub get_remote_host
{
    my ($r,$arg) = @_;
    if ((!defined $arg) or ($arg == 1) or ($arg == 2)){
	$r->{remote_host} = $ENV{REMOTE_HOST} || $ENV{REMOTE_ADDR};
    } else {
	$r->{remote_host} = $ENV{REMOTE_HOST};
    }
    return $r->{remote_host};
}

#-----------------------------------------------------------------------

=head2 $r->header_only

Returns true if the client is asking for headers only, e.g. if the 
request method was HEAD.

=cut

#-----------------------------------------------------------------------

sub header_only
{
    my $r = $_[0];
    unless (defined $r->{header_only}){
	$r->{header_only} = ($r->method() =~ /^HEAD$/i) ? 1 : 0;
    }
    return $r->{header_only};
}

#-----------------------------------------------------------------------
#
# $r->header_out($header, $value) - Change the value of a response 
# header, or create a new one. You should not define any "Content-XXX" 
# headers by calling this method, because these headers use their own 
# specific methods.
#
#-----------------------------------------------------------------------

sub header_out
{
    my ($r,$header,$value) = @_;
    if (@_ == 3){
	if (defined $value){
	    $r->{header}->{$header} = $value;
	} else {
	    delete $r->{header}->{$header};
	}
    }
    return $r->{header}->{$header} if exists $r->{header}->{$header};
}

sub header_in
{
    my ($r,$header,$value) = @_;
    $header = uc $header;
    if (@_ == 3){
	if (defined $value){
	    if (exists $ENV{$header}){
		$ENV{$header} = $value;
	    } else {
		$ENV{'HTTP_'.$header} = $value;
	    }
	} else {
	    delete $ENV{'HTTP_'.$header};
	    delete $ENV{$header};
	}
    }
    if (exists $ENV{$header}){
	return $ENV{$header};
    } elsif (exists $ENV{'HTTP_'.$header}){
	return $ENV{'HTTP_'.$header};
    } else {
	# fall through
    }
}

#-----------------------------------------------------------------------

=head2 $r->method()

Returns the request method. It will be a string such as "GET", "HEAD" 
or "POST".

=cut

#-----------------------------------------------------------------------

sub method
{
    my $r = shift;
    my $method;
    unless (exists $r->{method}){
	$r->{method} = $ENV{REQUEST_METHOD};
    }
    return $r->{method};
}

#-----------------------------------------------------------------------

=head2 $r->path_info()

The $r->path_info method will return what is left in the path after the 
URI --> filename translation. 

=cut

#-----------------------------------------------------------------------

sub path_info
{
    my $r = shift;
    $r->{path_info} = $ENV{PATH_INFO} unless exists $r->{path_info};
    return $r->{path_info};
}

#-----------------------------------------------------------------------

=head2 $r->protocol

The $r->protocol method will return a string identifying the protocol 
that the client speaks. Typical values will be "HTTP/1.0" or "HTTP/1.1". 

=cut

#-----------------------------------------------------------------------

sub protocol
{
    my $r = shift;
    $r->{protocol} = $ENV{SERVER_PROTOCOL} unless exists $r->{protocol};
    $r->{protocol} = 'HTTP/1.0' unless defined $r->{protocol};
    return $r->{protocol};
}

#-----------------------------------------------------------------------

=head2 $r->the_request

The request line sent by the client, handy for logging, etc.

=cut

#-----------------------------------------------------------------------

sub the_request
{
    my $r = shift;
    unless (exists $r->{the_request}){
	my $full_uri = defined $r->args() ? $r->uri().'?'.$r->args() : $r->uri();
	$r->{the_request} = join ' ', $r->method, $full_uri, $r->protocol;
    }
    return $r->{the_request};
}

#-----------------------------------------------------------------------

=head2 $r->uri()

Returns the requested URI minus optional query string.

=cut

#-----------------------------------------------------------------------

sub uri
{
    my $r = shift;
    my $uri;
    if (exists $r->{uri}){
	$uri = $r->{uri};
    } else {
	$uri = $r->{uri} = $ENV{SCRIPT_NAME}.(defined $r->path_info ? $r->path_info : '');
    }
    return $uri;
}

#-----------------------------------------------------------------------

=head1 SERVER RESPONSE METHODS

=cut

#-----------------------------------------------------------------------

=head2 $r->content_type( [$newval] )

Get or set the content type being sent to the client. Content types are 
strings like "text/plain", "text/html" or "image/gif". This corresponds
to the "Content-Type" header in the HTTP protocol. 

=cut

#-----------------------------------------------------------------------

sub content_type
{
    my ($r,$newval) = @_;
    if (defined $newval){
	$r->{content_type} = $newval;
    }
    return $r->{content_type};
}

#-----------------------------------------------------------------------

=head2 $r->status( [$integer] )

Get or set the reply status for the client request.

=cut

#-----------------------------------------------------------------------

sub status
{
    my ($r,$integer) = @_;
    if (defined $integer){
	$r->{status} = $integer;
    }
    return $r->{status};
}

#-----------------------------------------------------------------------

=head2 $r->status_line( [$string] )

Get or set the response status line. The status line is a string like 
"200 Document follows" and it will take precedence over the value 
specified using the $r->status() described above.

=cut

#-----------------------------------------------------------------------

sub status_line
{
    my ($r,$string) = @_;
    if (defined $string){
	if ((exists $ENV{'PerlXS'}) and ($ENV{'PerlXS'} eq 'PerlIS')){
	    $r->{status_line} = $r->protocol . ' ' .$string."\n";
	} else {
	    $r->{status_line} = 'Status: '.$string."\n";
	}
    } elsif ((!defined $r->{status_line}) and 
	     (defined $r->{status})){
	if ((exists $ENV{'PerlXS'}) and ($ENV{'PerlXS'} eq 'PerlIS')){
	    $r->{status_line} = $r->protocol . ' ' .$r->{status} . ' ' . status_message($r->{status})."\n";
	} else {
	    $r->{status_line} = 'Status: ' .$r->{status} . ' ' . status_message($r->{status})."\n";
	}
    } else {
	# continue
    }
    return $r->{status_line};
}

#-----------------------------------------------------------------------

=head1 SENDING DATA TO THE CLIENT

=cut

#-----------------------------------------------------------------------

=head2 $r->print( @items )

prints!

=cut

#-----------------------------------------------------------------------

sub print
{
    my ($r,@args) = @_;
    CORE::print(@args);
}

#-----------------------------------------------------------------------

=head2 $r->send_http_header( [$content_type] )

Send the response line and all headers to the client. Takes an optional 
parameter indicating the content-type of the response, i.e. 'text/html'.

=cut

#-----------------------------------------------------------------------

sub send_http_header
{
    my ($r,$content_type) = @_;
    if (defined $content_type){
	$r->{content_type} = $content_type;
    }
    $r->print($r->status_line);
    $r->print('Content-type: '.$r->{content_type}."\n") if (defined $r->{content_type});
    my $header;
    foreach $header (keys %{$r->{header}}){
	$r->print($header.': '.$r->{header}->{$header}."\n");
    }
    $r->print("\n");
}

#-----------------------------------------------------------------------

=head1 SERVER CONFIGURATION METHODS

=cut

#-----------------------------------------------------------------------

=head2 $r->dir_config( $key )

Returns the value of a per-directory variable specified by the 
"PerlSetVar" directive (see CONSTRUCTOR, above).

=cut

#-----------------------------------------------------------------------

sub dir_config
{
    my ($r,$key) = @_;
    return defined $key ? $r->{conf}->{PerlSetVar}->{$key} : $r->{conf}->{PerlSetVar};
}

sub exit
{
    exit;
}

#-----------------------------------------------------------------------

=head1 AUTHOR

Nigel Wetters (nwetters@cpan.org)

=head1 COPYRIGHT

Copyright (c) 2001, Nigel Wetters. All Rights Reserved. This module is
free software. It may be used, redistributed and/or modified under the 
same terms as Perl itself.

=cut

#-----------------------------------------------------------------------

sub query_string
{
    my ($r,$val) = @_;
    if (defined $val){
	$r->{query_string} = $ENV{QUERY_STRING} = $val;
    } else {
	$r->{query_string} = $ENV{QUERY_STRING} unless exists $r->{query_string};
    }
    return $r->{query_string};
}

sub PARSE_ARGS {
    my($wantarray,$string) = @_;
    return unless defined $string and $string;
    if(defined $wantarray and $wantarray) {
        return map { Apache::unescape_url_info($_) } split /[=&;]/, $string, -1;
    }
    $string;
}

*parse_args = \&PARSE_ARGS unless defined &parse_args;

sub unescape_url
{
    my $string = $_[0];
    $string =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
    return $string;
}

*unescape_uri = \&unescape_url;

sub unescape_url_info
{
    my $string = $_[0];
    $string =~ s/\+/ /g;
    $string =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
    return $string;
}

*unescape_uri_info = \&unescape_url_info;

#-----------------------------------------------------------------------
#
# True...
#
#-----------------------------------------------------------------------

1;
