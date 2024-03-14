package WebSite::Extensions::Picture;

use v5.38;
use utf8;

use feature qw(isa);

use Exporter::Lite;
use YAML::XS qw(LoadFile);

use Kalaclista::HyperScript qw(img);

use WebSite::Context::Path qw(cachedir);
use WebSite::Context::URI  qw(href baseURI);

our @EXPORT_OK = qw(file src mkGif mkWebP apply);

my sub load {
  my $path = cachedir->child('images')->child(shift)->path;

  utf8::decode($path);

  return undef if !-e $path;
  return LoadFile($path);
}

sub file : prototype($$) {
  my ( $file, $idx ) = @_;
  $file =~ s{\.md$}{/${idx}.yaml};
  return $file;
}

sub src : prototype($$$$) {
  my ( $href, $idx, $scale, $extension ) = @_;
  my $link = baseURI->clone;

  my $path = $href->path;
  $path =~ s{^/|/$}{}g;

  $link->path("/images/${path}/${idx}_${scale}.${extension}");

  return $link;
}

sub mkGif : prototype($$$$) {
  my ( $title, $href, $idx, $meta ) = @_;
  return img(
    {
      alt   => $title, title => $title,
      src   => src( $href, $idx, "1x", 'gif' )->to_string,
      width => $meta->{'width'}, height => $meta->{'height'}
    }
  );
}

sub mkWebP : prototype($$$$) {
  my ( $title, $href, $idx, $meta ) = @_;

  my @sizes;
  my @srcset;

  my $default;

  for my $scale (qw(1x 2x)) {
    my $size = delete $meta->{$scale};
    next if !defined $size;

    my ( $width, $height ) = @{$size}{qw/width height/};

    push @sizes,  "(max-width: ${width}px) ${width}px";
    push @srcset, src( $href, $idx, $scale, 'webp' ) . " ${scale}";

    $default //= { width => $width, height => $height };
  }

  return img(
    {
      alt    => $title, title => $title,
      srcset => join( q|, |, @srcset ),
      sizes  => join( q|, |, @sizes ),
      src    => src( $href, $idx, "1x", 'webp' ),
      width  => $default->{width},
      height => $default->{height}
    }
  );
}

sub apply : prototype($$$) {
  my ( $path, $href, $dom ) = @_;

  for my $item ( $dom->find('p > img:only-child')->@* ) {
    my $idx = $item->attr('src');
    next if $idx !~ m{^\d+$};

    my $file = file $path, $idx;
    my $meta = load $file;
    next if !defined $meta;

    my $alt = $item->attr('alt');
    my $img =
        exists $meta->{'gif'}
        ? mkGif $alt, $href, $idx, $meta->{'gif'}
        : mkWebP $alt, $href, $idx, $meta;

    my $src   = src $href, $idx, "1x", ( exists $meta->{'gif'} ? 'gif' : 'webp' );
    my $image = $dom->tree->createElement('a');
    $image->attr( href  => $src->to_string );
    $image->attr( class => 'content__card--thumbnail' );
    $image->innerHTML("${img}");

    $item->replace($image);
  }
}

sub transform {
  my ( $class, $entry ) = @_;
  return $entry unless defined $entry->dom && $entry->dom isa 'HTML5::DOM::Element';

  my $dom  = $entry->dom->clone(1);
  my $href = $entry->href->clone;
  apply $entry->meta->{'path'}, $href, $dom;

  return $entry->clone( dom => $dom );
}

1;
