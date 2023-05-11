package WebSite::Templates::Permalink;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Kalaclista::HyperScript;
use WebSite::Helper::Hyperlink qw(href);

use Kalaclista::Constants;

use WebSite::Widgets::Layout;

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
    { class => 'ads top' },
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
    { class => 'ads bottom' },
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

  return ( $position eq 'top' ? ( hr, $top ) : ( hr, $bottom ) );
}

sub content {
  my $vars  = shift;
  my $entry = $vars->entries->[0];

  my $date     = date( $entry->date );
  my $readtime = readtime( $entry->dom->innerHTML );

  my @top    = $vars->section =~ m{^(?:posts|echos|notes)$} ? ads('top')    : ();
  my @bottom = $vars->section =~ m{^(?:posts|echos|notes)$} ? ads('bottom') : ();

  return article(
    { class => 'entry entry__permalink' },
    header(
      h1( a( { href => $entry->href->to_string }, $entry->title ) ),
      p(
        time_( { datetime => $date }, "更新：${date}" ),
        span("読了まで：約${readtime}分"),
      ),
    ),
    section(
      { class => 'entry__content' },
      @top,
      hr( { class => 'sep' } ),
      raw( $entry->dom->innerHTML ),
      @bottom,
    ),
  );
}

sub render {
  my $vars = shift;

  return layout( $vars => content($vars) );
}

1;
