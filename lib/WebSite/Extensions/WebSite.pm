package WebSite::Extensions::WebSite;

use strict;
use warnings;
use utf8;

use URI::Fast;
use URI::Escape qw(uri_unescape);
use YAML::XS ();

use Kalaclista::HyperScript qw(a h1 p blockquote cite);

use Kalaclista::Constants;
use Kalaclista::WebSite;

my $datadir = Kalaclista::Constants->rootdir->child('content/data/webdata');

sub transform {
  my ( $class, $entry, $dom ) = @_;

  for my $item ( $dom->find('ul > li:only-child > a:only-child')->@* ) {
    my $href = $item->getAttribute('href');
    my $text = $item->innerText;

    next if ( $href !~ m{^https?} );

    my $data = Kalaclista::WebSite->load( $href, $datadir );
    my $link = uri_unescape($href);
    my ( $title, $summary );

    if ( !$data->is_gone and !$data->is_ignore ) {
      $title   = $data->title;
      $summary = $data->summary;
    }

    $title   //= $text // $summary // $link;
    $summary //= $text // $title   // $link;

    if ( length($title) > 35 ) {
      $title = substr( $title, 0, 35 ) . "……";
    }

    if ( length($summary) > 70 ) {
      $summary = substr( $summary, 0, 70 ) . "……";
    }

    my $html = a(
      { href => $href },
      h1($title),
      p( cite($link) ),
      blockquote( p($summary) )
    );

    my $article = $item->tree->createElement('aside');
    $article->setAttribute( class => 'content__card--website' );
    $article->innerHTML("${html}");

    $item->parent->parent->replace($article);
  }

  return $entry;
}

1;
