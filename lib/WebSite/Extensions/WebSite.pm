package WebSite::Extensions::WebSite;

use strict;
use warnings;
use utf8;

use URI::Fast;
use URI::Escape qw(uri_unescape);
use YAML::XS ();

use Text::HyperScript::HTML5 qw(a h1 p blockquote cite);

use Kalaclista::Constants;
use Kalaclista::Utils qw(make_path);
use Kalaclista::WebSite;

my $datadir = Kalaclista::Constants->rootdir->child('content/data/webdata');

sub transform {
  my ( $class, $entry, $dom ) = @_;

  for my $item ( $dom->find('ul > li:only-child > a:only-child')->@* ) {
    my $href = $item->getAttribute('href');
    my $text = $item->innerText;

    next if ( $href !~ m{^https?} );

    my $path = make_path( URI::Fast->new($href) );
    my $file = $datadir->child("${path}.yaml");

    my $link = uri_unescape($href);
    my ( $title, $summary );

    if ( -f $file->path ) {
      my $data = YAML::XS::LoadFile( $file->path );

      $title   = $data->{'title'}   if ( exists $data->{'title'}   && $data->{'title'} ne q{} );
      $summary = $data->{'summary'} if ( exists $data->{'summary'} && $data->{'summary'} ne q{} );
    }

    $title   //= $text // $summary // $link;
    $summary //= $text // $title   // $link;

    $summary = substr( $summary, 0, 70 ) . "・・・";

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
