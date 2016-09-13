package Util;
use feature qw/say state/;
use Time::HiRes qw/usleep/;
use DateTime;
use WWW::UserAgent::Random;
use Mojo::UserAgent;

use File::Path qw/make_path/;
use DB;
use Data::Dumper;

require Exporter;
@ISA       = qw(Exporter);
@EXPORT = qw/
    full_logs
    full_url
    get_ua
    now
    dt2s
/;

@EXPORT_OK = @EXPORT;

our $DEBUG = 0;

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
