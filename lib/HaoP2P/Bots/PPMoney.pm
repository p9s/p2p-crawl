package HaoP2P::Bots::PPMoney;
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

has site       => ( is => 'ro', isa => Str, default => 'https://www.ppmoney.com/' );
has debug      => ( is => 'ro', isa => Int, default => 0 );
has max_page   => ( is => 'rw', isa => Int, default => 99 );
has site_index => ( is => 'ro', isa => Str, default => 'ppmoney_com' );
extends 'HaoP2P::Bots';

my %icons = ( 4 => '手动', 19 => '减满券', 20 => '加息券', 6 => 'APP', 1 => '新手');

sub search {
    my $self = shift;
    my @items;

    my @urls = ( { url => '/creditassign/newlist/-1/1', tag => '变现' }, { url => '/project/PrjListJson/-1/1/GongYingLianJinRong/true/true', tag => '三农金融' }, { url => '/project/PrjListJson/-1/1/FangChanDiYa/true/true', tag => '房产抵压' }, { url => '/project/PrjListJson/-1/1/QiCheJinRong/true/true', tag => '汽车金融' }, { url => '/StepUp/List/-1/1/StepUp/true/true', tag => '月月增' }, { url => '/StepUp/List/-1/1/FixedTerm/true/true', tag => '省心宝' }, );

    foreach my $h_url (@urls) {

        # 新手专区
        my $url = $self->abs_url( $h_url->{url} );

        my $max_page  = $self->max_page;
        my $next_page = 1;
        while ( $url && $max_page ) {
            $max_page--;
            full_logs("# GET $url") if $self->debug;
            my $json = $self->ua->max_redirects(3)->get($url)->res->json;
            undef $url unless $json;
            $json = $json->{PackageList};

            foreach my $item ( @{ $json->{Data} } ) {
                next unless $item;
                # find process next page

                # find content
                my $info = {};
                $info->{uniq_id} = $item->{prjId};
                $info->{url}     = $self->abs_url( $item->{link} );
                $info->{title}   = $item->{name};

                # tags, don't forget manual tag, forexample: '新手专享';
                push @{ $info->{tags} }, $item->{type};
                map { push @{$info->{tags}}, $icons{$_} if exists $icons{$_} } @{ $item->{icons} };

                # interest
                $info->{interest} = $item->{maxProfit} if $item->{maxProfit };
                $info->{interest} = $item->{profit} if $info->{interest} < $item->{profit};

                # days
                if ( $item->{progress} == 100 ) {
                    $info->{days} = 0;
                }
                else {
                    $info->{days} = $item->{isDayPrj} ? $item->{timeLimit} : $item->{timeLimit} * 30;
                }

                # pay_method
                $info->{pay_method} = sprintf( '%s天锁定期后可退出', $item->{lockTimeLimit}) 
                    if  $item->{lockTimeLimit} ;
                # min_amount
                $info->{min_amount} = 1000;

                # progress
                $info->{progress} = $item->{progress};
                # status 'on/off'
                $info->{status} = $item->{status} == 1 ? 'on' : 'off';

                # properties
                push @{$info->{properties}}, { label => '开始时间', value  => $item->{beginTime} };
                push @{$info->{properties}}, { label => '结束时间', value => $item->{endTime} };
                push @{$info->{properties}}, { label => '预期年化收益', vlaue => $info->{interest}};
                my $monetary = sprintf( '%s %s', $item->{monetary} || 0, '元' );
                push @{$info->{properties}}, { label => '融资金额', value => $monetary };
                push @{$info->{properties}}, { label => '锁定期', value => $item->{lockTimeLimit} . ' 天' } if $item->{lockTimeLimit};
                push @{$info->{properties}}, { label => '理财期限', value => $info->{ days} . ' 天' } if $info->{days};

                push @items, $info;    # unless $self->debug;
                $self->store($info) unless $self->debug;
            }

            # process next page
            if ( $json && $json->{Data} && scalar @{ $json->{Data} } > 0 ) {
                ++$next_page;
                $url = sprintf( '%s/%s', $self->abs_url( $h_url->{url} ), $next_page );
            } else {
                undef $url;
            }
        }

    }
    return \@items;
}


1;

# vim:set ts=4 sw=4 et:
