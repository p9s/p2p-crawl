package HaoP2P::Bots::fix_me;
use utf8;

# ###############################
# Author: Mc Cheung
# Email:  mc.cheung@aol.com
# Date:   fix_me
# ###############################

use Moo;
use Types::Standard qw/Str Int/;
use Util;
use List::MoreUtils qw/uniq/;
use Encode;
use Data::Dumper;
use feature qw/say/;

use namespace::clean;

has site       => ( is => 'ro', isa => Str, default => 'fix_me' ); # https://www.hfax.com
has debug      => ( is => 'ro', isa => Int, default => 1 );  # fix_me_last
has max_page   => ( is => 'rw', isa => Int, default => 99 );
has site_index => ( is => 'ro', isa => Str, default => 'fix_me' ); # hfax_com
extends 'HaoP2P::Bots';

sub search {
    my $self = shift;
    my @items;

    # 新手专区
    my $url = $self->abs_url('fix_me' ); #/toFinanceList.do?m=5

    my $max_page = $self->max_page;
    while ( $url && $max_page ) {
        $max_page--;
        full_logs("# GET $url") if $self->debug;
        my $tx = $self->ua->max_redirects(3)->get($url)->res->dom;
        $tx->find('div[class~="listBox-Info"]')->each(
            sub {
                my ( $e, $i ) = @_;

                # find process next page
                full_logs("The $i items") if $self->debug;
              
                # find content
                my $info = {};

                # title
                # tags, don't forget manual tag, forexample: '新手专享';
                # interest
                # days
                # pay_method
                # min_amount
                # progress

                # status 'on/off'

                # url
                # uniq_id


                # $value = chompf($value);
                # $value = merge_space($value);
                # properties

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

    foreach my $property ( @{ $info->{properties} } ) {
        my $label = $property->{label} // '';
        my $value = $property->{value} // '';

        if ( $label =~ /预期年化利率/ ) {
            $info->{interest} = $1 if $value =~ /([\d\.]+)/;
        }

        if ( $label =~ /投资期限/ ) {
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
        $info->{min_amount} = 0 unless $info->{min_amount};
    }
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
