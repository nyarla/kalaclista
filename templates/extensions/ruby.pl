no warnings 'redefine';

sub ruby {
  my $src  = shift;
  my @text = split qr([|]), $src;

  my $rb = shift @text;
  if ( @text == 1 ) {
    return qq(<ruby>$rb<rt>@text</rt></ruby>);
  }

  my @rb  = split qr{}, $rb;
  my $out = q{};
  while ( @rb > 0 ) {
    my $t = shift @rb;
    my $r = shift @text // q{};

    $out .= qq{$t<rp>（</rp><rt>$r</rt><rp>）</rp>};
  }

  return "<ruby>${out}</ruby>";
}

use warnings 'redefine';

my $extension = sub {
  my $meta = shift;
  return sub {
    my $dom = shift;

    for my $node ( $dom->find('h1, h2, h3, h4, h5, h6, p, li, dt, dd')->@* ) {
      my $html = $node->innerHTML;
      $html =~ s<[{]([^}]+)[}]><ruby($1)>eg;

      $node->innerHTML($html);
    }
  };
};

$extension;
