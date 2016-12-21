#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../../lib";
use Pod::Usage;
use Getopt::Long;
use HaoP2P;


my $product_rs = HaoP2P->rset( 'Product' );

open my $fh, '>', 'urls.txt' || die $!;
foreach my $product ( $product_rs->all ) {
#push @urls, sprintf( '%s/%s', 'http://www.haop2p.net/product', $product->id );
    print $fh sprintf( "%s/%s\n", 'http://www.haop2p.net/product', $product->id );
}
close $fh;

`curl -H 'Content-Type:text/plain' --data-binary @urls.txt "http://data.zz.baidu.com/urls?site=www.haop2p.net&token=cxDxKFfzIp3jwtf3"`
