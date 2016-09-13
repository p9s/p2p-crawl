package HaoP2P::Schema::Versioned;

use base 'DBIx::Class::Schema::Versioned';

package DBIx::Class::Version::Table;
__PACKAGE__->table('version');

# and register the altered class
package DBIx::Class::Version;
__PACKAGE__->register_class( 'Table', 'DBIx::Class::Version::Table' );


1;
