package WebSite::Widgets::Analytics;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(analytics);

use Kalaclista::HyperScript qw(script raw);

my $code = <<'...';
window.dataLayer = window.dataLayer || [];
function gtag(){dataLayer.push(arguments);}
gtag('js', new Date());
gtag('config', 'G-18GLHBH79E'); 
...

sub analytics {
  state $result;
  return $result if ( defined $result );

  $result = script( raw($code) );

  return $result;
}

1;
