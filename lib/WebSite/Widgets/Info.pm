package WebSite::Widgets::Info;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(siteinfo);

use Kalaclista::HyperScript    qw(p footer raw);
use WebSite::Helper::Hyperlink qw(hyperlink href);

use WebSite::Context;

sub siteinfo {
  state $result;
  return $result if ( defined $result );

  my $baseURI = WebSite::Context->instance->baseURI;

  $result = footer(
    { id => 'copyright' },
    p(
      '(c) 2006-' . ( (localtime)[5] + 1900 ) . ' ',
      hyperlink( 'OKAMURA Naoki aka nyarla', href( '/nyarla/', $baseURI ) )
    )
  );

  return $result;
}

1;
