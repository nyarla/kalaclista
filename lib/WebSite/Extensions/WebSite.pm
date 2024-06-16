package WebSite::Extensions::WebSite;

use v5.38;
use utf8;

use feature qw(isa);

use Exporter::Lite;

use Kalaclista::HyperScript qw(a div h2 p blockquote img cite small classes);

use WebSite::Context::Path   qw(srcdir);
use WebSite::Loader::WebSite qw(external);

BEGIN {
  WebSite::Loader::WebSite->init( srcdir->child('data/website.csv')->to_string );
}

our @EXPORT_OK = qw(cardify apply);

sub cardify : prototype($) {
  my $website = shift;

  if ( !$website->gone ) {
    my $domain  = $website->href->host;
    my $favicon = img(
      classes(qw|u-logo logo|),
      {
        src    => "https://www.google.com/s2/favicons?domain=${domain}&sz=32",
        width  => 16,
        height => 16,
        alt    => '',
      }
    );

    return a(
      classes(qw|u-url url|),
      { href => $website->href->to_string },
      h2( classes(qw|p-name fn|), $website->title ),
      p( $favicon, cite( $website->cite ) ),
    );
  }

  return div(
    h2( classes(qw|pname fn|), $website->title ),
    p( cite( $website->cite ), small('無効なリンクです') ),
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
    $aside->attr( class => 'content__card--website h-card vcard' . ( $website->gone ? ' gone' : q{} ) );
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
