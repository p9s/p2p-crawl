#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Data::Dumper;
use Test::More;
use FindBin qw/$Bin/;
use lib "$Bin/../../lib";

BEGIN {
    use_ok 'HaoP2P::Bots';
}

my $bots = HaoP2P::Bots->new;

done_testing;
