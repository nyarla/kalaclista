package WebSite::Extensions::CodeSyntax;

use strict;
use warnings;
use utf8;

use feature qw(state);

use YAML::XS ();

use WebSite::Context;

sub transform {
  state $prefix  ||= WebSite::Context->instance->entries->path;
  state $datadir ||= WebSite::Context->instance->entries->parent->child('code');
  my ( $class, $entry ) = @_;

  my $path = $entry->path->path;
  my $idx  = 1;

  for my $block ( $entry->dom->find('pre > code')->@* ) {
    my $file = $path;

    $file =~ s<^$prefix/><>;
    $file =~ s<\.md$></${idx}.yml>;
    $file = $datadir->child($file)->path;

    if ( -f $file ) {
      my $data = YAML::XS::LoadFile($file);

      if ( !ref $entry->meta('css') ) {
        $entry->meta( css => [] );
      }

      push $entry->meta('css')->@*, $data->{'style'};

      $block->innerHTML( $data->{'highlight'} );

      for my $node ( $block->find('a')->@* ) {
        my $text = $node->tree->createTextNode( $node->textContent );
        $node->replace($text);
      }
    }

    $idx++;
  }

  return $entry;
}

1;
