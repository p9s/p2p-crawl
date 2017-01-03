package HaoP2P::Schema::Result::News;
use utf8;
use Moo;
use strictures 2;
use Util qw/now/;

use namespace::clean;

extends 'HaoP2P::Schema::Result';

__PACKAGE__->table('news');
__PACKAGE__->add_columns(
    id       => { data_type => 'integer', is_nullable => 0, is_auto_increment => 1 },
    title    => { data_type => 'varchar', is_nullable => 1, size              => 255 },
    uniq_id  => { data_type => 'varchar', is_nullable => 0, size              => 255 },
    url      => { data_type => 'varchar', is_nullable => 0, size              => 255 },
    tags     => { data_type => 'text',    is_nullable => 0, serializer_class  => 'JSON' },
    descript => { data_type => 'text', },
    content  => { data_type => 'text', },

    is_public => { data_type => 'integer', default_value => 0 },

    created_at => { data_type => 'datetime', default_value => \'CURRENT_TIMESTAMP', timezone => 'Asia/Shanghai' },
);

__PACKAGE__->set_primary_key('id');

1;
