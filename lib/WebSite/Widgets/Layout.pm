package WebSite::Widgets::Layout;

use strict;
use warnings;
use utf8;

use Exporter::Lite;
our @EXPORT = qw( layout );

use Kalaclista::HyperScript;
use Kalaclista::Constants;

use WebSite::Helper::Hyperlink qw(hyperlink href);

use WebSite::Widgets::Analytics;
use WebSite::Widgets::Info;
use WebSite::Widgets::Menu;
use WebSite::Widgets::Profile;
use WebSite::Widgets::Title;
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
my @analytics = Kalaclista::Constants->vars->is_production ? ($goat) : ();

sub layout {
  my ( $vars, $content ) = @_;
  my $baseURI = Kalaclista::Constants->baseURI;

  return document(
    metadata($vars),
    [
      banner($vars),
      main(
        nav(
          { id => 'section' },
          hyperlink( 'ブログ', href( '/posts/', $baseURI ) ),
          hyperlink( '日記',  href( '/echos/', $baseURI ) ),
          hyperlink( 'メモ帳', href( '/notes/', $baseURI ) ),
          a( { href => $search, 'aria-label' => 'Google カスタム検索ページへのリンクです' }, '検索' ),
        ),
        $content
      ),
      profile,
      siteinfo,
      @analytics,
    ]
  );
}

1;
