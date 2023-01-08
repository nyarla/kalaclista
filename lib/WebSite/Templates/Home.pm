package WebSite::Templates::Home;

use strict;
use warnings;
use utf8;

use Kalaclista::HyperScript;
use WebSite::Helper::Hyperlink qw(href);

use Kalaclista::Constants;

use WebSite::Widgets::Analytics;
use WebSite::Widgets::Info;
use WebSite::Widgets::Menu;
use WebSite::Widgets::Profile;
use WebSite::Widgets::Title;
use WebSite::Widgets::Metadata;

sub date {
  return ( split qr{T}, shift )[0];
}

sub content {
  my $vars    = shift;
  my $baseURI = Kalaclista::Constants->baseURI;

  return article(
    { class => 'entry entry__home' },
    header( h1('カラクリスタとは？') ),
    section(
      { class => 'entry__content' },
      p(
        'カラクリスタとは',
        a(
          { href => 'https://the.kalaclista.com/nyarla/' },
          'にゃるらとかカラクリスタとか名乗っている岡村直樹'
        ),
        'によって運営されているブログとメモ帳サイトです。',
        '長年ブログをあっちこっちで書いては移転を繰り返し、今の形に落ち着きました。'
      ),

      p(
        '過去に色々と書き散らしていたので、今見返すと『何言ってんだコイツ』みたいな記事や、',
        'ホスティング元を移転しまくった結果として表示が乱れている記事もあります。'
      ),

      p(
        'しかし最近ではそのアホな行動も落ち着き、今は定期的な週報と月報ブログになっています。',
        '本当はもうちょっと良さげな記事とか書きたいんですが、やる気を出してないんで仕方ないよね……。'
      ),

      h1('提供されるコンテンツ'),

      p('カラクリスタで提供されるコンテンツは次の通りとなります：'),

      ul(
        li(
          a( { href => href( '/posts/', $baseURI ) }, 'ブログ' ),
          '：一般的なブログ。しっかりした記事を書いている'
        ),
        li(
          a( { href => href( '/echos/', $baseURI ) }, '日記' ),
          '：いわゆる日記。週報と月報、あと割とラフな記事を載せている'
        ),
        li(
          a( { href => href( '/notes/', $baseURI ) }, 'メモ帳' ),
          '：個人的なメモっぽいもの。Wiki の成りそこない'
        ),
      ),

      p('またこれらのコンテンツは更新情報を RSS 2.0 や Atom 、 JSONFeed として購読可能なので、良かったら購読をお願いします。'),

      ul(
        li(
          'カラクリスタ全体：',
          '  ',
          a( { href => href( '/index.xml', $baseURI ) }, 'RSS 2.0' ),
          '  ',
          a( { href => href( '/atom.xml', $baseURI ) }, 'Atom' ),
          '  ',
          a( { href => href( '/jsonfeed.json', $baseURI ) }, 'JSONFeed' ),
        ),

        li(
          'ブログ：',
          '  ',
          a( { href => href( '/posts/index.xml', $baseURI ) }, 'RSS 2.0' ),
          '  ',
          a( { href => href( '/posts/atom.xml', $baseURI ) }, 'Atom' ),
          '  ',
          a( { href => href( '/posts/jsonfeed.json', $baseURI ) }, 'JSONFeed' ),
        ),

        li(
          '日記：',
          '  ',
          a( { href => href( '/echos/index.xml', $baseURI ) }, 'RSS 2.0' ),
          '  ',
          a( { href => href( '/echos/atom.xml', $baseURI ) }, 'Atom' ),
          '  ',
          a( { href => href( '/echos/jsonfeed.json', $baseURI ) }, 'JSONFeed' ),
        ),

        li(
          'メモ帳：',
          '  ',
          a( { href => href( '/notes/index.xml', $baseURI ) }, 'RSS2.0' ),
          '  ',
          a( { href => href( '/notes/atom.xml', $baseURI ) }, 'Atom' ),
          '  ',
          a( { href => href( '/notes/jsonfeed.json', $baseURI ) }, 'JSONFeed' ),
        )
      ),

      h1('最近の更新'),
      ul(
        { class => 'archives' },
        (
          map {
            li(
              time_(
                { datetime => date( $_->date ) },
                date( $_->date )
              ),
              '（',
              a(
                { href => href( "/@{[ $_->type ]}/", $baseURI ) },
                $vars->contains->{ $_->type }->{'label'},
              ),
              '）',
              a( { href => $_->href, class => 'title' }, $_->title )
            )
          } $vars->entries->@*
        )
      ),

      h1('連絡先'),
      p('あとこの WebSite も含め私の連絡先は次の通りとなりますが、場合によっては返信しない可能性もあるのでその点はご了承ください。'),
      ul(
        li(
          'Email:  ',
          a(
            { href => 'mailto:nyarla@kalaclista.com' },
            'nyarla@kalaclista.com'
          ),
        ),

        li(
          'Twitter:  ',
          a( { href => 'https://twitter.com/kalaclista/' }, '@kalaclista' ),
        ),
      ),
    ),
  );
}

sub render {
  my $vars = shift;

  return document(
    metadata($vars),
    [
      banner,
      profile,
      sitemenu,
      content($vars),
      siteinfo,
      analytics,
    ]
  );
}

1;
