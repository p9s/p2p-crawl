package WWW;
use Mojo::Base 'Mojolicious';
use lib '../../lib';
use HaoP2P;
use Data::Dumper;

# This method will run once at server start
sub startup {
    my $self = shift;

    my $config = $self->plugin(
        'yaml_config' => {
            file      => 'conf/config.yaml',
            stash_key => 'config',
            class     => 'YAML::XS'

        }
    );

    #$self->config($config);
    $self->plugin(
        'tt_renderer' => {
            template_options => {
                DEBUG        => 1,
                UNICODE      => 1,
                ENCODING     => 'UTF-8',
                PRE_CHOMP    => 1,
                POST_CHOMP   => 1,
                TRIM         => 1,
            }
        }
    );

    #push @{$self->renderer->paths}, 'views';
    $self->defaults( layout => 'wrapper' );
    $self->renderer->default_handler('tt');

    # Router
    my $r = $self->routes;

    # Normal route to controller
    $r->get('/')->to('root#index');
    $r->get('/product/:haop2p_product_id')->to('product#index');
}

1;
