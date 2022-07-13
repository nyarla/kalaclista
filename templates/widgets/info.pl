my $info = sub {
  my $baseURI = shift;

  return footer(
    { id => 'copyright' },
    p(
      "(C) 2006-2022 ",
      a( { href => href( '/nyarla/', $baseURI ) }, 'OKAMURA Naoki aka nyarla' )
    )
  );
};

$info;
