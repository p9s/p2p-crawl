package HaoP2P::Bots::HfaxCom;
use utf8;

# ###############################
# Author: Mc Cheung
# Email:  mc.cheung@aol.com
# Date:   27 Oct 2016
# ###############################

use Moo;
use Types::Standard qw/Str Int/;
use Util;
use List::MoreUtils qw/uniq/;
use Encode;
use Data::Dumper;
use feature qw/say/;

use namespace::clean;

has site       => ( is => 'ro', isa => Str, default => 'https://www.hfax.com' );
has debug      => ( is => 'ro', isa => Int, default => 1 );
has max_page   => ( is => 'rw', isa => Int, default => 99 );
has site_index => ( is => 'ro', isa => Str, default => 'hfax_com' );
extends 'HaoP2P::Bots';

sub search {
    my $self = shift;
    my @items;

    # 新手专区
    my $url = $self->abs_url('/toFinanceList.do?m=5');
    full_logs("# GET $url") if $self->debug;

    while ($url) {
        full_logs("# GET $url") if $self->debug;
        my $tx = $self->ua->get($url)->res->dom;
        $tx->find('div[class~="listBox-Info"]')->each(
            sub {
                my ( $e, $i ) = @_;

                # find process next page
                my $next_page = $e->find('div[class="pageDivClass"] > a')->grep(
                    sub {
                        $_->all_text =~ /下一页/;
                    }
                );
                if ( $next_page && $next_page->size > 0 ) {
                    $url = $self->abs_url( $next_page->first->attr('href') );
                    full_logs("Next page: $url") if $self->debug;
                }

                full_logs("The $i items");
                my $info = {};

                $e->find('div[class="listBox-Info-left"]')->each(
                    sub {
                        my ( $e, $i ) = @_;

                        # title
                        $info->{title} = $e->find('a[class="listBox-title"]')->first->all_text;

                        # tags
                        $e->find('span=["class="cuxiao"]')->each(
                            sub {
                                my ( $e, $i ) = @_;
                                @{ $info->{tags} }, $e->all_text;
                            }
                        );
                    }
                );

                $e->find('div[class="listBox-benefit-sider clearfix"]')->each(
                    sub {
                        my ( $e, $i ) = @_;
                        $e->find('li')->each(
                            sub {
                                my ( $e, $i ) = @_;

                                my $ps    = $e->find('p')->to_array;
                                my $label = shift @$ps;
                                $label = $label->all_text if $label;
                                my $value = shift @$ps;
                                $value = $value->all_text if $value;

                                $value = chompf($value)      if $value;
                                $value = merge_space($value) if $value;

                                push @{ $info->{properties} }, { label => $label, value => $value };
                            }
                        );
                    }
                );

                # progress
                $e->find('div[class="jindu-bar-box clearfix"] > span')->each(
                    sub {
                        my ( $e, $i ) = @_;
                        $info->{progress} = $e->all_text;
                    }
                );

                # total amount
                $e->find('p[class="total-mon listAmount"]')->each(
                    sub {
                        my ( $e, $i ) = @_;
                        my $t = $e->all_text;
                        chomp($t);
                        my ( $k, $v ) = split /\s+/, $t, 2;
                        push @{ $info->{properties} }, { label => $k, value => $v };
                    }
                );

                # status
                my $btn = $e->find('div[class="touzi-box-right"] > a')->first;
                if ($btn) {
                    $info->{status} = $btn->attr('class') eq 'already-btn' ? 'off' : 'on';
                }

                # url
                $e->find('a[class="listBox-title"]')->each(
                    sub {
                        my ( $e, $i ) = @_;
                        $info->{url} = $self->abs_url( $e->attr('href') );
                        ( $info->{uniq_id} ) = $e->attr('href') =~ /id=([^=&]+)/;
                    }
                );

                fix_params($info);
                push @{ $info->{tags} }, '新手专享';
                push @items, $info;    # unless $self->debug;

                $self->store($info) unless $self->debug;

           }
        );
        # findout next page
        my $next_url = get_next_page( $tx );
        $url = $next_url ? $self->abs_url( $next_url ) : undef;
    }



    # 惠理财
    $url = $self->abs_url( 'toFinanceList.do?m=7');
    while ( $url ) {
        $tx = $self->get( $url )->res->dom;
        $tx-find( 'div[class="listBox-Info clearfix"]')->each( 
            sub {
                my ( $e, $i ) = @_;
                my $info = {};
                # title 
                $e->find( 'a[class="listBox-title"]')->each( 
                    sub {
                        my ( $e, $i ) = @_;
                        $info->{ title } = $e->all_text;
                        $info->{ url } = $self->abs_url( $e->attr( 'href' ) );
                    }
                );

                # tags 
                $e->find( 'div[class="listBox-wrap clearfix"]')->first->find( 'span')->each( 
                    sub {
                        my ( $e, $i ) = @_;
                        push @{ $info->{ tags }}, $e->all_text;
                    }
                );

                # properties
                $e->find( 'div[class="listBox-benefit-sider clearfix"] > ul > li')->each( 
                    sub {
                        my ( $e, $i ) = @_;

                        push @{ $info->{ properties } }, {
                            label => $e->find( 'p:first-child')->all_text,
                            value => $e->find( 'p:last-child')->all_text,
                        };
                    }
                );
                $e->find( 'p[class="total-mon listAmount"]')->each( 
                    sub {
                        my ( $e, $i ) = @_;
                        
                        my $txt = $e->all_text;
                        my ( $label, $value ) = split /\s+/, $txt, 2; 
                        
                        push @{ $info->{ properties }}, { label => $label, value => $value };
                    }
                );

                # progress 
                $info->{ progress } = $e->find( 'div[class="jindu-bar-box clearfix"] > span:first-child' )->all_text;

                # status
                $e->find( 'div.touzi-box-right > a')->each( 
                    sub {
                        my $e = shift;
                        $info->{ status } = $e->attr( 'class' ) eq 'already-btn' ? 'off' : 'on';
                    }
                );

                fix_params($info);
                push @{ $info->{tags} }, '惠理财';
                push @items, $info;    # unless $self->debug;
            }
        );
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
}

sub get_next_page {
    my $e = shift;

    my $url;
    $e->find( 'div[class="pageDivClass"]')->each( 
        sub {
            my ( $e, $i ) = @_;
            $e->find( 'a')->each( 
                sub {
                    my ( $e, $i ) = @_;
                    $url = $e->attr( 'href') if $e->all_text =~ /下一页/;
                }
            );
        }
    );
    return $url;
}

1;

# vim:set ts=4 sw=4 et:
