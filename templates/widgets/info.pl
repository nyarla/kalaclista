my $info = sub {
  my $vars    = shift;
  my $baseURI = shift;

  my $href =
    sub { my $link = $baseURI->clone; $link->path( $_[0] ); $link->as_string };

  return footer(
    { id => 'copyright' },
    p(
      "(C) 2006-2022 ",
      a( { href => $href->('/nyarla/') }, 'OKAMURA Naoki aka nyarla' )
    )
  );
};

$info;
