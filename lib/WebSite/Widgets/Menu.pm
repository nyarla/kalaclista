package WebSite::Widgets::Menu;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(sitemenu);

use Kalaclista::HyperScript    qw(nav hr p);
use WebSite::Helper::Hyperlink qw(hyperlink href);

use WebSite::Context;

my $search = 'https://cse.google.com/cse?cx=018101178788962105892:toz3mvb2bhr#gsc.tab=0';

sub sitemenu {
  state $result;
  return $result if ( defined $result );

  my $baseURI = WebSite::Context->instance->baseURI;
  $result = nav(
    { id => 'menu' },
    p(
      { class => 'section' },
      hyperlink( 'ブログ', href( '/posts/', $baseURI ) ),
      hyperlink( '日記',  href( '/echos/', $baseURI ) ),
      hyperlink( 'メモ帳', href( '/notes/', $baseURI ) ),
    ),
    p(
      { class => 'help' },
      hyperlink( 'プロフィール', href( '/nyarla/', $baseURI ) ),
      hyperlink( '検索',     $search ),
    ),
  );

  return $result;
}

1;
