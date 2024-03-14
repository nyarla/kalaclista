package WebSite::Extensions::CodeHighlight;

use v5.38;
use utf8;

use feature qw(isa);

use Exporter::Lite;
use YAML::XS qw(LoadFile);

use WebSite::Context::Path qw(srcdir);

our @EXPORT_OK = qw(apply);

my sub load : prototype($) {
  my $path = srcdir->child('entries/code')->child(shift)->path;
  return undef if !-e $path;
  return LoadFile($path);
}

sub apply : prototype($$$) {
  my ( $path, $meta, $dom ) = @_;
  my $idx = 1;

  for my $block ( $dom->find('pre > code[class]')->@* ) {
    my $file = $path;
    $file =~ s|\.md$|/${idx}.yml|;

    my $data = load $file;
    next if !defined $data;

    # append stylesheet to entry metadata
    $meta->{'css'} //= [];
    push $meta->{'css'}->@*, $data->{'style'};

    # replace html code
    $block->innerHTML( $data->{'highlight'} );

    # remove to hyperlink from code block
    for my $node ( $block->find('a')->@* ) {
      $node->innerHTML( $node->textContent );
    }

    $idx++;
  }
}

sub transform {
  my ( $class, $entry ) = @_;
  return $entry unless defined $entry->dom && $entry->dom isa 'HTML5::DOM::Element';

  my $path = $entry->meta->{'path'};
  my $meta = {};
  my $dom  = $entry->dom->clone(1);

  apply $path, $meta, $dom;

  return $entry->clone(
    meta => $meta,
    dom  => $dom,
  );
}

1;
