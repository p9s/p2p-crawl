package WWW::Controller::News;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

use Mojo::Log;
my $log = Mojo::Log->new;
my $news_rs = HaoP2P->rset('News');

sub index {
    my $c = shift;

    my $page  = $c->req->param('page');
    my $items = $c->req->param('items');
    $page  //= 1;
    $items //= 10;

    my $news = $news_rs->top_news( $page, $items );
    $c->stash( top_news => [$news->all] );
    $c->stash( pager    => $news->pager );
}

sub detail {
    my $c          = shift;
    my $news_id    = $c->stash('news_id');
    my $news_title = $c->stash('news_title');

    $c->stash( news => $news_rs->find($news_id) );
    my $news = $news_rs->top_news( 1, 20 );
    $c->stash( news_related => [$news->all] );
}

1;
