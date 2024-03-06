package WebSite::Extensions::AdjustHeading;

use v5.38;
use utf8;

use feature qw(isa);

use Exporter::Lite;

use Kalaclista::HyperScript qw(strong raw);

our @EXPORT_OK = qw(adjust);

my %table = (
  'h1' => 'h2',
  'h2' => 'h3',
  'h3' => 'h4',
  'h4' => 'h5',
  'h5' => 'h6',
);

sub adjust : prototype($) {
  my $dom = shift;

  for my $node ( $dom->find('h1, h2, h3, h4, h5, h6')->@* ) {
    if ( $node->tag ne q{h6} ) {
      $node->tag( $table{ $node->tag } );
      next;
    }

    my $new = $node->tree->createElement('p');
    $new->innerHTML( strong( raw( $node->innerHTML ) )->to_string );

    $node->replace($new);
  }
}

sub transform {
  my ( $class, $entry ) = @_;

  if ( defined $entry->dom && $entry->dom isa 'HTML5::DOM::Element' ) {
    my $dom = $entry->dom->clone(1);
    adjust $dom;

    return $entry->clone( dom => $dom );
  }

  return $entry;
}

1;
