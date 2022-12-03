package WebSite::Templates::Permalink;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Text::HyperScript qw(raw);
use Text::HyperScript::HTML5;
use Kalaclista::HyperScript::More;

use WebSite::Widgets::Analytics;
use WebSite::Widgets::Info;
use WebSite::Widgets::Menu;
use WebSite::Widgets::Profile;
use WebSite::Widgets::Title;
use WebSite::Widgets::Metadata;

sub readtime {
  my $text = shift;
  $text =~ s{<pre[\s\S]+?/pre>}{}g;
  $text =~ s{<blockquote[\s\S]+?/blockquote>}{}g;
  $text =~ s{<aside.+?content__card[\s\S]+?</aside>}{}g;
  $text =~ s{</?.+?>}{}g;

  return int( length($text) / 500 );
}

sub date {
  return ( split qr{T}, shift )[0];
}

sub ads {
  state $top ||= aside(
    { class => 'ads' },
    ins(
      {
        class => 'adsbygoogle',
        style => 'display:block',
        data  => {
          'ad-format'     => 'fluid',
          'ad-format-key' => '-gr-d+2d-6d+7k',
          'ad-client'     => 'ca-pub-1273544194033160',
          'ad-slot'       => '5004342069'
        }
      },
      ""
    ),
    script( raw("(adsbygoogle = window.adsbygoogle || []).push({})") ),
  );

  state $bottom ||= aside(
    { class => 'ads' },
    ins(
      {
        class => 'adsbygoogle',
        style => 'display:block',
        data  => {
          'ad-format' => 'autorelaxed',
          'ad-client' => 'ca-pub-1273544194033160',
          'ad-slot'   => '2107661428'
        },
      },
      ""
    ),
    script( raw("(adsbygoogle = window.adsbygoogle || []).push({})") ),
  );

  my $position = shift;

  return $position eq 'top' ? $top : $bottom;
}

sub render {
  my $vars  = shift;
  my $entry = $vars->entries->[0];

  my $date     = date( $entry->date );
  my $readtime = readtime( $entry->dom->innerHTML );

  return document(
    metadata($vars),
    [
      banner,
      profile,
      sitemenu,
      main(
        ads('top'),
        article(
          { class => 'entry' },
          header(
            p(
              time_( { datetime => $date }, "${date}：" ),
              span("読了まで：約${readtime}分"),
            ),
            h1( a( { href => $entry->href->to_string }, $entry->title ) ),
          ),
          section(
            { class => 'entry__content' },
            raw( $entry->dom->innerHTML ),
          ),
        ),
        ads('bottom'),
      ),
      siteinfo,
      analytics,
    ],
  );
}

1;
