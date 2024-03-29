package WebSite::Templates::NotFound;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Kalaclista::HyperScript;
use WebSite::Helper::Hyperlink qw(href);

use WebSite::Widgets::Layout;

my $search = 'https://cse.google.com/cse?cx=018101178788962105892:toz3mvb2bhr#gsc.tab=0';

sub date {
  return ( split qr{T}, shift )[0];
}

sub content {
  return article(
    classes(qw|entry entry__notfound|),
    header( h1('404 not found') ),
    section(
      classes(qw|entry__content|),
      { class => 'entry__content' },
      hr( { class => 'sep' } ),
      p('要求されたページは見つかりませんでした。'),
      p('ページが見つからなかった理由には下記の様な原因があります：'),
      ul(
        li('歴史的経緯によりページが行方不明になっている'),
        li('なんらかの理由によりページが削除された'),
        li('そもそもそう言ったページは存在しない'),
        li('URL を打ち間違えている')
      ),

      p('そのため『あれ？確か昔こんなページがあったはず……』と思われる場合、'),
      ul( li( a( { href => $search }, 'この Web サイトの全文検索（by Google）' ) ) ),
      p('を使うとお探しのページが見つかるかもしれません。')
    ),
  );
}

sub render {
  my $vars = shift;
  return layout( $vars => content($vars) );
}

1;
