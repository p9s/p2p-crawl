package HaoP2P::Schema::Result::P2PSite;
use utf8;
use Moo;
use strictures 2;

use namespace::clean;

extends 'HaoP2P::Schema::Result';

__PACKAGE__->table('p2p_site');
__PACKAGE__->add_columns(
    id          => { data_type => 'integer',  is_nullable   => 0,   is_auto_increment => 1 },
    name        => { data_type => 'varchar',  is_nullable   => 0,   size              => 255 },
    url         => { data_type => 'varchar',  is_nullable   => 0,   size              => 255 },
    enabled     => { data_type => 'integer',  default_value => 0 },
    created_at  => { data_type => 'datetime', default_value => \'CURRENT_TIMESTAMP' },
    site_index  => { data_type => 'varchar',  default_value => '',  size              => 32, },
    aff_url     => { data_type => 'varchar',  is_nullable   => 1, },
    about       => { data_type => 'text' },
    description => { data_type => 'varchar',  size          => 255, default           => '' },
    keywords    => { data_type => 'varchar',  size          => 254, default           => '' },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( 'unique_name', [qw/name/] );
__PACKAGE__->has_many( 'products' => 'HaoP2P::Schema::Result::Product', 'p2p_site_id' );

sub sqlt_deploy_hook {
    my ( $self, $sqlt_table ) = @_;
    $sqlt_table->add_index( name => 'p2p_site_site_index', fields => ['site_index'] );
}

sub find_product {
    my $self    = shift;
    my $uniq_id = shift;

    return $self->rset('Product')->search( { p2p_site_id => $self->id, uniq_id => $uniq_id }, { rows => 1 } )->single;
}

sub create_product {
    my $self = shift;
    my $info = shift;

    my $now = DateTime->now( time_zone => 'Asia/Shanghai' );
    $info->{updated_at} = $now unless $info->{updated_at};
    $info->{created_at} = $now unless $info->{created_at};
    return $self->create_related( 'products', $info );
}

sub newest_products {
    my $self  = shift;
    my $page  = shift || 1;
    my $attrs = { rows => '10', page => $page, order_by => { '-desc' => 'id' } };
    return $self->search_related( 'products', { status => 'on' }, $attrs );
}

1;
