package WebSite::Extensions::Products;

use v5.38;
use utf8;

use feature qw(isa);

use Exporter::Lite;

use Kalaclista::HyperScript qw(h2 div ul li a raw classes);

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
    $html .= h2( classes(qw|p-name fn|), $data->title );
    $html .= ul( li('この商品の取り扱いは終了しました') );

    return $html;
  }

  my $margin;

  $html .= h2( a( classes(qw|p-name fn u-url url|), { href => $data->description->[0]->href->to_string }, $data->title ) );

  if ( defined $data->thumbnail && $data->thumbnail ne q{} ) {
    $html .= div(
      classes(qw|[&>a>img]:!m-0 [&>a>img]:rounded-sm [&>a>img]:border-2 float-none my-4 sm:float-right sm:-mt-8 sm:my-0|),
      raw( $data->thumbnail )
    );
  }

  $html .= ul( map { linkify($_) } $data->description->@* );

  return $html;
}

sub linkify : prototype($) {
  my $link = shift;

  if ( $link->href->host eq 'amzn.to' ) {
    return li( classes(qw|u-url url p-name fn amazon|), a( { href => $link->href->to_string }, 'Amazon.co.jp で探す' ) );
  }

  if ( $link->href->host eq 'a.r10.to' ) {
    return li( classes(qw|u-url url p-name fn rakuten|), a( { href => $link->href->to_string }, '楽天で探す' ) );
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
    $aside->attr( class => 'content__card--affiliate h-product hproduct' );
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
