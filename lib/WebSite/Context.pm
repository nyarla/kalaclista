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
    my $context    = WebSite::Context->new(
      production => $production,
      baseURI    => URI::Fast->new( $production ? 'https://the.kalaclista.com' : 'http://nixos:1313' ),
      dirs       => Kalaclista::Data::Directory->instance(
        detect => $detect,
        cache  => q{cache},
        dist   => q{public/dist},
        src    => q{src},
      ),
    );

    $class->instance($context);
    return $class->instance;
  }

  method entries {
    return $self->dirs->src('entries/src');
  }

  method datadir {
    return $self->dirs->rootdir->child('content/data');
  }

  method distdir {
    return $self->dirs->distdir;
  }

  method srcdir {
    return $self->dirs->srcdir;
  }
}
