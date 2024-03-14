package WebSite::Context::URI;

use v5.38;
use utf8;

use feature qw(state);

use Exporter::Lite;
use URI::Fast;

use WebSite::Context::Environment;

our @EXPORT = qw(href baseURI);

sub baseURI {
  state $baseURI ||= URI::Fast->new(
      env->production ? 'https://the.kalaclista.com'
    : env->test       ? 'https://example.com'
    :                   'http://nixos:1313'
  );

  return $baseURI;
}

sub href : prototype($) {
  my $path = shift;
  my $href = baseURI->clone;
  $href->path($path);

  return $href;
}

1;
