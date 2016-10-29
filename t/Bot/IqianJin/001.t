#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Data::Dumper;
use Test::More;
use FindBin qw/$Bin/;
use lib "$Bin/../../../lib";

BEGIN {
    use_ok 'HaoP2P::Bots::IqianJinCom';
}

my $bots = HaoP2P::Bots::IqianJinCom->new;

my $items = $bots->search;

diag Dumper $items;

done_testing;
