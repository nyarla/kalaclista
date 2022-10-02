package WebSite::Widgets::Menu;

use strict;
use warnings;
use utf8;

use Exporter::Lite;

use Text::HyperScript::HTML5 qw(nav hr p);
use WebSite::Helper::Hyperlink qw(hyperlink href);

our @EXPORT = qw(sitemenu);

my $search = 'https://cse.google.com/cse?cx=018101178788962105892:toz3mvb2bhr#gsc.tab=0';

sub sitemenu {
  my $baseURI = shift;

  return nav(
    { id => 'menu', class => 'entry__content' },
    hr,
    p(
      { class => 'kind' },
      hyperlink( 'ブログ', href( '/posts/', $baseURI ) ),
      hyperlink( '日記',  href( '/echos/', $baseURI ) ),
      hyperlink( 'メモ帳', href( '/notes/', $baseURI ) ),
    ),
    p(
      { class => 'links' },
      hyperlink( '運営方針', href( '/policies/', $baseURI ) ),
      hyperlink( '権利情報', href( '/licenses/', $baseURI ) ),
      hyperlink( '検索',   $search ),
    ),
  );
}

1;
