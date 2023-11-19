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

    my $baseURI =
          $env->production ? 'https://the.kalaclista.com'
        : $env->test       ? 'https://example.com'
        :                    'http://nixos:1313';

    my $cache = q{cache};
    my $dist =
          $env->production  ? q{public/dist}
        : $env->development ? q{public/dev}
        :                     q{public/test};

    my $src = ( !$env->test ) ? q{src} : q{t/fixtures};

    my $c = WebSite::Context->new(
      env     => $env,
      baseURI => URI::Fast->new($baseURI),
      dirs    => Kalaclista::Data::Directory->instance(
        detect => $detect,
        cache  => $cache,
        dist   => $dist,
        src    => $src,
      ),
    );

    $class->instance($c);
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
