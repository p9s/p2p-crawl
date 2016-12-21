package HaoP2P::Bots::XiaoNiu88;
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

has site       => ( is => 'ro', isa => Str, default => 'http://www.xiaoniu88.com/' );
has debug      => ( is => 'ro', isa => Int, default => 1 );                             # fix_me_last
has max_page   => ( is => 'rw', isa => Int, default => 99 );
has site_index => ( is => 'ro', isa => Str, default => 'xiaoniu88_com' );               # hfax_com
extends 'HaoP2P::Bots';

sub search {
    my $self = shift;
    my @items;

    my @urls = ( { url => '/product/financing', tag => '灵活理财' }, { url => '/product/smart', tag => '月月牛' }, { url => '/product/investment', tag => '固收理财' }, { url => '/product/planning', tag => '安心牛' }, { url => '/product/month/interest', tag => '月息牛' }, { url => '/product/listing', tag => '散标列表' }, { url => '/product/newbie', tag => '新手专享' }, { url => '/product/transfer', tag => '转让' }, );

    foreach my $h_url (@urls) {

        # 新手专区
        my $url      = $self->abs_url( $h_url->{url} );
        my $max_page = $self->max_page;
        while ( $url && $max_page ) {
            $max_page--;
            full_logs("# GET $url") if $self->debug;
            my $tx = $self->ua->max_redirects(5)->get($url)->res->dom;
            $tx->find('div[class~="item"]')->each(
                sub {
                    my ( $e, $i ) = @_;
                    # find process next page
                    full_logs("The $i items") if $self->debug;

                    my $info = $self->parse_info( $e, $h_url->{tag} );
                    push @items, $info;    # unless $self->debug;
                    $self->store($info) unless $self->debug;
                }
            );

            # findout next page
            my $next_page = get_next_page($tx);
            $url = $next_page ? sprintf( '%s/%s', $self->abs_url( $h_url->{url} ), $next_page ) : undef;
        }

    }
    return \@items;
}

sub parse_info {
    my $self = shift;
    my $e    = shift;
    my $tag  = shift;

    # find content
    my $info = {};

    # title
    $e->find('div[class="title"]')->each(
        sub {
            my $e     = shift;
            my $title = $e->find('a')->first;
            $info->{title} = clean_text( $title->all_text ) if $title;

            # url
            $info->{url} = $self->abs_url( $title->attr('href') ) if $title;

            #uniq_id
            ( $info->{uniq_id} ) = $info->{url} =~ /(\d+)$/ if $info->{url};

            # tags, don't forget manual tag, forexample: '新手专享';
            $e->find('i')->each(
                sub {
                    my $e = shift;
                    push @{ $info->{tags} }, clean_text( $e->all_text );
                }
            );

            push @{ $info->{tags} }, $tag;
        }
    );

    # status 'on/off'
    $info->{status} = 'off';    # status default value is: off
    my $status = $e->find('dl[class="operate quota"]')->first;
    if ($status) {
        my $button = $status->find('dt')->first;
        if ($button) {
            $button = clean_text( $button->all_text );
            $info->{status} = 'on' if $button =~ /立即购买/;
        }
        my $max_amount = $status->find('dd')->first;
        if ($max_amount) {
            $max_amount = clean_text( $max_amount->all_text ) || 0;
            $max_amount = 0 if $max_amount =~ /成功交易时间/;
            $max_amount =~ s/[^\d]//g;
            $info->{status} = $max_amount > 0 ? 'on' : 'off';
        }
    }

    # properties
    $e->find('div[class="info"] dl')->each(
        sub {
            my $e     = shift;
            my $label = $e->find('dd')->first;
            $label = clean_text( $label->all_text ) if $label;

            my $value = $e->find('dt')->first;
            $value = clean_text( $value->all_text ) if $value;

            push @{ $info->{properties} }, { label => $label, value => $value } if $label && $value;
        }
    );
    $info = fix_params($info);

    return $info;
}

sub fix_params {
    my $info = shift;
    @{ $info->{tags} } = uniq @{ $info->{tags} };

    foreach my $property ( @{ $info->{properties} } ) {
        my $label = $property->{label} // '';
        my $value = $property->{value} // '';

        if ( $label =~ /收益率/ ) {
            $info->{interest} = $1 if $value =~ /([\d\.]+)/;
        }

        if ( $label =~ /期限/ ) {
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

        $info->{pay_method} = '一次性还本付息';
        $info->{min_amount} = 0 unless $info->{min_amount};
    }

    $info->{progress} = 0;    # default set all to 0

    return $info;
}

sub get_next_page {
    my $e = shift;
    my $next_page;

    my $url;
    $e->find('div[class="page"] a')->each(
        sub {
            my ( $e, $i ) = @_;

            if ( $e->all_text =~ /下一页/ ) {
                my $url = $e->attr('href');
                $url = $e->attr('href') if $url;
                ($next_page) = $url =~ /(\d+)$/ if $url;
            }
        }
    );
    return $next_page;
}

1;

# vim:set ts=4 sw=4 et:
