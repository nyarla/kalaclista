package WebSite::Helper::Digest;

use strict;
use warnings;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(digest);

sub calculate {
  my $path   = shift;
  my $digest = `openssl dgst -r -sha256 "$path" | cut -c 1-7`;
  chomp($digest);

  return $digest;
}

sub digest {
  state $cache ||= {};

  my $path = shift;

  if ( exists $cache->{$path} ) {
    return $cache->{$path};
  }

  my $digest = calculate($path);

  $cache->{$path} = $digest;

  return $digest;
}

1;
