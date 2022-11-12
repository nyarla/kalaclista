package WebSite::Widgets::Analytics;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(analytics);

use Text::HyperScript qw(true raw);
use Text::HyperScript::HTML5 qw(script);

sub analytics {
  state $result ||= script(
    raw(
      qq{
(() => {
  const events =
    "wheel,touchstart,touchmove,keypress,keydown,pointermove".split(",");

  var loaded = false;
  const lazyloader = () => {
    if (loaded) {
      return;
    }

    loaded = true;

    let analytics = document.createElement("script");
    Object.assign(analytics, {
      src: "https://www.googletagmanager.com/gtag/js?id=G-18GLHBH79E",
      async: "async",
    });

    for (let ev of events) {
      document.removeEventListener(ev, lazyloader);
    }

    document.body.appendChild(analytics);
  };

  for (let ev of events) {
    document.addEventListener(ev, lazyloader);
  }

})();

window.dataLayer = window.dataLayer || [];

function gtag(){dataLayer.push(arguments);}

gtag('js', new Date());
gtag('config', 'G-18GLHBH79E');
    }
    )
  );
  return $result;
}

1;
