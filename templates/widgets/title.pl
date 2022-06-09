my $title = sub {
  my $vars    = shift;
  my $baseURI = shift;

  my $href =
    sub { my $link = $baseURI->clone; $link->path( $_[0] ); $link->as_string };

  return header( { id => 'global' },
    p( a( { href => $href->('/') }, "カラクリスタ" ) ) );
};

$title;
