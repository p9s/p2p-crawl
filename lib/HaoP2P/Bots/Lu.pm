package HaoP2P::Bots::Lu;

# Author: Mc Cheung
# Email:  mc.cheung@aol.com
# Date:   13 Sep 2016

use Moo;
use Types::Standard qw/Str Int/;
use URI;
use Util;
use Data::Dumper;
use namespace::clean;

has site     => ( is => 'ro', isa => Str, default => 'https://list.lu.com' );
has debug    => ( is => 'ro', isa => Int, default => 0 );
has max_page => ( is => 'rw', isa => Int, default => 99 );

extends 'HaoP2P::Bots';

sub search {
    my $self = shift;
    my @items;

    # 活期
    my $url = $self->abs_url('/list/huoqi');
    full_logs("# GET $url") if $self->debug;
    $self->ua->get($url)->res->dom->find('div.product')->each(
        sub {
            my ( $e, $i ) = @_;
            my $info = {};
            $e->find('div.title > a')->each(
                sub {
                    my ( $e, $i ) = @_;
                    $info->{title} .= $e->all_text;
                    $info->{url}   .= $self->abs_url( $e->attr('href') );
                }
            );

            $e->find('div.title > span')->each(
                sub {
                    my ( $e, $i ) = @_;
                    push @{ $info->{tags} }, $e->all_text;
                }
            );

            $e->find('ul.detail >li')->each(
                sub {
                    my ( $e, $i ) = @_;
                    my $label = $e->find('div.label')->first->all_text;
                    my $value = $e->find('div[class*="value"]')->first->all_text;
                    push @{ $info->{properties} },
                        {
                        label => $label,
                        value => $value,
                        };
                }
            );

            $e->find('a[class*="btn"]')->each(
                sub {
                    my ( $e, $i ) = @_;
                    $info->{status} = $e->attr('class') =~ /disabled/ ? 'off' : 'on';
                }
            );

            fix_params($info);

            push @items, $info unless $self->debug;
            full_logs( Dumper $info ) if $self->debug;
        }
    );

    # 定期
    $url = $self->abs_url('/list/dingqi');
    my $current_page = 1;
    while ( $url && $self->max_page ) {
        full_logs("# Get $url") if $self->debug;

        my $tx = $self->ua->get($url);
        $tx->res->dom->find('li[class~="product-list"]')->each(
            sub {
                my ( $e, $i ) = @_;
                full_logs("## Process on item: $i") if $self->debug;

                my $info = {};
                $e->find('dt.product-name')->each(
                    sub {
                        my ( $e, $i ) = @_;
                        $e->find('a')->each(
                            sub {
                                my ( $e, $i ) = @_;
                                $info->{title} .= $e->all_text;
                                $info->{url}   .= $self->abs_url( $e->attr('href') );
                            }
                        );

                        $e->find('span')->each(
                            sub {
                                my ( $e, $i ) = @_;
                                push @{ $info->{tags} }, $e->all_text;
                            }
                        );
                    }
                );

                # properties
                $e->find('ul.clearfix > li')->each(
                    sub {
                        my ( $e, $i ) = @_;
                        my $label;
                        my $value;
                        $e->find('span')->each(
                            sub {
                                my ( $e, $i ) = @_;
                                $label .= chompf $e->all_text;
                            }
                        );

                        $e->find('p')->each(
                            sub {
                                my ( $e, $i ) = @_;
                                $value .= chompf $e->all_text;
                            }
                        );

                        push @{ $info->{properties} },
                            {
                            label => $label,
                            value => $value,
                            };
                    }
                );

                $e->find('div.product-amount')->each(
                    sub {
                        my ( $e, $i ) = @_;
                        my ( $label, $value );
                        $e->find('span.product-property-name')->each(
                            sub {
                                my $e = shift;
                                $label .= chompf $e->all_text;
                            }
                        );

                        $e->find('p')->each(
                            sub {
                                my $e = shift;
                                $value .= merge_space chompf $e->all_text;
                            }
                        );

                        push @{ $info->{properties} }, { label => $label, value => $value };
                    }
                );

                $e->find('a[class*="btn"]')->each(
                    sub {
                        my $e = shift;
                        $info->{status} = $e->attr('class') =~ /disabled/ ? 'off' : 'on';
                        $info->{url} = $self->abs_url( $e->attr('href') );
                    }
                );

                $e->find('span.progress-txt')->each(
                    sub {
                        my $e = shift;
                        $info->{progress} .= chompf $e->all_text;
                    }
                );

                fix_params($info);

                push @items, $info;

            }
        );
        my $page_count = $tx->res->dom->find('input[id="pageCount"]')->first;
        if ($page_count) {
            $page_count = $page_count->attr('value');
            $page_count++;
            $current_page++;
            if ( $current_page <= $page_count ) {
                $url = $self->abs_url('/list/dingqi') . '?currentPage=' . $current_page;
                $self->max_page( $self->max_page - 1 );
            }
            else {
                $url = undef;
            }
        }
        else {
            $url = undef;
        }

    }
    return \@items;
}

sub fix_params {
    my $info = shift;
    $info->{uniq_id} = $1 if $info->{url} =~ /product\/(\d+)\//;
    $info->{uniq_id} = $1 if $info->{url} =~ /productId=(\d+)/;
}

1;

# vim:set ts=4 sw=4 et:
