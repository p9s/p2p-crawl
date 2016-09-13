package HaoP2P::Schema::Result::Product;
use utf8;
use Moo;
use strictures 2;
use Util qw/now/;

use namespace::clean;

extends 'HaoP2P::Schema::Result';

__PACKAGE__->table('product');
__PACKAGE__->add_columns(
    id          => { data_type => 'integer', is_nullable => 0, is_auto_increment => 1 },
    p2p_site_id => { data_type => 'integer', is_nullable => 0, },
    title       => { data_type => 'varchar', is_nullable => 1, size              => 255 },
    uniq_id     => { data_type => 'varchar', is_nullable => 0, size              => 255 },
    url         => { data_type => 'varchar', is_nullable => 0, size              => 255 },
    tags       => { data_type => 'varchar', is_nullable => 0,    size             => 255, serializer_class => 'JSON' },
    progress   => { data_type => 'varchar', is_nullable => 1,    size             => 32 },
    properties => { data_type => 'text',    is_nullable => 1,    serializer_class => 'JSON' },
    status     => { data_type => 'varchar', size        => '16', default_value    => 'on' },

    created_at => { data_type => 'datetime', default_value => \'CURRENT_TIMESTAMP', timezone => 'Asia/Shanghai' },
    updated_at => { data_type => 'datetime', is_nullable => 1, datetime_undef_if_invalid => 1, timezone => 'Asia/Shanghai' },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( 'p2p_site_id_uniq_id', [qw/p2p_site_id uniq_id/] );
__PACKAGE__->belongs_to( 'site' => 'HaoP2P::Schema::Result::P2PSite', 'p2p_site_id' );


sub update_product {
    my $self = shift;
    my $product = shift;

    $product->{updated_at} = now;
    return $self->update( $product );
}

1;
