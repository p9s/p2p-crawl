package HaoP2P::Schema::Result::P2PSite;
use utf8;
use Moo;
use strictures 2;

use namespace::clean;

extends 'HaoP2P::Schema::Result';

__PACKAGE__->table('p2p_site');
__PACKAGE__->add_columns(
    id         => { data_type => 'integer',  is_nullable   => 0, is_auto_increment => 1 },
    name       => { data_type => 'varchar',  is_nullable   => 0, size              => 255 },
    url        => { data_type => 'varchar',  is_nullable   => 0, size              => 255 },
    enabled    => { data_type => 'integer',  default_value => 0 },
    created_at => { data_type => 'datetime', default_value => \'CURRENT_TIMESTAMP' },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( 'unique_name', [qw/name/] );

1;
