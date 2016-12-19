package HaoP2P::Bots::WeiDai;
use utf8;

# ###############################
# Author: Mc Cheung
# Email:  mc.cheung@aol.com
# Date:   2016-12-16
# ###############################

use Moo;
use Types::Standard qw/Str Int/;
use Util;
use List::MoreUtils qw/uniq/;
use Encode;
use Data::Dumper;
use feature qw/say/;

use namespace::clean;

has site       => ( is => 'ro', isa => Str, default => 'https://www.weidai.com.cn/' );
has debug      => ( is => 'ro', isa => Int, default => 1 );                              # fix_me_last
has max_page   => ( is => 'rw', isa => Int, default => 99 );
has site_index => ( is => 'ro', isa => Str, default => 'weidai_com_cn' );                # hfax_com
extends 'HaoP2P::Bots';

sub search {
    my $self = shift;
    my @items;

    # 优选计划
    my $url    = $self->abs_url('/list/assetPacketList');
    my $params = { type       => 0, periodType => 0, page       => 0, rows       => 10, }; 
    my $max_page = $self->max_page;
    while ( $url && $max_page ) {
        $params->{page}++;
        $max_page--;
        $url = $self->abs_url_with_params( $url, $params );
        full_logs("# GET $url") if $self->debug;

        my $json = $self->ua->get( $url => get_headers() )->res->json;
        undef $url unless $json;
        undef $url unless $json->{success};
        $json->{data}->{count} //= 0;
        undef $url if $json->{data}->{count} == 0;

        foreach my $row ( @{ $json->{data}->{data} } ) {
            my $info = $self->get_info( $row, '优选计划' );
            push @items, $info;    # unless $self->debug;
            $self->store($info) unless $self->debug;
        }
    }

    # 散标列表
    $url            = $self->abs_url('/list/bidList');
    $max_page       = $self->max_page;
    $params->{page} = 0;
    while ( $url && $max_page ) {
        $params->{page}++;
        $max_page--;
        $url = $self->abs_url_with_params( $url, $params );
        full_logs("# GET $url") if $self->debug;

        my $json = $self->ua->get( $url => get_headers() )->res->json;
        undef $url unless $json;
        undef $url unless $json->{success};
        $json->{data}->{count} //= 0;
        undef $url if $json->{data}->{count} == 0;

        foreach my $row ( @{ $json->{data}->{data} } ) {
            my $info = $self->get_info( $row, '散标' );
            push @items, $info;    # unless $self->debug;
            $self->store($info) unless $self->debug;
        }
    }

    # 转让专区
    $url            = $self->abs_url('/list/transferList');
    $max_page       = $self->max_page;
    $params->{page} = 0;
    while ( $url && $max_page ) {
        $params->{page}++;
        $max_page--;
        $url = $self->abs_url_with_params( $url, $params );
        full_logs("# GET $url") if $self->debug;

        my $json = $self->ua->get( $url => get_headers() )->res->json;
        undef $url unless $json;
        undef $url unless $json->{success};
        $json->{data}->{count} //= 0;
        undef $url if $json->{data}->{count} == 0;

        foreach my $row ( @{ $json->{data}->{data} } ) {
            my $info = $self->get_info( $row, '转让' );
            push @items, $info;    # unless $self->debug;
            $self->store($info) unless $self->debug;
        }
    }


    return \@items;
}

sub get_info {
    my $self = shift;
    my $row = shift;
    my $tag = shift;

    my $info = {};

    # title
    $info->{title} = $row->{title};

    # tags, don't forget manual tag, forexample: '新手专享';
    push @{ $info->{tags} }, '新手专享'   if $row->{tags} && $row->{tags} == 1;
    push @{ $info->{tags} }, '大客户专享' if $row->{tags} && $row->{tags} == 2;
    push @{ $info->{tags} }, '手机专享'   if $row->{tags} && $row->{tags} == 4;
    push @{ $info->{tags} }, '定时标'     if $row->{tags} && $row->{tags} == 8;
    push @{ $info->{tags} }, '密码标'     if $row->{tags} && $row->{tags} == 16;
    push @{ $info->{tags} }, $tag         if $tag;

    map { @{ $info->{tags} }, $_ } @{$row->{activityTags}};
    push @{ $info->{tags} }, '' unless $info->{tags};

    # progress
    $info->{progress} = sprintf( '%2f', ( $row->{completionRate} || 0 ) / 100 );

    # min amount
    $info->{min_amount} = $row->{tenderMinAmount} || 0;

    # days
    $info->{days} = $row->{duration} || 0;
    $info->{days} *= 30 if $row->{durationTimeUnit} == 1;

    # status 'on/off'
    $info->{status} = $row->{status} eq 'OPENED' ? 'on' : 'off';

    # url
    $info->{url} = $self->abs_url( $row->{bidUrl} );

    # uniq_id
    $info->{uniq_id} = $row->{bid};

    # properties
    push @{ $info->{properties} }, { label => '项目总额',, value => $row->{bidAmount} } if $row->{bidAmount};
    push @{ $info->{properties} }, { label => '发布时间',, value => $row->{openTime} }  if $row->{openTime};
    push @{ $info->{properties} }, { label => '还款方式',, value => $row->{repaymentStyle} == 0 ? '月还息到期还本' : $row->{repaymentStyle} == 1 ? '等额本息' : '按月分期' } if defined $row->{repaymentStyle};
    push @{ $info->{properties} }, { label => '起息时间', value => '满标后T+1开始计息' };
    push @{ $info->{properties} }, { label => '风险保障', value => '适用风险备付金计划' };

    return $info;
}

sub get_headers {
    return {
        'Pragma'          => 'no-cache',
        'Accept-Encoding' => 'gzip, deflate, sdch, br',
        'Accept-Language' => 'en-US,en;q=0.8,zh-CN;q=0.6,zh;q=0.4',
        'User-Agent'      => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36',
        'Accept'          => '*/*',

# 'Referer' => 'https' => '//www.weidai.com.cn/list/showApList.html' ,
        'X-Requested-With' => 'XMLHttpRequest',
        'Connection'       => 'keep-alive',
        'Cache-Control'    => 'no-cache',
    };
}

1;

# vim:set ts=4 sw=4 et:
