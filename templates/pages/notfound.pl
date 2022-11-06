use strict;
use warnings;
use utf8;

use WebSite::Widgets::Analytics;
use WebSite::Widgets::Info;
use WebSite::Widgets::Menu;
use WebSite::Widgets::Profile;
use WebSite::Widgets::Title;

use Kalaclista::Directory;
use Kalaclista::Variables;
use URI::Fast;

my $dirs = Kalaclista::Directory->instance;

my $stylesheet = $dirs->build_dir->child('assets/main.css');
my $css        = ( $stylesheet->is_file ) ? $stylesheet->slurp : q{};

my $script = $dirs->build_dir->child('assets/main.js');
my $js     = ( $script->is_file ) ? $script->slurp : q{};

my $search = 'https://cse.google.com/cse?cx=018101178788962105892:toz3mvb2bhr#gsc.tab=0';

my $baseURI = URI::Fast->new( $ENV{'URL'} // q{https://the.kalaclista.com} );
my $vars    = Kalaclista::Variables->new(
  title       => '404 not found',
  website     => 'カラクリスタ',
  description => 'ページが見つかりません',
  section     => 'pages',
  kind        => '404',
  data        => {
    css    => $css,
    js     => $js,
    loader => q{},
  },
  entries    => [],
  href       => '',
  breadcrumb => [],
);

my $main = sub {
  return main(
    article(
      { class => 'entry  entry__notfound' },
      header( h1('404 not found') ),
      p('要求されたページは見つかりませんでした。'),
      p('ページが見つからなかった理由には下記の様な原因があります：'),
      ul(
        li('歴史的経緯によりページが行方不明になっている'), li('なんらかの理由によりページが削除された'),
        li('そもそもそう言ったページは存在しない'),     li('URL を打ち間違えている')
      ),

      p('そのため『あれ？確か昔こんなページがあったはず……』と思われる場合、'),
      ul( li( a( { href => $search }, 'この Web サイトの全文検索（by Google）' ) ) ),
      p('を使うとお探しのページが見つかるかもしれません。')
    )
  );
};

my $template = sub {
  return document(
    expand( 'meta/head.pl', $vars, $baseURI ),
    [
      banner($baseURI),
      profile($baseURI),
      sitemenu($baseURI),
      $main->(),
      siteinfo($baseURI),
      analytics,
    ]
  );
};

$template;
