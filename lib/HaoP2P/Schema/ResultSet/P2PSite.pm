package HaoP2P::Schema::ResultSet::P2PSite;
use utf8;
use strict;
use warnings;
use base 'HaoP2P::Schema::ResultSet';

sub all_sites {
    my $self  = shift;

    return [$self->search( undef, { order_by => 'id' } )->all];
}


1;
