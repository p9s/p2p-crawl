package HaoP2P::Bots::XinHeHui;
use utf8;

# ###############################
# Author: Mc Cheung
# Email:  mc.cheung@aol.com
# Date:   2016-12-21
# ###############################

use Moo;
use Types::Standard qw/Str Int/;
use Util;
use List::MoreUtils qw/uniq/;
use Encode;
use Data::Dumper;
use feature qw/say/;

use namespace::clean;

has site       => ( is => 'ro', isa => Str, default => 'https://www.xinhehui.com' );
has debug      => ( is => 'ro', isa => Int, default => 1 );                            # fix_me_last
has max_page   => ( is => 'rw', isa => Int, default => 99 );
has site_index => ( is => 'ro', isa => Str, default => 'xinhehui_com' );               # hfax_com
extends 'HaoP2P::Bots';

sub search {
    my $self = shift;
    my @items;

    my @urls = (
        {   url => '/Financing/Invest/ajaxplist?c=1&sort_id=&sort=&b_type=&time_limit=&bid_st=&show_new=1', tag => '新手专区', },
        {   url => '/Financing/Invest/ajaxplist?c=2&sort_id=&sort=&b_type=&time_limit=&bid_st=&show_new=0', tag => '日益升', },
        {   url => '/Financing/Invest/ajaxplist?c=6&sort_id=&sort=&b_type=&time_limit=&bid_st=&show_new=0', tag => '速兑通', }
    );

    foreach my $h_url (@urls) {
        # 新手专区
        my $url      = $self->abs_url( $h_url->{url} );
        my $tag = $h_url->{tag} || '新手专区';

        my $max_page = $self->max_page;
        while ( $url && $max_page ) {
            $max_page--;
            full_logs("# GET $url") if $self->debug;
            my $tx = $self->ua->get($url)->res->dom;
            $tx->find('div[class~="proListBox"]')->each(
                sub {
                    my ( $e, $i ) = @_;

                    # find process next page
                    full_logs("The $i items") if $self->debug;

                    my $info = $self->parse_info($e, $tag);
                    push @items, $info;    # unless $self->debug;
                    $self->store($info) unless $self->debug;
                }
            );

            # findout next page
            my $next_url = get_next_page($tx);
            $url = $next_url ? $self->abs_url( $h_url->{url} . sprintf('&p=%s',  $next_url ) ) : undef;
        }

    }
    return \@items;
}

sub parse_info {
    my $self = shift;
    my $e = shift;
    my $tag = shift || '新手专享';

    # find content
    my $info = {};

    # title
    my $title = $e->find('h4 a')->first;
    $info->{title} = clean_text( $title->all_text ) if $title;

    # url
    $info->{url} = $self->abs_url( $title->attr('href') ) if $title;

    # uniq_id
    ( $info->{uniq_id} ) = $info->{url} =~ /id=(\d+)/ if $info->{url};

    # tags, don't forget manual tag, forexample: '新手专享';
    $e->find('h4 span a')->each(
        sub {
            my $e = shift;
            push @{ $info->{tags} }, clean_text( $e->attr('title') );
        }
    );
    push @{ $info->{tags} }, $tag;

    # progress
    my $progress = $e->find('em[class="propress-data"]')->first;
    $info->{progress} = clean_text( $progress->all_text ) if $progress;

    # properties
    $e->find('span[class~="proP7"]')->each(
        sub {
            my $e     = shift;
            my $label = $e->find('p[class="txt01"]')->first;
            $label = clean_text( $label->all_text ) if $label;
            $e->at('p[class="txt01"]')->remove;
            my $value = clean_text( $e->all_text );
            push @{ $info->{properties} }, { label => $label, value => $value } if $label && $value;
        }
    );

    $info = fix_params($info);

    # status 'on/off'
    $info->{status} = 'on';

    return $info;
}

sub fix_params {
    my $info = shift;
    @{ $info->{tags} } = uniq @{ $info->{tags} };
    foreach my $property ( @{ $info->{properties} } ) {
        my $label = $property->{label} // '';
        my $value = $property->{value} // '';

        if ( $label =~ /预期年化收益率/ ) {
            $info->{interest} = $1 if $value =~ /([\d\.]+)/;
        }

        if ( $label =~ /项目期限/ ) {
            $info->{days} = $1 if $value =~ /(\d+)/;
            $info->{days} = 0 unless $info->{days};
            $info->{days} *= 30 if $label =~ /月/;
            $info->{days} *= 30 * 12 if $label =~ /年/;
        }

        if ( $label =~ /起投金额/ ) {
            $info->{min_amount} = $1 if $value =~ /([\d,\.]+)/;
            $info->{min_amount} =~ s/[,]//g;

            $info->{min_amount} = int( $info->{min_amount} );
            $info->{min_amount} .= '00'   if $value =~ /百元/;
            $info->{min_amount} .= '000'  if $value =~ /千元/;
            $info->{min_amount} .= '0000' if $value =~ /万元/;
        }

        $info->{pay_method} = $value if $label =~ /还款方式/;
    }
    $info->{min_amount} = 0 unless $info->{min_amount};
    return $info;
}

sub get_next_page {
    my $e = shift;

    my $pages = $e->find( 'div[class="page pageWraper"] a');
    return unless $pages;

    my $next = $pages->grep( sub { $_->all_text =~ /^>$/ } );
    return unless $next;

    $next = $next->first;
    return unless $next;
    
    $next = $next->attr( 'href' );
    return unless $next;

    my ( $page ) = $next =~ /p=(\d+)/;
    return $page;
}

1;
# vim:set ts=4 sw=4 et:
