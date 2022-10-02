package WebSite::Widgets::Info;

use strict;
use warnings;
use utf8;

use Exporter::Lite;

use Text::HyperScript::HTML5 qw(p footer);
use WebSite::Helper::Hyperlink qw(hyperlink href);

our @EXPORT = qw(siteinfo);

sub siteinfo {
  my $baseURI = shift;
  return footer(
    { id => 'copyright' },
    p(
      '(C) 2006-' . ( (localtime)[5] + 1900 ) . ' ',
      hyperlink( 'OKAMURA Naoki aka nyarla', href( '/nyarla/', $baseURI ) )
    )
  );
}

1;
