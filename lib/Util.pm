package Util;
use feature qw/say state/;
use Time::HiRes qw/usleep/;
use DateTime;
use WWW::UserAgent::Random;
use Mojo::UserAgent;
use String::CamelCase qw/camelize/;
use File::Basename qw/fileparse/;
use JSON qw/to_json/;
use Carp qw/carp cluck/;

use Data::Dumper;

require Exporter;
@ISA       = qw(Exporter);
@EXPORT = qw/
    full_logs
    full_url
    get_ua
    now
    dt2s
    camelize
    carp
    cluck
    fileparse
    chompf
    merge_space
    to_json
    clean_text
/;

@EXPORT_OK = @EXPORT;

our $DEBUG = 0;


sub clean_text {
    my $str = shift;
    return unless $str;
    return merge_space( chompf( $str ) );
}

sub merge_space {
    my $str = shift;
    return '' unless $str;
   
    $str =~ s/\t+/ /g;
    $str =~ s/\r\n//g;
    $str =~ s/\s+/ /g;
    return $str;
}

sub chompf {
    my $str = shift;
    return '' unless $str;
    $str =~ s/^\s+//g;
    $str =~ s/\s+$//g;
    return $str;
}

sub full_url {
    my $url     = shift;
    my $abs_url = shift;
    return $url unless $abs_url;

    return URI->new_abs( $url, $abs_url )->canonical->as_string;
}

sub full_logs {
    my ( $logs, $level ) = @_;

    $now = dt2s( now() );
    say "[$now] $logs";
    die if $leve && $level eq 'die';
}


sub now {
    return DateTime->now( time_zone => 'Asia/Shanghai' );
}

sub dt2s {
    my $dt = shift;
    my $format = shift || '%Y-%m-%d %H:%M:%S';
    return $dt->strftime($format);
}

sub get_ua {
    my $ua = Mojo::UserAgent->new;
    $ua->max_redirects(0);
    $ua->transactor->name('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36');

#$ua->transactor->name( rand_ua('') );
    $ua = $ua->cookie_jar( Mojo::UserAgent::CookieJar->new );
    return $ua;
}

1;
