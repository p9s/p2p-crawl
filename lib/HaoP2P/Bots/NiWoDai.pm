package HaoP2P::Bots::NiWoDai;
use utf8;

# ###############################
# Author: Mc Cheung
# Email:  mc.cheung@aol.com
# Date:   2016-12-10
# ###############################

use Moo;
use Types::Standard qw/Str Int/;
use Util;
use List::MoreUtils qw/uniq/;
use Encode;
use Data::Dumper;
use feature qw/say/;

use namespace::clean;

has site       => ( is => 'ro', isa => Str, default => 'https://member.niwodai.com' );
has debug      => ( is => 'ro', isa => Int, default => 0 );
has max_page   => ( is => 'rw', isa => Int, default => 99 );
has site_index => ( is => 'ro', isa => Str, default => 'niwodai_com' );
extends 'HaoP2P::Bots';

sub search {
    my $self = shift;
    my @items;

    # 新手专区
    my $url      = $self->abs_url('/baiduFina/newPeople.do');
    my $max_page = $self->max_page;
    while ( $url && $max_page && not $self->debug ) {
        $max_page--;
        full_logs("# GET $url") if $self->debug;
        my $tx = $self->ua->get($url)->res->dom;
        $tx->find('div[class="clearfix module jiacai"]')->each(
            sub {
                my ( $e, $i ) = @_;
                full_logs("The $i items") if $self->debug;

                # find content
                my $info = {};

                # title
                $e->find('h3 a')->each(
                    sub {
                        my ( $e, $i ) = @_;
                        $info->{title} = $e->all_text if $e;
                    }
                );

                # tags, don't forget manual tag, forexample: '新手专享';
                $e->find('h3 span')->each(
                    sub {
                        my ( $e, $i ) = @_;
                        push @{ $info->{tags} }, $e->all_text;
                    }
                );
                $e->find('h3 em')->each(
                    sub {
                        my ( $e, $i ) = @_;
                        push @{ $info->{tags} }, $e->all_text;
                    }
                );
                push @{ $info->{tags} }, '新手专享';

                # properties
                $e->find('ul[class="clearfix bot_con"] li')->each(
                    sub {
                        my ( $e, $i ) = @_;

                        my $label = $e->find('span[class="fc_6"]')->first;
                        $label = $label->all_text if $label;
                        $label = chompf( merge_space($label) ) if $label;

                        $e->at('span[class="fc_6"]')->remove;
                        my $value = $e->all_text;
                        $value = chompf( merge_space($value) ) if $value;

                        push @{ $info->{properties} }, { label => $label, value => $value } if $label && $value;
                    }
                );

                # status 'on/off'
                my $url = $e->attr('onclick');
                if ($url) {
                    ($url) = $url =~ /'(http.*?)'/;
                    if ($url) {
                        $info->{status} = 'on';

                        # url
                        $info->{url} = $url;

                        # uniq_id
                        ( $info->{uniq_id} ) = $url =~ /fp_id=([^&]+)/;
                        unless ( $info->{uniq_id} ) {
                            ( $info->{uniq_id} ) = $url =~ /proId=(\d+)/;
                        }
                    }
                }

                $info = fix_params($info);
                push @items, $info;    # unless $self->debug;
                $self->store($info) unless $self->debug;
            }
        );

        # findout next page
        my $next_url = get_next_page($tx);
        $url = $next_url ? $self->abs_url($next_url) : undef;
    }

    #嘉财有道
    $url      = $self->abs_url('/financial/financialDetail.do');
    $max_page = $self->max_page;
    while ( $url && $max_page ) {
        $max_page--;
        full_logs("# GET $url") if $self->debug;

        my $tx = $self->ua->get($url)->res->dom;
        $tx->find('div[class="mb_10 jiacai_out"]')->each(
            sub {
                my ( $e, $i ) = @_;
                full_logs("The $i items") if $self->debug;

                # find content
                my $info = {};

                # title
                $e->find('h3 a')->each(
                    sub {
                        my ( $e, $i ) = @_;
                        $info->{title} = $e->all_text if $e;
                    }
                );

                # tags, don't forget manual tag, forexample: '新手专享';
                $e->find('h3 span')->each(
                    sub {
                        my ( $e, $i ) = @_;
                        push @{ $info->{tags} }, chompf( merge_space( $e->all_text ) );
                    }
                );
                $e->find('h3 em')->each(
                    sub {
                        my ( $e, $i ) = @_;
                        push @{ $info->{tags} }, $e->all_text;
                    }
                );
                push @{ $info->{tags} }, '新手专享';

                # properties
                $e->find('ul[class="clearfix bot_con"] li')->each(
                    sub {
                        my ( $e, $i ) = @_;

                        my $label = $e->find('span[class="fc_6"]')->first;
                        $label = $label->all_text if $label;
                        $label = chompf( merge_space($label) ) if $label;

                        $e->at('span[class="fc_6"]')->remove;
                        my $value = $e->all_text;
                        $value = chompf( merge_space($value) ) if $value;

                        push @{ $info->{properties} }, { label => $label, value => $value } if $label && $value;
                    }
                );

                # progress
                $e->find( 'span[class~="b_jingdu"]')->each( sub {
                    my ( $e, $i ) = @_;
                    $info->{progress} = chompf( merge_space( $e->all_text ));
                });

                # status 'on/off'
                my $button = $e->find('a[class="btn btnSize_1 btn_orange"]')->first;
                if ($button) {
                    $info->{status} = $button->all_text =~ /立即加入/ ? 'on' : 'off';
                    my $url = $button->attr('href');
                    if ($url) {

                        # url
                        $info->{url} = $url;

                        # uniq_id
                        ( $info->{uniq_id} ) = $url =~ /fp_id=([^&]+)/;
                        unless ( $info->{uniq_id} ) {
                            ( $info->{uniq_id} ) = $url =~ /proId=(\d+)/;
                        }
                    }
                }

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

        if ( $label =~ /收益/ ) {
            $value =~ s/[\s%]//g;
            $info->{interest} = $value;
        }

        if ( $label =~ /投资期限/ ) {
            $info->{days} = $1 if $value =~ /(\d+)/;
            $info->{days} = 0 unless $info->{days};
            $info->{days} *= 30 if $value =~ /月/;
        }

        $info->{min_amount} = 0 unless $info->{min_amount};
        $info->{pay_method} = 'T+2';
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
