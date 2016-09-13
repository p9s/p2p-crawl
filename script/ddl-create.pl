#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use Pod::Usage;
use Getopt::Long;
use HaoP2P;
use File::Path qw/make_path/;


my ( $preversion, $help );
GetOptions( 'p|preversion:s' => \$preversion, ) or die pod2usage;

my $schema = HaoP2P->schema;

my $sql_dir = "$Bin/../ddl";
make_path $sql_dir unless -d $sql_dir;

my $version = $schema->schema_version;
$schema->create_ddl_dir( 'MySQL', $version, $sql_dir, $preversion );
