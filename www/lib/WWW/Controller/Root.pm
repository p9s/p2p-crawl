package WWW::Controller::Root;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $c = shift;
  my $page = $c->req->param('page');
  my $items = $c->req->param( 'items' );
  $page //= 1;
  $items //= 10;

  my $product_rs = HaoP2P->rset( 'Product' );
  $c->stash(top_products => $product_rs->top_products( $page, $items ) );
}

1;
