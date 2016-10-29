package HaoP2P::Schema::ResultSet;
use utf8;
use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

sub schema {
    return shift->result_source->schema;
}

sub rset {
    my $self =shift;
    return $self->schema->resultset(shift);
}

1;
