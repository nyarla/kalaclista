package WebSite::Helper::Digest;

use strict;
use warnings;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(digest);

use YAML::XS;
use WebSite::Context;

sub calculate {
  my $path   = shift;
  my $digest = `openssl dgst -r -sha256 "$path" | cut -c 1-7`;
  chomp($digest);

  return $digest;
}

sub digest {
  state $rootdir ||= WebSite::Context->instance->dirs->rootdir;
  state $cache   ||= {};

  my $file = shift;

  if ( exists $cache->{$file} ) {
    return $cache->{$file};
  }

  my $path   = $rootdir->child($file)->path;
  my $digest = calculate($path);

  $cache->{$file} = $digest;
  return $digest;
}

1;
