#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use HaoP2P;

my $schema = HaoP2P->schema;

chdir "$Bin/..";

# not a versioned database? deploy it.
unless ( $schema->get_db_version ) {
    $schema->deploy;
}
else {
    $schema->upgrade;
}
