package WebSite::Extensions::WebSite;

use v5.38;
use utf8;

use feature qw(isa);

use Exporter::Lite;

use Kalaclista::HyperScript qw(a div h2 p blockquote cite small);

use WebSite::Context::Path   qw(srcdir);
use WebSite::Loader::WebSite qw(external);

BEGIN {
  WebSite::Loader::WebSite->init( srcdir->child('data/website.csv')->to_string );
}

our @EXPORT_OK = qw(cardify apply);

sub cardify : prototype($) {
  my $website = shift;

  if ( !$website->gone ) {
    return a(
      { href => $website->href->to_string },
      h2( $website->title ),
      p( cite( $website->cite ) ),
      blockquote( p( $website->title ) ),
    );
  }

  return div(
    h2( $website->title ),
    p( cite( $website->cite ), small('無効なリンクです') ),
    blockquote( p( $website->title ) ),
  );
}

sub apply : prototype($) {
  my $dom = shift;

  for my $item ( $dom->find('ul > li:only-child > a:only-child')->@* ) {
    my $href  = $item->getAttribute('href');
    my $title = $item->innerText;

    next if $href !~ m{^https?};

    my $website = external $title, $href;
    my $card    = cardify $website;

    my $aside = $item->tree->createElement('aside');
    $aside->attr( class => 'content__card--website' . ( $website->gone ? ' gone' : q{} ) );
    $aside->innerHTML( $card->to_string );

    $item->parent->parent->replace($aside);
  }
}

sub transform {
  my ( $class, $entry ) = @_;
  return $entry unless defined $entry->dom && $entry->dom isa 'HTML5::DOM::Element';

  my $dom = $entry->dom->clone(1);
  apply $dom;

  return $entry->clone( dom => $dom );
}

1;
