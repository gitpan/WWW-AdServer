package WWW::AdServer::Advert;
$VERSION = '0.01';
use strict;
use vars qw ( $VERSION );
use Carp;

sub new
{
    my ($class, %arg) = @_;
    my $self = bless {
	displayer    => $arg{displayer} || carp ('no Displayer object passed to Advert object'),
	logger       => $arg{logger}    || carp ('no Logger object passed to Advert object'),
	ad_conf      => $arg{adconf}    || carp('no ad config directory passed to Advert object'),
	exchange_id  => $arg{member_id},
	zones        => $arg{zones},
	advert       => $arg{advert},

	link         => undef,   #
        image        => undef,   #
	image_height => undef,   #
	image_width  => undef,   #
	alt_tag      => undef,   #  THESE ARE PASSED TO Displayer OBJECT

    }, $class;

    carp ('must construct an Advert with zone, advert, or member_id') 
	unless (
		(defined $self->{zones}) or
		(defined $self->{advert})
		);

    $self->_check_path;
    $self->_get_advert or return undef;
    return $self;
}

sub _check_path
{
    my $self = shift;
    my $adconf = $self->{ad_conf};
    if (!(-d $adconf)){
	croak "please make the config directory and chmod 0777";
    } elsif (!(-d $adconf.'/admin')){
	my $old_mask = umask();
	umask(0000);
	mkdir $adconf.'/admin';
	mkdir $adconf.'/admin/logs';
	umask($old_mask);
    } elsif (!(-d $adconf.'/admin/logs')){
	my $old_mask = umask();
	umask(0000);
	mkdir $adconf.'/admin/logs';
	umask($old_mask);
    } elsif (!(-d $adconf.'/adverts')){
	my $old_mask = umask();
	umask(0000);
	mkdir $adconf.'/adverts';
	umask($old_mask);
    } elsif (!(-d $adconf.'/logs')){
	my $old_mask = umask();
	umask(0000);
	mkdir $adconf.'/logs';
	umask($old_mask);
    } elsif (!(-d $adconf.'/zones')){
	my $old_mask = umask();
	umask(0000);
	mkdir $adconf.'/zones';
	umask($old_mask);
    } else {
	# continue
    }
}

sub redirect
{
    my $self = shift;
    $self->{displayer}->redirect($self);    
}

sub display
{
    my $self = shift;
    $self->{displayer}->display($self);
}

sub log_impression
{
    my $self = shift;
    $self->{logger}->log_impression($self);
}

sub log_clickthru
{
    my $self = shift;
    $self->{logger}->log_clickthru($self);
}

sub get_link
{
    my $self = shift;
    $self->_get_advert unless defined $self->{link};
    return $self->{link};
}

sub get_image
{
    my $self = shift;
    $self->_get_advert unless defined $self->{image};
    return $self->{image};
}

sub get_alt
{
    my $self = shift;
    $self->_get_advert unless defined $self->{alt_tag};
    return $self->{alt_tag};
}

sub get_height
{
    my $self = shift;
    $self->_get_advert unless defined $self->{image_height};
    return $self->{image_height};
}

sub get_width
{
    my $self = shift;
    $self->_get_advert unless defined $self->{image_width};
    return $self->{image_width};
}

sub get_advert
{
    my $self = shift;
    $self->_get_advert unless defined $self->{advert};
    return $self->{advert};
}

sub set_advert
{
    my ($self,$ad_id) = @_;
    $self->{advert} = $ad_id;
    $self->_get_advert;
}

sub get_zones
{
    my $self = shift;
    return @{$self->{zones}};
}

sub _get_advert
{
    my $self = shift;
    my $advert_path;
    if (defined $self->{advert}){
	$advert_path = $self->{ad_conf}.'/adverts/'.$self->{advert};
    } else {
	my @zone = @{ $self->{zones} };
	my $zone = $zone[ int(rand $#zone + 1) ];
	my $zone_path = $self->{ad_conf}.'/zones/'.$zone;

	my $advert;
	my $cumulative_weight=0;

	return undef unless (-e $zone_path);
	open (ZONE, "<", $zone_path) or return undef;
	while ( my $advert_conf = (<ZONE>) ){
	    chomp($advert_conf);
	    if ($advert_conf =~ /^advert=(.*?);weight=(\d+)$/){
		my ($adname,$weighting) = ($1,$2);
		$cumulative_weight += $weighting;
		$advert->{$adname} = [$cumulative_weight,$weighting];
	    }
	}
	close ZONE;

	my $rand = rand $cumulative_weight;
	foreach my $adchoice (keys %$advert){
	    if (( $rand <= $advert->{$adchoice}->[0] ) 
		and ( $rand > ( $advert->{$adchoice}->[0] - $advert->{$adchoice}->[1] ) ))
	    {
		$self->{advert} = $adchoice;
		$advert_path = $self->{ad_conf}.'/adverts/'.$self->{advert};
		last;
	    }
	}
    }
    return undef unless (-e $advert_path);
    open (ADVERT, "<", $advert_path) or return undef;
    chomp($self->{link}         = <ADVERT>);
    chomp($self->{image}        = <ADVERT>);
    chomp($self->{alt_tag}      = <ADVERT>);
    chomp($self->{image_height} = <ADVERT>);
    chomp($self->{image_width}  = <ADVERT>);
    close ADVERT;
    
    if ((defined $self->{link}) and ($self->{link} =~ /^link=(.*)$/)){
	$self->{link} = $1;
    } else {
	return undef;
    }

    if ((defined $self->{image}) and ($self->{image} =~ /^image=(.*)$/)){
	$self->{image} = $1;
    } else {
	return undef;
    }

    if ((defined $self->{alt_tag}) and ($self->{alt_tag} =~ /^alt=(.*)$/)){
	$self->{alt_tag} = $1;
    } else {
	return undef;
    }

    if ((defined $self->{image_height}) and ($self->{image_height} =~ /^height=(.*)$/)){
	$self->{image_height} = $1;
    } else {
	return undef;
    }

    if ((defined $self->{image_width}) and ($self->{image_width} =~ /^width=(.*)$/)){
	$self->{image_width} = $1;
    } else {
	return undef;
    }

    return 1;
}

1;
__END__
=head1 NAME

WWW::AdServer::Advert - represents a web advert in Perl

=head1 SYNOPSIS

  use WWW::AdServer::Advert;

  my $advert = WWW::AdServer::Advert->new( displayer=>$display, zone=>$zone );

  $advert->display;

=head1 DESCRIPTION

Represents an advert.

=head2 $object = WWW::AdServer::Advert->new( %hash );

Constructor for an Advert object. Must be passed a hash of arguments containing the Displayer object, and one of exhange_id (memeber id for banner exchange), zones (zone ids for serving ads), or advert (advert id).

=head2 $object->display;

Outputs the advert to the client.

=head2 EXPORT

None by default.

=head1 AUTHOR 

Nigel Wetters (nwetters@cpan.org)

=head1 COPYRIGHT 

Copyright (c) 2001, Nigel Wetters. All Rights Reserved. This module is free software. 
It may be used, redistributed and/or modified under the same terms as Perl itself. 

=cut
