package WebSite::Extensions::Products;

use v5.38;
use utf8;

use feature qw(isa);

use Exporter::Lite;

use Kalaclista::HyperScript qw(h2 ul li a raw);

use WebSite::Context::Path qw(srcdir);
use WebSite::Loader::Products;

BEGIN {
  WebSite::Loader::Products->init( srcdir->child('data/products.csv')->to_string );
}

our @EXPORT_OK = qw( cardify linkify apply);

## TODO: add support to thumbnail image
sub cardify : prototype($) {
  my $data = shift;
  my $html = q{};

  if ( $data->description->[0]->gone ) {
    $html .= h2( $data->title );
    $html .= ul( li('この商品の取り扱いは終了しました') );

    return $html;
  }

  $html .= h2( a( { href => $data->description->[0]->href->to_string }, $data->title ) );
  $html .= ul( map { linkify($_) } $data->description->@* );

  return $html;
}

sub linkify : prototype($) {
  my $link = shift;

  if ( $link->href->host eq 'amzn.to' ) {
    return li( { class => 'amazon' }, a( { href => $link->href->to_string }, 'Amazon.co.jp で探す' ) );
  }

  if ( $link->href->host eq 'a.r10.to' ) {
    return li( { class => 'rakuten' }, a( { href => $link->href->to_string }, '楽天で探す' ) );
  }

  return ();
}

sub apply : prototype($) {
  my $dom = shift;

  for my $item ( $dom->find('p > a:only-child')->@* ) {
    unless ( $item->parent->firstChild->isSameNode($item)
      && $item->parent->lastChild->isSameNode($item) ) {
      next;
    }

    my $product = product $item->textContent;
    next if !defined $product;

    my $html = cardify $product;

    my $aside = $item->tree->createElement('aside');
    $aside->attr( class => 'content__card--affiliate' );
    $aside->innerHTML($html);

    $item->parent->replace($aside);
  }
}

sub transform {
  my ( $class, $entry ) = @_;

  if ( defined $entry->dom && $entry->dom isa 'HTML5::DOM::Element' ) {
    my $dom = $entry->dom->clone(1);
    apply $dom;

    return $entry->clone( dom => $dom );
  }

  return $entry;
}

1;
