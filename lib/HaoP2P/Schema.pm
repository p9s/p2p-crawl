package HaoP2P::Schema;
use utf8;
use strictures 2;
use namespace::clean;
use base 'DBIx::Class::Schema';

our $VERSION = 4;

__PACKAGE__->load_namespaces;

__PACKAGE__->load_components(qw/ +HaoP2P::Schema::Versioned /);
__PACKAGE__->upgrade_directory('./ddl');
__PACKAGE__->backup_directory('./backup');

1;
