package WWW::AdServer;
use Moo;
#use MooX::late;

#has dsn => (is => 'ro', required => 1);
#has db  => (is => 'ro', required => 1, isa => 'WWW::AdServer::Database');
use WWW::AdServer::Database;

#sub BUILDARGS {
#	my ($class, %args) = @_;
#	if ($args{dsn}) {
#		$args{db} = WWW::AdServer::Database->new(dsn => $args{dsn});
#	}
#	return \%args;
#}

1;

