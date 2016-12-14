package WWW::Controller::Site;
use Mojo::Base 'Mojolicious::Controller';

my $site_rs = HaoP2P->rset('P2PSite');

sub index {
    my $c = shift;

    $c->stash( sites => $site_rs->all_sites );
}

sub detail {
    my $c       = shift;
    my $site_id = $c->param('site_id') || 1;
    my $page    = $c->param('page') || 1;

    my $site = $site_rs->find($site_id) if $site_id;
    if ($site) {
        $c->stash( site => $site );
        my $products = $site->newest_products($page);
        $c->stash( products => [$products->all] );
        $c->stash( pager => $products->pager );
    }
}

1;
