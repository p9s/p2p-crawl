package HaoP2P::Bots::My089;
use utf8;

# ###############################
# Author: Mc Cheung
# Email:  mc.cheung@aol.com
# Date:   2016-12-13
# ###############################

use Moo;
use Types::Standard qw/Str Int/;
use Util;
use List::MoreUtils qw/uniq/;
use Encode;
use Data::Dumper;
use feature qw/say/;

use namespace::clean;

has site       => ( is => 'ro', isa => Str, default => 'http://investment.my089.com/' );
has debug      => ( is => 'ro', isa => Int, default => 0 );                                # fix_me_last
has max_page   => ( is => 'rw', isa => Int, default => 99 );
has site_index => ( is => 'ro', isa => Str, default => 'my089_com' );                      # hfax_com
extends 'HaoP2P::Bots';

sub search {
    my $self = shift;
    my @items;

    my $url = $self->abs_url('/credit/index');                                             #/toFinanceList.do?m=5
    full_logs("# GET $url") if $self->debug;

    my $max_page = $self->max_page;
    full_logs("## Max page: $max_page\n");

    my $params = { totalPage => '', currentPage => '', funding_ => '', lifeOfLoan_ => '', loanType_ => 90, oc_ => 5, ou_ => -1, };
    my $headers = { 'Accept' => 'application/json, text/javascript, */*; q=0.01', 'Accept-Encoding' => 'gzip, deflate', 'Accept-Language' => 'en-US,en;q=0.8,zh-CN;q=0.6,zh;q=0.4', 'Cache-Control' => 'no-cache', 'Connection' => 'keep-alive', 'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8', 'Host' => 'investment.my089.com', 'Origin' => 'http' => '//investment.my089.com', 'Pragma' => 'no-cache', 'Referer' => 'http' => '//investment.my089.com/credit', 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36', 'X-Requested-With' => 'XMLHttpRequest', };
    while ($max_page) {
        $max_page--;

        full_logs("# GET $url") if $self->debug;

        my $tx = $self->ua->post( $url => $headers => form => $params )->res->json;
        $max_page = 0 if $tx->{page}->{totalPage} == $tx->{page}->{currentPage};
        $params = $tx->{page};
        $params->{currentPage}++;

        foreach my $item ( @{ $tx->{list} } ) {
            # find process next page
            # find content
            full_logs("### Item: $item->{subjectID}") if $self->debug;
            my $info = {};

            # title
            $info->{title} = $item->{title};

            # tags
            push @{ $info->{tags} }, $item->{subjectDescription};

            # progress
            $info->{progress} = $item->{progress} || 0;

            # status all result is active
            $info->{status} = $item->{progress} < 100 ? 'on' : 'off';

            # url
            $info->{url} = '/credit/forBidding?sid=' . $item->{subjectID};
            $info->{url} = $self->abs_url( $info->{url} );

            # uniq_id
            $info->{uniq_id} = $item->{subjectID};

            # min_amount
            $info->{min_amount} = $item->{minBid};

            # properties
            my @properties = split /<br\/>/, $item->{descriptionFilter};
            foreach my $p (@properties) {
                $p =~ s/['"]//g;
                my ( $label, $value ) = split /:/, $p;
                $label = merge_space( chompf($label) ) if $label;
                $value = merge_space( chompf($value) ) if $value;
                push @{ $info->{properties} }, { label => $label, value => $value } if $label && $value;
            }

            # properties
            my $detail = $self->ua->get( $info->{url} )->res->dom;
            $detail->find('div[class="biao_info"] ul li')->each(
                sub {
                    my $e     = $_[0];
                    my $label = $e->find('span')->first;
                    my $value = $e->find('span')->last;

                    $label = merge_space( chompf( $label->all_text ) ) if $label;
                    $value = merge_space( chompf( $value->all_text ) ) if $value;
                    push @{ $info->{properties} }, { label => $label, value => $value } if $label && $value;
                }
            );

            push @{ $info->{properties} }, { label => '已投标',    value => $item->{bidCount}        || 0 };
            push @{ $info->{properties} }, { label => '还需',       value => $item->{remainderAmount} || 0 };
            push @{ $info->{properties} }, { label => '剩余时间', value => $item->{remainTime}      || 0 };

            #$info = fix_params($info);
            push @items, $info;    # unless $self->debug;
            $self->store($info) unless $self->debug;
        }
    }
    return \@items;

}

sub fix_params {
    my $info = shift;
    @{ $info->{tags} } = uniq @{ $info->{tags} };

    foreach my $property ( @{ $info->{properties} } ) {
        my $label = $property->{label} // '';
        my $value = $property->{value} // '';

        if ( $label =~ /利率/ ) {
            $info->{interest} = $1 if $value =~ /([\d\.]+)/;
        }

        if ( $label =~ /期限/ ) {
            $info->{days} = $1 if $value =~ /(\d+)/;
            $info->{days} = 0 unless $info->{days};
            $info->{days} *= 30 if $label =~ /月/;
        }

        if ( $label =~ /金额/ ) {
            $info->{min_amount} = $1 if $value =~ /([\d,\.]+)/;
            $info->{min_amount} =~ s/[,]//g;

            $info->{min_amount} = int( $info->{min_amount} );
        }

        $info->{pay_method} = $value if $label =~ /还款方式/;

        if ( $label =~ /可投范围/ ) {
            $info->{min_amount} = ( $value =~ /([\d,\.]+)/ )[0];
        }
    }
    return $info;
}

1;
