package HaoP2P::Bots::Eloancn;
use utf8;

# ###############################
# Author: Mc Cheung
# Email:  mc.cheung@aol.com
# Date:   2016-12-28
# ###############################

use Moo;
use Types::Standard qw/Str Int/;
use Util;
use List::MoreUtils qw/uniq/;
use Encode;
use Data::Dumper;
use feature qw/say/;

use namespace::clean;

has site       => ( is => 'ro', isa => Str, default => 'http://www.eloancn.com' );
has debug      => ( is => 'ro', isa => Int, default => 0 );   
has max_page   => ( is => 'rw', isa => Int, default => 99 );
has site_index => ( is => 'ro', isa => Str, default => 'eloancn_com' );
extends 'HaoP2P::Bots';

sub search {
    my $self = shift;
    my @items;
    my $current_items;

    # 翼农
    my $url = $self->abs_url('/new/loadAllWmpsRecords.action');
    
    my $current_page = 1;
    while ( $url && $current_page <= $self->max_page ) {
        my $new_url = $url . sprintf( '?page=%s', $current_page );
        full_logs("# GET $new_url") if $self->debug;
        
        $current_items = 0;
        $current_page++;

        my $tx = $self->ua->max_redirects(3)->get($new_url)->res->dom;
        
        my $wraps = $tx->find('div[class="wrap"]');
        my $item;
        foreach my $wrap (@$wraps) {
            unless ($item) {
                $item = $wrap->to_string if $wrap;
                next;
            }

            $item .= $wrap->to_string;

            my $e = Mojo::DOM->new($item);

            # find content
            my $info = {};

            # title
            my $title = $e->find('div[class="mainline"] span')->slice( 1, 2 )->map( sub { $_->all_text if defined $_ && $_ } )->join(' ')->encode->to_string;
            $title = clean_text($title) if $title;
            $info->{title} = $title if $title;

            # tags, don't forget manual tag, forexample: '新手专享';
            $e->find('div[class="border_xc"] span')->each(
                sub {
                    my $e = shift;
                    push @{ $info->{tags} }, clean_text( $e->all_text ) if $e;
                }
            );

            my $status = $e->find('div[class="dw0 qt1"] div a')->first;
            if ($status) {
                
                 $info->{status} = clean_text( $status->all_text );
                # status 'on/off'
                $info->{status} = $info->{status} eq '投资' ? 'on' : 'off';
            }
            
            # uniq_id
            my $uniq_id = $e->find( 'div[class="zqlist"]')->first;
            $uniq_id = $uniq_id->attr( 'onclick' ) if $uniq_id;
            ( $info->{uniq_id} ) = $uniq_id =~ /\((\d+)\)/ if $uniq_id;

            # url
            $info->{url} = $url;

            # pay_method
            my $pay_method = $e->find('div[class="ycbitem-textM"] p')->first;
            $info->{pay_method} = clean_text( $pay_method->all_text ) if $pay_method;

            # properties
            $e->find('div[class^="con_con"] div')->each(
                sub {
                    my $e     = shift;
                    my $label = $e->find('p')->first;
                    $label = clean_text( $label->all_text ) if $label;
                    my $value = $e->find('p')->last;
                    $value = clean_text( $value->all_text ) if $value;

                    push @{ $info->{properties} }, { label => $label, value => $value } if $label && $value;
                }
            );

            $info = fix_params($info);

            push @items, $info;    # unless $self->debug;
            $self->store($info) unless $self->debug;
            undef $item;
            $current_items++;
        }

        $url = undef unless $current_items;
    }

    return \@items;
}

sub fix_params {
    my $info = shift;
    @{ $info->{tags} } = uniq @{ $info->{tags} };


    foreach my $property ( @{ $info->{properties} } ) {
        my $label = $property->{label} // '';
        my $value = $property->{value} // '';

        if ( $label =~ /预期年货收益/ ) {
            $value = clean_text( $value );
            $value =~ s/%//g;

            print "Value: $value\n";
            $info->{interest} = eval $value;
            ($info->{interest}) = $value =~ /([\d\.]+)/ unless $info->{interest};
        }

        if ( $label =~ /锁定期限/ ) {
            $info->{days} = $1 if $value =~ /(\d+)/;
            $info->{days} = 0 unless $info->{days};
        }

        # progress
        if ( $label =~ /已募集/ ) {
            my ( $now, $total ) = split /\//, $value, 2;
            $now //= 0;
            $total //= 0;
            $info->{progress} = $now / $total * 100;
        }
    }

    foreach my $tag ( @{$info->{tags}}) {
        next unless $tag =~ /整数倍投资/;
        ($info->{min_amount}) = $tag =~ /(\d+)/;
    }
    # min_amount
    $info->{min_amount} //= 0;
    $info->{status} = $info->{progress} < 100 ? 'on' : 'off';
    
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
