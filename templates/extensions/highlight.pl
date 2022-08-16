use Kalaclista::Directory;
use YAML::Tiny ();

my $dir = Kalaclista::Directory->instance->datadir;

my $extension = sub {
  my $meta = shift;
  my $href = $meta->href->path;

  return sub {
    my $dom = shift;

    my $idx = 0;
    for my $block ( $dom->find('pre > code')->@* ) {
      $idx++;
      my $file = $dir->child("highlight${href}${idx}.yaml");
      if ( $file->is_file ) {
        my $data = YAML::Tiny::Load( $file->slurp_utf8 );

        $meta->addon->{'style'} //= [];
        push $meta->addon->{'style'}->@*, $data->{'style'};

        $block->innerHTML( $data->{'code'} );
      }
    }
  };
};

$extension;
