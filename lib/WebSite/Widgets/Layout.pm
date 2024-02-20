package WebSite::Widgets::Layout;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;
our @EXPORT = qw( layout );

use Kalaclista::HyperScript;
use WebSite::Helper::TailwindCSS;

use WebSite::Context;

use WebSite::Widgets::Navigation;
use WebSite::Widgets::Information;

use WebSite::Widgets::Menu;
use WebSite::Widgets::Profile;
use WebSite::Widgets::Metadata;

my $search = 'https://cse.google.com/cse?cx=018101178788962105892:toz3mvb2bhr#gsc.tab=0';
my $goat   = script(
  {
    "data-goatcounter" => "https://stats.kalaclista.com/count",
    async              => true,
    src                => 'https://stats.kalaclista.com/count.js'
  },
  ''
);

sub layout {
  state $c         ||= WebSite::Context->instance;
  state $analytics ||= [ $c->production ? ($goat) : () ];
  my ( $vars, $content ) = @_;

  my $baseURI = $c->baseURI;

  return qq(<!DOCTYPE html>\n) . html(
    { lang => 'ja' },
    metadata($vars),
    body(
      classes(q|container mx-auto max-w-2xl px-4|),
      navigation($vars),
      main( classes(q|card-frame px-4 py-2 bg-bright|), $content ),
      profile,
      footer( information, copyright ),
      $analytics->@*,
    )
  );
}

1;
