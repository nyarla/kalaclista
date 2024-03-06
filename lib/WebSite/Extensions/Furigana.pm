package WebSite::Extensions::Furigana;

use v5.38;
use utf8;

use Exporter::Lite;

our @EXPORT_OK = qw(furigana apply);

sub furigana : prototype($) {
  my $src = shift;
  $src =~ s{​}{}g;

  my @text = split qr([|]), $src;

  my $rb = shift @text;
  if ( @text == 1 ) {
    return qq|<ruby>$rb<rt>@text</rt></ruby>|;
  }

  my @rb = split qr{}, $rb;
  my $out;
  while ( @rb > 0 ) {
    my $t = shift @rb;
    my $r = shift @text // q{};

    $out .= qq|$t<rp>（</rp><rt>$r</rt><rp>）</rp>|;
  }

  return qq|<ruby>${out}</ruby>|;
}

sub apply {
  my $dom = shift;

  for my $node ( $dom->find('h1, h2, h3, h4, h5, h6, p, li, dt, dd')->@* ) {
    my $html = $node->innerHTML;
    $html =~ s<[{]([^}]+)[}]><furigana($1)>eg;

    $node->innerHTML($html);
  }
}

sub transform {
  my ( $class, $entry ) = @_;

  if ( defined $entry->dom && $entry->dom isa 'HTML5::DOM::Element' ) {
    my $dom = $entry->dom->clone(1);
    apply($dom);

    return $entry->clone( dom => $dom );
  }

  return $entry;
}

1;
