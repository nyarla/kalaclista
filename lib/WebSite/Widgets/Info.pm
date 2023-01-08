package WebSite::Widgets::Info;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(siteinfo);

use Kalaclista::HyperScript qw(p footer);
use WebSite::Helper::Hyperlink qw(hyperlink href);

use Kalaclista::Constants;

sub siteinfo {
  state $result;
  return $result if ( defined $result );

  my $baseURI = Kalaclista::Constants->baseURI;

  $result = footer(
    { id => 'copyright' },
    p(
      '(C) 2006-' . ( (localtime)[5] + 1900 ) . ' ',
      hyperlink( 'OKAMURA Naoki aka nyarla', href( '/nyarla/', $baseURI ) )
    )
  );

  return $result;
}

1;
