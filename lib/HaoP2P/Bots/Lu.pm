package HaoP2P::Bots::Lu;
use utf8;
# ###############################
# Author: Mc Cheung
# Email:  mc.cheung@aol.com
# Date:   13 Sep 2016
# ###############################

use Moo;
use Types::Standard qw/Str Int/;
use Util;
use List::MoreUtils qw/uniq/;
use Data::Dumper;
use namespace::clean;

has site       => ( is => 'ro', isa => Str, default => 'https://list.lu.com' );
has debug      => ( is => 'ro', isa => Int, default => 0 );
has max_page   => ( is => 'rw', isa => Int, default => 99 );
has site_index => ( is => 'ro', isa => Str, default => 'lu_com' );
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
            push @{ $info->{tags} }, '活期';
            push @items, $info;    # unless $self->debug;
            $self->store($info);
        }
    );

    # P2P
    $url = $self->abs_url('/list/p2p');
    $self->ua->get($url)->res->dom->find('li.product-rows-item')->each(
        sub {
            my ($e) = @_;
            my $info = {};

            $e->find('a.product-title')->each(
                sub {
                    my ($e) = @_;
                    $info->{title} .= $e->all_text;
                    $info->{url}   .= $self->abs_url( $e->attr('href') );
                }
            );

            # tags
            $e->find('span[class^="ld-tag"]')->each(
                sub {
                    my ($e) = @_;
                    push @{ $info->{tags} }, merge_space chompf $e->all_text;
                }
            );

            $e->find('ul[class^="product-desc"] > li')->each(
                sub {
                    my ($e) = @_;
                    my ( $label, $value );
                    $e->find('span')->each(
                        sub {
                            my $e = shift;
                            $label .= merge_space chompf $e->all_text;
                        }
                    );

                    $e->find('p')->each(
                        sub {
                            my $e = shift;
                            $value .= merge_space chompf $e->all_text;
                        }
                    );

                    push @{ $info->{properties} }, { label => $label, value => $value } if $label && $value;
                }
            );

            $e->find('li.product-options product-status')->each(
                sub {
                    my $e = shift;
                    $e->find('a')->each(
                        sub {
                            $info->{status} = 'on';
                        }
                    );
                }
            );
            $info->{status} = 'off' unless $info->{ status };

            fix_params($info);
            push @{ $info->{tags} }, 'P2P';
            push @items, $info;    # unless $self->debug;
            $self->store($info);
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
                push @{ $info->{tags} }, '定期';
                push @items, $info;
                $self->store($info);
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
                undef $url;
            }
        }
        else {
            undef $url;
        }
    }
    return \@items;
}

sub fix_params {
    my $info = shift;
    $info->{uniq_id} = $1 if $info->{url} =~ /product\/(\d+)\//;
    $info->{uniq_id} = $1 if $info->{url} =~ /productId=(\d+)/;
    @{ $info->{tags} } = uniq @{ $info->{tags} };

    foreach my $property ( @{ $info->{properties} } ) {
        my $label = $property->{label} // '';
        my $value = $property->{value} // '';

        if ( $label =~ /收益|利率/ ) {
            $info->{interest} = $1 if $value =~ /([\d\.]+)/;
        }
        if ( $label =~ /期限/ ) {
            $info->{days} = $1 if $value =~ /(\d+)/;
            unless ( defined $info->{days} ) {
                $info->{days} = 0 if $value =~ /灵活/;
            }
        }

        if ( $label =~ /金额/ ) {
            $info->{min_amount} = $1 if $value =~ /([\d,\.]+)/;
            $info->{min_amount} =~ s/[,]//g;
            $info->{min_amount} = int( $info->{min_amount} );
        }

        $info->{pay_method} = $value if $label =~ /收益方式/;
    }
}

1;

# vim:set ts=4 sw=4 et:
