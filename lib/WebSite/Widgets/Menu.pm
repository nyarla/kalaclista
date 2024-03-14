package WebSite::Widgets::Menu;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(sitemenu);

use Kalaclista::HyperScript qw(nav hr p a);

use WebSite::Context::URI qw(href);

my $search = 'https://cse.google.com/cse?cx=018101178788962105892:toz3mvb2bhr#gsc.tab=0';

sub sitemenu {
  state $html ||= nav(
    { id => 'menu' },
    p(
      { class => 'section' },
      a( { href => href('/posts/')->to_string }, 'ブログ' ),
      a( { href => href('/echos/')->to_string }, '日記' ),
      a( { href => href('/notes/')->to_string }, 'メモ帳' ),
    ),
    p(
      { class => 'help' },
      a( { href => href('/nyarla/')->to_string }, 'プロフィール' ),
      a( { href => $search },                     '検索' ),
    ),
  );

  return $html;
}

1;
