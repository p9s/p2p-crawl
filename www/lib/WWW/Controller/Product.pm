package WWW::Controller::Product;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $c = shift;
  my $product_id = $c->param('haop2p_product_id');

  my $product_rs = HaoP2P->rset( 'Product' );
  my $product = $product_rs->find( $product_id );

  $c->stash( product => $product );
  $c->stash( title => $product->title );
}


1;
