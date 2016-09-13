package HaoP2P::Schema::Result;
use utf8;
use Moo;
use strictures 2;

use Data::Dumper;
use namespace::clean;

extends 'DBIx::Class::Core';

__PACKAGE__->load_components(
#        Helper::Row::ForceDefaultValueGet
#        InflateColumn::Object::Enum
#        Helper::Row::ToJSON
    qw/
        InflateColumn::DateTime
        InflateColumn::Serializer
        /
);

sub _dumper_hook { $_[0] = bless { %{ $_[0] }, _result_source => undef }, ref( $_[0] ); }

sub dump {
    my $self = shift;
    local $Data::Dumper::Freezer = '_dumper_hook';
    print STDERR Dumper $self;
}

sub schema {
    return shift->result_source->schema;
}

sub rset {
    my $self = shift;
    return $self->result_source->resultset unless scalar @_;
    return $self->result_source->schema->resultset( $_[0] );
}

1;
