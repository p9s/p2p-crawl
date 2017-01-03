package HaoP2P::Bots;
use utf8;
use Moo;
use Types::Standard qw/InstanceOf/;
use Util;
use HaoP2P;

use URI;
use feature qw/say state/;

use namespace::clean;

has Site => ( is => 'ro', isa => InstanceOf ['HaoP2P::Schema::Result::P2PSite'], builder => 1, lazy => 1 );
has ua => ( is => 'rw', isa => InstanceOf ['Mojo::UserAgent'], builder => 1, lazy => 1 );

sub _build_Site {
    my $self = shift;
    state $p2p_site = HaoP2P->rset('P2PSite')->search( { site_index => $self->site_index }, { rows => 1 } )->single;

    cluck 'No P2PSite found!' unless $p2p_site;
    return $p2p_site;
}

sub _build_ua {
    return get_ua();
}

sub abs_url {
    my $self = shift;
    my $url  = shift;

    return URI->new_abs( $url, $self->site )->canonical->as_string;
}

sub abs_url_with_params {
    my $self   = shift;
    my $url    = shift;
    my $params = shift;

    my $uri = URI->new_abs( $url, $self->site );
    $uri->query_form($params) if $params;
    return $uri->canonical->as_string;
}

sub store {
    my $self  = shift;
    my $items = shift;

    if ( ref($items) eq 'ARRAY' ) {
        foreach my $item (@$items) {
            $self->_update_or_create_product($item);
        }
    }
    elsif ( ref($items) eq 'HASH' ) {
        $self->_update_or_create_product($items);
    }
}

sub _update_or_create_product {
    my $self = shift;
    my $item = shift;
    unless ( $item->{uniq_id} ) {
        full_logs( "Item UNIQ_ID not found: " . to_json($item) );
        return;
    }

    my $product = $self->Site->find_product( $item->{uniq_id} );
    if ($product) {
        $product->update_product($item);
    }
    else {
        $self->Site->create_product($item);
    }
}

sub dump_html {
    my $self = shift;
    my $tx   = shift;

    open my $fh, '>', '/tmp/html_debug_body.html' || die "$!\n";
    print $fh $tx->res->body;
    close $fh;
}

1;
