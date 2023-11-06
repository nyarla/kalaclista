package WebSite::Extensions::CodeSyntax;

use strict;
use warnings;
use utf8;

use feature qw(state);

use YAML::XS ();

use WebSite::Context;

sub transform {
  state $datadir ||= WebSite::Context->instance->dirs->rootdir->child('content/data/highlight');
  my ( $class, $entry ) = @_;

  my $href = $entry->href->path;
  my $idx  = 0;

  for my $block ( $entry->dom->find('pre > code')->@* ) {
    $idx++;
    my $file = $datadir->child("${href}${idx}.yaml");
    if ( -f $file->path ) {
      my $data = YAML::XS::LoadFile( $file->path );

      if ( !ref $entry->meta('css') ) {
        $entry->meta( css => [] );
      }

      push $entry->meta('css')->@*, $data->{'style'};

      $block->innerHTML( $data->{'code'} );

      for my $node ( $block->find('a')->@* ) {
        my $text = $node->tree->createTextNode( $node->textContent );
        $node->replace($text);
      }
    }
  }

  return $entry;
}

1;
