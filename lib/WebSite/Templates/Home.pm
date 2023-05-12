package WebSite::Templates::Home;

use strict;
use warnings;
use utf8;

use Kalaclista::HyperScript;
use WebSite::Helper::Hyperlink qw(href);

use Kalaclista::Constants;

use WebSite::Widgets::Layout;

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
      hr( { class => 'sep' } ),
      { class => 'entry__content' },
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
                '：（',
                a(
                  { href => href( "/@{[ $_->type ]}/", $baseURI ) },
                  $vars->contains->{ $_->type }->{'label'},
                ),
                '）'
              ),
              a( { href => $_->href, class => 'title' }, $_->title )
            )
          } $vars->entries->@*
        )
      ),

      h2('提供されるコンテンツ'),

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
          '：個人的なメモっぽいもの。Wiki 感を出したかった（つもり）'
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

      h2('運営方針と著作権の云々'),
      p('このブログの運営方針と著作権やライセンスの云々は次のページで確認できます：'),
      ul(
        li( a( { href => href( '/policies/', $baseURI ) }, 'カラクリスタの運営ポリシー' ) ),
        li( a( { href => href( '/licenses/', $baseURI ) }, 'この Web サイトでのライセンスなどについて' ) ),
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
  my $vars = shift;
  return layout( $vars => content($vars) );
}

1;
