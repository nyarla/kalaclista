package WebSite::Extensions::AdjustHeading;

use strict;
use warnings;
use utf8;

my %table = (
  'h1' => 'h2',
  'h2' => 'h3',
  'h3' => 'h4',
  'h4' => 'h5',
  'h5' => 'h6',
);

sub transform {
  my ( $class, $entry ) = @_;

  for my $node ( $entry->dom->find('h1, h2, h3, h4, h5, h6')->@* ) {
    if ( $node->tag ne 'h6' ) {
      my $tag = $table{ $node->tag };
      $node->tag($tag);
    }
    else {
      my $strong = $node->tree->createElement('strong');
      $strong->innerHTML( $node->innerHTML );
      my $new = $node->tree->createElement('p');
      $new->appendChild($strong);
      $node->replace($new);
    }
  }

  return $entry;
}

1;
