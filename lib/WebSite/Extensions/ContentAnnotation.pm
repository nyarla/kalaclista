package WebSite::Extensions::ContentAnnotation;

use v5.38;
use utf8;

use feature qw(isa);

use Exporter::Lite;

our @EXPORT_OK = qw(annotate);

sub annotate : prototype($) {
  my $dom = shift;

  for my $block ( $dom->find('blockquote')->@* ) {
    next if ( $block->textContent !~ m/\[\![^\]]+\]/ );

    my $firstline = $block->at('*:first-child');
    my $afters    = $block->find('*:first-child ~ *');

    my ( $kind, $content ) = $firstline->innerHTML =~ m|\[\!([^\]]+)\]\n(.+)|;
    $firstline->innerHTML($content);

    my $replace = $block->tree->createElement('section');
    $replace->classList->add( qw(annotated), lc $kind );
    $replace->appendChild($firstline);
    $replace->appendChild($_) for $afters->@*;

    $block->replace($replace);
  }
}

sub transform {
  my ( $class, $entry ) = @_;
  return $entry unless defined $entry->dom && $entry->dom isa 'HTML5::DOM::Element';

  my $dom = $entry->dom->clone(1);

  annotate $dom;

  return $entry->clone( dom => $dom );
}

1;
