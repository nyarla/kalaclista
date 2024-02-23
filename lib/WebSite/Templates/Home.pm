package WebSite::Templates::Home;

use strict;
use warnings;
use utf8;

use feature q(state);

use Kalaclista::HyperScript;
use WebSite::Helper::Hyperlink qw(href);

use WebSite::Context;
use WebSite::Widgets::Layout;
use WebSite::Helper::TailwindCSS;

sub date {
  my $datetime = shift;
  my $date     = ( split qr{T}, $datetime )[0];
  my ( $year, $month, $day ) = split qr{-}, $date;

  $year  = int($year);
  $month = int($month);
  $day   = int($day);

  return qq<${year}年${month}月${day}日>;
}

sub content {
  my $page    = shift;
  my $c       = WebSite::Context->instance;
  my $baseURI = $c->baseURI;

  state $header ||= header(
    h1(
      classes(q|text-xl sm:text-3xl font-bold mt-2 mb-4|),
      a( { href => $baseURI->to_string }, 'カラクリスタ' )
    ),
    p( classes(q|card before:bg-green text-xs sm:text-sm !pl-0.5|), '『輝かしい青春』なんて失かった人のWebSiteです。' ),
  );

  my @entries;
  for my $entry ( $page->entries->@* ) {
    my $published = date( $entry->date );
    my $updated   = date( $entry->lastmod // $entry->date );

    my $datetime = dt(
      classes(q|text-xs !mt-6|),
      time_( { datetime => $entry->date }, $published ),
      ( $published ne $updated ? ( span( classes(q|mx-1|), '→' ), time_( { datetime => $entry->lastmod }, $updated ) ) : () ),
      span( ' - ', $c->sections->{ $entry->type }->label, )
    );

    push @entries, $datetime;

    my $headline = dd(
      classes(q|!block !ml-0|),
      h2(
        classes(q|!text-base !mb-0 !mt-1|),
        a( { href => $entry->href->to_string }, $entry->title ),
      ),
    );

    push @entries, $headline;
  }

  return article(
    $header,
    section(
      classes(q|e-content mb-6|),
      h2('最近の更新'),
      dl(@entries),

      h2('更新の講読'),
      p('このWebサイトでは下記の Feed で最新の更新を受け取ることが出来ます：'),
      dl(
        dt('ブログ'),
        dd(
          ul(
            li( a( { href => 'https://the.kalaclista.com/posts/index.xml' },     'RSS 2.0' ) ),
            li( a( { href => 'https://the.kalaclista.com/posts/atom.xml' },      'Atom 1.0' ) ),
            li( a( { href => 'https://the.kalaclista.com/posts/jsonfeed.json' }, 'JSONFeed 1.1' ) ),
          ),
        ),
        dt('日記'),
        dd(
          ul(
            li( a( { href => 'https://the.kalaclista.com/echos/index.xml' },     'RSS 2.0' ) ),
            li( a( { href => 'https://the.kalaclista.com/echos/atom.xml' },      'Atom 1.0' ) ),
            li( a( { href => 'https://the.kalaclista.com/echos/jsonfeed.json' }, 'JSONFeed 1.1' ) ),
          ),
        ),
        dt('メモ帳'),
        dd(
          ul(
            li( a( { href => 'https://the.kalaclista.com/notes/index.xml' },     'RSS 2.0' ) ),
            li( a( { href => 'https://the.kalaclista.com/notes/atom.xml' },      'Atom 1.0' ) ),
            li( a( { href => 'https://the.kalaclista.com/notes/jsonfeed.json' }, 'JSONFeed 1.1' ) ),
          )
        ),
        dt('Webサイト全体'),
        dd(
          ul(
            li( a( { href => 'https://the.kalaclista.com/index.xml' },     'RSS 2.0' ) ),
            li( a( { href => 'https://the.kalaclista.com/atom.xml' },      'Atom 1.0' ) ),
            li( a( { href => 'https://the.kalaclista.com/jsonfeed.json' }, 'JSONFeed 1.1' ) ),
          )
        ),
      ),

      h2('カラクリスタについて'),
      p(
        'カラクリスタは',
        a( { href => 'https://the.kalaclista.com/nyarla/' }, '『にゃるら』とか『カラクリスタ』と名乗っている岡村直樹' ),
        'によって運営されているブログや日記、メモ帳をまとめた Web サイトです。'
      ),
      p(
        'この Web サイトは、過去にあちこちで書き散らしていたコンテンツを一つにまとめにまとめる事によって誕生しました。',
      ),
      p('そのため、この Web サイトの記事によっては内容が古くなっていたり、今の時世では適切ではない表現が含まれている場合があります。'),
      p(
        'またこの Web サイトが現在の形に至るまでに、ホスティング先の変更やドメインの移動などを繰り返していたため、',
        'その影響による表示の乱れや崩れなどを確認していますが、現状では修正し切れていないためその点はご了承ください。',
      ),

      h2('連絡先'),
      p(
        'このWebサイトについて何か連絡がある際には、下記の連絡先までご連絡ください。',
        '問合せの内容に基づき対応したいと考えています：',
      ),
      ul(
        li( 'メール - ',       a( { href => 'mailto:nyarla@kalaclista.com' },            'nyarla@kalaclista.com' ) ),
        li( 'Fediverse - ', a( { href => 'https://kalaclista.com/@nyarla' },          '@nyarla@kalaclista.com' ), ),
        li( 'Bluesky - ',   a( { href => 'https://bsky.app/profile/kalaclista.com' }, '@kalaclista.com' ) ),
      ),
      p(
        'なお一般的な問合せについては適切に対応したいと考えていますが、',
        'その時々の体調や問合せの内容によって応答をしない場合もありますので、その点、ご了承ください。'
      ),
      p(
        'また簡易的な連絡は Fediverse か Bluesky を経由した方が早くお答えできる可能性がありますが、',
        'Fediverse や Bluesky で応答がない、もしくは非公開の連絡を望む場合にはメールでの問合せをお願いします。'
      ),
    ),
  );
}

sub render {
  my $page = shift;
  return layout( $page => content($page) );
}

1;
