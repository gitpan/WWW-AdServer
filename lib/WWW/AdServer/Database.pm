package WWW::AdServer::Database;
use Moo;

has dsn => (
    is       => 'ro',
    required => 1,
);

has type => (
    is       => 'rw',
);

has db => (
    is    => 'rw',
);


sub BUILD {
    my ($self) = @_;

    if (not $self->type) {
        if ($self->dsn =~ /\.yml$/) {
            $self->type('YAML');
            with 'WWW::AdServer::Database::YAML';
            $self->db( $self->load($self->dsn) );
            #$self->db( WWW::AdServer::Database::YAML->new );
            #$self->db->load($self->dsn);
        }
    }
    return;
}

1;
