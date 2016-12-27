package HaoP2P::Bots::TuanDai;
use utf8;

# ###############################
# Author: Mc Cheung
# Email:  mc.cheung@aol.com
# Date:   2016-12-27 
# ###############################

use Moo;
use Types::Standard qw/Str Int/;
use Util;
use List::MoreUtils qw/uniq/;
use Encode;
use Data::Dumper;
use feature qw/say/;

use namespace::clean;

has site       => ( is => 'ro', isa => Str, default => 'https://www.tuandai.com/');
has debug      => ( is => 'ro', isa => Int, default => 1 );  # fix_me_last
has max_page   => ( is => 'rw', isa => Int, default => 99 );
has site_index => ( is => 'ro', isa => Str, default => 'tuandai_com' );
extends 'HaoP2P::Bots';

sub search {
    my $self = shift;
    my @items;

    # 智能理财
    my $url = $self->abs_url('/pages/weplan/welist.aspx' ); 

    my $max_page = $self->max_page;
    while ( $url && $max_page ) {
        $max_page--;
        full_logs("# GET $url") if $self->debug;
        my $tx = $self->ua->max_redirects(3)->get($url)->res->dom;
        $tx->find('div[class~="invent_list"] ul li')->each(
            sub {
                my ( $e, $i ) = @_;
                # find process next page
                full_logs("The $i items") if $self->debug;
              
                # find content
                my $info = {};
                # title
                my $title = $e->find( 'p[class~="title"] a')->first;
                $info->{title} = $title->all_text if $title;

                # url
                $info->{url} = $self->abs_url( $title->attr( 'href') ) if $title;
                # uniq_id
                ($info->{uniq_id}) = $info->{url} =~ /id=([^&]+)/ if $info->{url};


                # tags, don't forget manual tag, forexample: '新手专享';
                $e->find( 'p[class="title"] span')->each( sub {
                    my $e = shift;
                    push @{$info->{tags}}, $e->all_text if $e;
                });
                push @{$info->{tags}}, '智能理财';

                # interest
                my $interest = $e->find( 'span[class~="f40 g-orange2"]')->first; 
                $info->{interest} = $interest->all_text if $interest;
                # days
                my $days = $e->find( 'div[class="mb10  mb15"] span')->to_array;
                if ( $days ) {
                    my $day = shift @$days;
                    $info->{days} = $day->all_text if $day;
                    $info->{days} = 0 unless $info->{days};

                    my $unit = shift @$days;
                    $unit = $unit->all_text if $unit;
                    $info->{days} *= 30 if $unit && $unit =~ /月/;
                    $info->{days} *= 30 * 12 if $unit && $unit =~ /年/;
                    
                    my $pay_method = shift @$days;
                    $info->{pay_method} = $pay_method->all_text if $pay_method;
                    # pay_method
                    $info->{pay_method} =~ s/\///g if $info->{pay_method};
                }

                # min_amount
                my $min_amount = $e->find( 'span[class="g9 ml5  f12 "]')->first; 
                $info->{min_amount} = $min_amount->all_text if $min_amount;
                ($info->{min_amount}) = $info->{min_amount} =~ /\d+/ if $info->{min_amount};
                
                # progress

                # status 'on/off'
                my $status = $e->find( 'a[id="btnSubscribe"]')->first;
                $info->{status} = $status && $status->all_text =~ /马上加入/ ? 'on' : 'off'; 

                $info->{progress} = $info->{status} eq 'on' ? 0 : 100;

                $info = fix_params($info);
                push @items, $info;    # unless $self->debug;
                $self->store($info) unless $self->debug;
            }
        );

        # findout next page
        my $next_url = get_next_page($tx);
        $url = $next_url ? $self->abs_url($next_url) : undef;
    }

    return \@items;
}

sub fix_params {
    my $info = shift;
    @{ $info->{tags} } = uniq @{ $info->{tags} };

    # properties
    push @{$info->{properties}}, { label => '还款方式', value => $info->{pay_method}} if $info->{pay_method};
    push @{$info->{properties}}, { label => '投资期限', value => $info->{days}} if $info->{days};
    push @{$info->{properties}}, { label => '预期年化利率', value => $info->{interest}} if $info->{interest};
    push @{$info->{properties}}, { label => '起投金额', value => $info->{min_amount}} if $info->{min_amount};
    return $info;
}

sub get_next_page {
    my $e = shift;

    my $url;
    $e->find('div[class="pageDivClass"]')->each(
        sub {
            my ( $e, $i ) = @_;
            $e->find('a')->each(
                sub {
                    my ( $e, $i ) = @_;
                    $url = $e->attr('href') if $e->all_text =~ /下一页/;
                }
            );
        }
    );
    return $url;
}

1;

# vim:set ts=4 sw=4 et:
