#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Data::Dumper;
use Test::More;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";

BEGIN {
    use_ok 'HaoP2P';
}

my $haop2p = new HaoP2P;
ok( $haop2p->schema, "haop2p schema ok" );

done_testing;

