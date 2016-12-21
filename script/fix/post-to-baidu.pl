#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../../lib";
use Pod::Usage;
use Getopt::Long;
use HaoP2P;

my $product_rs = HaoP2P->rset('Product');

open my $fh, '>', 'urls.txt' || die $!;
my $items = 0;

foreach my $product ( $product_rs->all ) {
    if ( $items < 2000 ) {
        print $fh sprintf( "%s/%s\n", 'http://www.haop2p.net/product', $product->id );
    } else {
        close $fh;
        my @results = `curl -H 'Content-Type:text/plain' --data-binary \@urls.txt "http://data.zz.baidu.com/urls?site=www.haop2p.net&token=cxDxKFfzIp3jwtf3"`;
        print "@results\n";

        open $fh, '>', 'urls.txt' || die $!;
        $items = 0;
    }
    $items++;
}

