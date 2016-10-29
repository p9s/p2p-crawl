package HaoP2P::Schema::ResultSet::Product;
use utf8;
use strict;
use warnings;
use base 'HaoP2P::Schema::ResultSet';

sub top_products {
  my $self = shift;
  my $page = shift // 1;
  my $items = shift // 10;


  return [$self->search(
                        {
                         status => 'on',
                        },
                        {
                         order_by => { -desc => 'id' },
                         rows     => $items,
                         page => $page,
                        }
                       )->all];
}

sub create_product {
  my $self = shift;
  my $params = shift;
}

1;
