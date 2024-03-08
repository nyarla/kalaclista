package WebSite::Widgets::Info;

use v5.38;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(siteinfo);

use Kalaclista::HyperScript qw(p footer a);

use WebSite::Context::URI qw(href);

sub siteinfo {
  state $info ||= footer(
    { id => 'copyright' },
    p(
      "(c) 2006-@{[ (localtime)[5] + 1900 ]} ",
      a( { href => href('/nyarla/')->to_string }, 'OKAMURA Naoki aka nyarla' ),
    ),
  );

  return $info;
}

1;
