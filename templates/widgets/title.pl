my $title = sub {
  my $baseURI = shift;

  return header(
    { id => 'global' },
    p( a( { href => href( '/', $baseURI ) }, "カラクリスタ" ) )
  );
};

$title;
