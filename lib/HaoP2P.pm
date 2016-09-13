package HaoP2P;
use utf8;
use feature qw/state/;

use Moo;
use Types::Standard qw/Str HashRef/;

use YAML::Syck qw/LoadFile/;
use Path::Tiny qw/path/;
use HaoP2P::Schema;
use MooX::ClassAttribute;

use namespace::clean;

class_has 'schema' => ( is => 'ro', lazy => 1, builder => '_build_schema' );
class_has 'config' => ( is => 'ro', isa => HashRef, lazy => 1, builder => '_build_config' );
class_has 'dbh'    => ( is => 'ro', lazy => 1, builder => '_build_dbh' );


sub root {
    my $self = shift;

    state $root_path = path(__FILE__)->absolute->parent->parent;

    return path( $root_path, @_ );
}

sub _build_config {
    my $self = shift;
    my $config = LoadFile( $self->root( 'conf', 'config.yaml' )->canonpath );
    return $config;
}

sub _build_schema {
    my $self   = shift;
    my $schema = HaoP2P::Schema->connect( @{ $self->config->{'DBI'} } );
    $schema->storage->dbh->{'mysql_enable_utf8'} = 1;
    $schema->storage->dbh->do('set names utf8');
    return $schema;
}

sub _build_dbh {
    my $self = shift;
    return $self->schema->storage->dbh;
}


1;
