#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Data::Dumper;
use Test::More;
use FindBin qw/$Bin/;
use lib "$Bin/../../../lib";

my $debug =  shift || 0;

BEGIN {
    use_ok 'HaoP2P::Bots::Eloancn';
}

my $bots = HaoP2P::Bots::Eloancn->new( debug => $debug );
my $items = $bots->search;

diag Dumper $items if $debug;

done_testing;
