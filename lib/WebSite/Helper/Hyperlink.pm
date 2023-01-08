package WebSite::Helper::Hyperlink;

use strict;
use warnings;

use Kalaclista::HyperScript qw(a);

use Exporter::Lite;

our @EXPORT = qw( href hyperlink );

sub href {
  my ( $path, $baseURI ) = @_;

  my $url = $baseURI->clone;
  $url->path($path);

  return $url->as_string;
}

sub hyperlink {
  my ( $title, $href ) = @_;
  return a( { href => $href }, $title );
}

1;
