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

    my $stage = exists $ENV{'KALACLISTA_ENV'} ? $ENV{'KALACLISTA_ENV'} : 'development';
    my $on    = exists $ENV{'CI'} ? 'ci' : exists $ENV{'IN_PERL_SHELL'} ? 'local' : 'runtime';
    my $env   = Kalaclista::Context::Environment->new(
      environment => $stage,
      on          => $on,
    );

    my $context = WebSite::Context->new(
      baseURI => URI::Fast->new( $env->production ? 'https://the.kalaclista.com' : 'http://nixos:1313' ),
      dirs    => Kalaclista::Data::Directory->instance(
        detect => $detect,
        cache  => q{cache},
        dist   => q{public/dist},
        src    => q{src},
      ),
      env => $env,
    );

    $class->instance($context);
    return $class->instance;
  }

  method production {
    return $self->env->production;
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
