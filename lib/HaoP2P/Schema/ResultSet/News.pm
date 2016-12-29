package HaoP2P::Schema::ResultSet::News;
use utf8;
use strict;
use warnings;
use feature qw/say/;
use DateTime;

use base 'HaoP2P::Schema::ResultSet';

sub top_news {
    my $self  = shift;
    my $page  = shift // 1;
    my $items = shift // 10;

    return $self->search(
        { is_public => '1', },
        {   order_by => { -desc => 'id' },
            rows     => $items,
            page     => $page,
        }
    );
}

sub is_exists {
    my $self    = shift;
    my $uniq_id = shift;

    say "UNIQ_ID not found!" unless $uniq_id;
    return unless $uniq_id;
    return $self->search( { uniq_id => $uniq_id }, { rows => 1 } )->single;
}

sub create_news {
    my $self   = shift;
    my $params = shift;

    return unless $params->{title};
    return unless $params->{uniq_id};
    return unless $params->{content};
    $params->{created_at} = DateTime->now( time_zone => 'Asia/Shanghai' );
    $params->{descript} = '' unless $params->{descript};
    return $self->create($params);
}

1;
