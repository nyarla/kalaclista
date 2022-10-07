use Kalaclista::Directory;
use YAML::Tiny ();

my $dir = Kalaclista::Directory->instance->datadir;

my $extension = sub {
  my ( $entry, $dom ) = @_;

  my $href = $entry->href->path;
  my $idx  = 0;

  for my $block ( $dom->find('pre > code')->@* ) {
    $idx++;
    my $file = $dir->child("highlight${href}${idx}.yaml");
    if ( $file->is_file ) {
      my $data = YAML::Tiny::Load( $file->slurp_utf8 );

      push $entry->addon('style')->@*, $data->{'style'};
      $block->innerHTML( $data->{'code'} );
    }
  }
};

$extension;
