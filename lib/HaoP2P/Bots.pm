package HaoP2P::Bots;
use utf8;
use Moo;
use Types::Standard qw/InstanceOf/;
use Util;
use URI;
use feature qw/say/;

use namespace::clean;

has ua => ( is => 'ro', isa => InstanceOf ['Mojo::UserAgent'], builder => 1, lazy => 1 );

sub _build_ua {
    return get_ua();
}

sub abs_url {
    my $self = shift;
    my $url = shift;

    return URI->new_abs( $url, $self->site )->canonical->as_string;
}

1;
