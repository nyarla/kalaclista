package WebSite::Widgets::Analytics;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(analytics);

use Text::HyperScript qw(raw);
use Text::HyperScript::HTML5 qw(script);

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
