use v5.38;
use builtin qw(true false);
use feature qw(class state);
no warnings qw(experimental);

use URI::Fast;

use Kalaclista::Data::Directory;

class WebSite::Context {
  field $baseURI;

  field $detect : param;
  field $dirs;

  method dirs {
    $dirs ||= Kalaclista::Data::Directory->instance(
      detect => $detect,
      cache  => q{cache},
      dist   => q{public/dist},
      src    => q{src},
    );

    return $dirs;
  }

  method production {
    return exists $ENV{'KALACLISTA_ENV'} && $ENV{'KALACLISTA_ENV'} eq 'production';
  }

  method baseURI {
    return URI::Fast->new( $self->production ? 'https://the.kalaclista.com' : 'http://nixos:1313' );
  }
}
