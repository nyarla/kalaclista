package WebSite::Widgets::Layout;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;
our @EXPORT = qw( layout );

use Kalaclista::HyperScript;

use WebSite::Context::Environment qw(env);
use WebSite::Context::URI         qw(href);

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

sub layout {
  state $analytics ||= [ env->production ? ($goat) : () ];
  my ( $vars, $content ) = @_;

  return document(
    metadata($vars),
    body(
      classes(qw|px-4|),
      banner($vars),
      main(
        classes(qw|card-rounded my-8|),
        nav(
          classes(qw|text-center sm:float-right [&>a]:ml-2|),
          { id => 'section' },
          a( { href => href('/posts/') },                                    'ブログ' ),
          a( { href => href('/echos/') },                                    '日記' ),
          a( { href => href('/notes/') },                                    'メモ帳' ),
          a( { href => $search, 'aria-label' => 'Google カスタム検索ページへのリンクです' }, '検索' ),
        ),
        $content
      ),
      profile,
      siteinfo,
      $analytics->@*,
    )
  );
}

1;
