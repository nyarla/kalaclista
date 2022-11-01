use strict;
use warnings;
use utf8;

use Kalaclista::Directory;
use YAML::XS ();

my $dir = Kalaclista::Directory->instance->datadir;

my $extension = sub {
  my ( $entry, $dom ) = @_;

  my $href = $entry->href->path;
  my $idx  = 0;

  for my $block ( $dom->find('pre > code')->@* ) {
    $idx++;
    my $file = $dir->child("highlight${href}${idx}.yaml");
    if ( $file->is_file ) {
      my $data = YAML::XS::Load( $file->slurp );

      push $entry->addon('style')->@*, $data->{'style'};
      $block->innerHTML( $data->{'code'} );
    }
  }
};

$extension;
