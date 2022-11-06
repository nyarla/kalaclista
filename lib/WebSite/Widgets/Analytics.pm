package WebSite::Widgets::Analytics;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(analytics);

use Text::HyperScript qw(true);
use Text::HyperScript::HTML5 qw(script);

sub analytics {
  state $result ||= script(
    {}, qq{
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-18GLHBH79E');  
  }
  );
}

1;
