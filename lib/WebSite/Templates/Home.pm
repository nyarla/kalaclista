package WebSite::Templates::Home;

use strict;
use warnings;
use utf8;

use Kalaclista::HyperScript;

use WebSite::Context::WebSite;
use WebSite::Context::URI qw(href);
use WebSite::Widgets::Layout;

sub date {
  return ( split qr{T}, shift )[0];
}

sub content {
  my $page = shift;

  return article(
    classes(qw|entry entry__home|),
    header( h1('カラクリスタとは？') ),
    section(
      classes(q|entry__content|),
      hr( { class => 'sep' } ),
      p(
        'カラクリスタとは',
        a(
          { href => 'https://the.kalaclista.com/nyarla/' },
          'にゃるらとかカラクリスタと名乗っている岡村直樹'
        ),
        'によって運営されているブログとメモ帳サイトです。',
        '長年ブログをあっちこっちで書いては移転を繰り返し、今の形に落ち着きました。'
      ),

      p(
        '元々色々なホスティング先に引越したり記事を思うがまま書き散らしていたので、',
        '今見返すと『何言ってんだコイツ』みたいな記事や表示が乱れている記事もあります。'
      ),

      p(
        'しかし最近ではその様な行動も落ち着き、今は定期的な週報と月報ブログになっているほか、',
        'また時々誰かの役に立つかもしれない記事を公開を不定期に公開しています。'
      ),

      h2('最近の更新'),
      ul(
        { class => 'archives' },
        (
          map {
            li(
              time_(
                { datetime => date( $_->date ) },
                date( $_->date ),
              ),
              a(
                { href => href("/@{[ $_->section ]}/") },
                WebSite::Context::WebSite::section( $_->section )->label,
              ),
              span('▹'),
              a( { href => $_->href, class => 'title' }, $_->title )
            )
          } $page->entries->@*
        )
      ),

      h2('提供されるコンテンツ'),

      p('カラクリスタで提供されるコンテンツは次の通りとなります：'),

      ul(
        li(
          a( { href => href('/posts/') }, 'ブログ' ),
          '：一般的なブログ。しっかりした記事を書いている'
        ),
        li(
          a( { href => href('/echos/') }, '日記' ),
          '：いわゆる日記。週報と月報、あと割とラフな記事を載せている'
        ),
        li(
          a( { href => href('/notes/') }, 'メモ帳' ),
          '：個人的なメモっぽいもの。Wiki 感を出したかった（つもり）'
        ),
      ),

      p('またこれらのコンテンツは更新情報を RSS 2.0 や Atom 、 JSONFeed として購読可能なので、良かったら購読をお願いします。'),

      ul(
        li(
          'カラクリスタ全体：',
          '  ',
          a( { href => href('/index.xml') }, 'RSS 2.0' ),
          '  ',
          a( { href => href('/atom.xml') }, 'Atom' ),
          '  ',
          a( { href => href('/jsonfeed.json') }, 'JSONFeed' ),
        ),

        li(
          'ブログ：',
          '  ',
          a( { href => href('/posts/index.xml') }, 'RSS 2.0' ),
          '  ',
          a( { href => href('/posts/atom.xml') }, 'Atom' ),
          '  ',
          a( { href => href('/posts/jsonfeed.json') }, 'JSONFeed' ),
        ),

        li(
          '日記：',
          '  ',
          a( { href => href('/echos/index.xml') }, 'RSS 2.0' ),
          '  ',
          a( { href => href('/echos/atom.xml') }, 'Atom' ),
          '  ',
          a( { href => href('/echos/jsonfeed.json') }, 'JSONFeed' ),
        ),

        li(
          'メモ帳：',
          '  ',
          a( { href => href('/notes/index.xml') }, 'RSS2.0' ),
          '  ',
          a( { href => href('/notes/atom.xml') }, 'Atom' ),
          '  ',
          a( { href => href('/notes/jsonfeed.json') }, 'JSONFeed' ),
        )
      ),

      h2('運営方針と著作権の云々'),
      p('このブログの運営方針と著作権やライセンスの云々は次のページで確認できます：'),
      ul(
        li( a( { href => href('/policies/') }, 'カラクリスタの運営ポリシー' ) ),
        li( a( { href => href('/licenses/') }, 'この Web サイトでのライセンスなどについて' ) ),
      ),

      h2('連絡先'),
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
          'GoToSocial:  ',
          a( { href => 'https://kalaclista.com/@nyarla' }, '@nyarla' ),
        ),
      ),
    ),
  );
}

sub render {
  my $page = shift;
  return layout( $page => content($page) );
}

1;
