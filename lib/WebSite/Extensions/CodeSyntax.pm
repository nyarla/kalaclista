package WebSite::Extensions::CodeSyntax;

use strict;
use warnings;
use utf8;

use Kalaclista::Constants;
use YAML::XS ();

my $datadir = Kalaclista::Constants->rootdir->child('content/data/highlight');

sub transform {
  my ( $class, $entry, $dom ) = @_;

  my $href = $entry->href->path;
  my $idx  = 0;

  for my $block ( $dom->find('pre > code')->@* ) {
    $idx++;
    my $file = $datadir->child("${href}${idx}.yaml");
    if ( -f $file->path ) {
      my $data = YAML::XS::LoadFile( $file->path );

      if ( !ref $entry->addon('style') ) {
        $entry->addon( style => [ $data->{'style'} ] );
      }
      else {
        push $entry->addon('style')->@*, $data->{'style'};
      }

      $block->innerHTML( $data->{'code'} );
    }
  }

  return $entry;
}

1;
