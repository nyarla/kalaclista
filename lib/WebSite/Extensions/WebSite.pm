package WebSite::Extensions::WebSite;

use strict;
use warnings;
use utf8;

use URI::Fast;
use URI::Escape qw(uri_unescape);
use YAML::XS ();

use Kalaclista::HyperScript qw(a h2 p blockquote cite div small);

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
    utf8::decode($link);
    my ( $title, $summary );

    my $exist = 1;

    if ( defined( $data->is_gone ) && $data->is_gone ) {
      $exist = 0;
    }
    elsif ( defined( $data->is_ignore ) && $data->is_ignore ) {
      $exist = 0;
    }
    elsif ( defined( $data->status ) && ( $data->status !~ m{^(?:2|304)} ) ) {
      $exist = 0;
    }

    if ($exist) {
      $title   = $data->title;
      $summary = $data->summary;
    }

    for my $label ( ( $text, $summary, $link ) ) {
      if ( !defined $title || $title eq q{} ) {
        $title = $label;
        next;
      }

      last;
    }

    for my $label ( ( $text, $title, $link ) ) {
      if ( !defined $summary || $summary eq q{} ) {
        $summary = $label;
        next;
      }

      last;
    }

    if ( length($summary) > 39 ) {
      $summary = substr( $summary, 0, 39 ) . "……";
    }

    my $html;
    if ($exist) {
      $html = a(
        { href => $href },
        h2($title),
        p( cite($link) ),
        blockquote( p($summary) )
      );
    }
    else {
      my $msg = $data->is_ignore ? '無効なリンクです' : 'リンク切れです';

      $html = div(
        h2($title),
        p( cite($link), small($msg) ),
        blockquote( p($summary) )
      );
    }

    my $article = $item->tree->createElement('aside');
    $article->setAttribute( class => 'content__card--website' );
    $article->innerHTML("${html}");

    $item->parent->parent->replace($article);
  }

  return $entry;
}

1;
