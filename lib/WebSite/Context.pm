use v5.38;
use builtin qw(true false);
use feature qw(class state);
no warnings qw(experimental);

use URI::Fast;

use Kalaclista::Context;
use Kalaclista::Data::Directory;

class WebSite::Context : isa(Kalaclista::Context) {

  sub init {
    my $class  = shift;
    my $detect = shift;

    my $production = ( exists $ENV{'KALACLISTA_ENV'} && $ENV{'KALACLISTA_ENV'} eq 'production' );

    Kalaclista::Context->init(
      production => $production,
      baseURI    => ( $production ? 'https://the.kalaclista.com' : 'http://nixos:1313' ),
      dirs       => {
        detect => $detect,
        cache  => q{cache},
        dist   => q{public/dist},
        src    => q{src},
      }
    );

    return $class->instance;
  }

}
