#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../../lib";
use Pod::Usage;
use Getopt::Long;
use HaoP2P;


my $site_rs = HaoP2P->rset( 'P2PSite' );

$site_rs->find( 1 )->update( { about => '陆金所，全称上海陆家嘴国际金融资产交易市场股份有限公司，是全球领先的互联网财富管理平台，平安集团旗下成员，2011年9月在上海注册成立，注册资本金8.37亿元，位于国际金融中心上海陆家嘴。
陆金所致力于结合金融全球化发展与信息技术创新，以健全的风险管控体系为基础，为广大机构、企业与合格投资者等提供专业、高效、安全的综合性金融资产交易信息及咨询相关服务。
陆金所旗下lu.com网络投融资平台（www.lu.com，原域名www.lufax.com）2012年3月正式上线运营。作为中国平安集团倾力打造的平台，lu.com结合全球金融发展与互联网技术创新，在健全的风险管控体系基础上，为中小企业及个人客户提供专业、可信赖的投融资服务，帮助他们实现便捷高效的低成本融资和财富增值。'});

