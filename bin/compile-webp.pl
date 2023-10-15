#!/usr/bin/env perl

use strict;
use warnings;

use YAML::XS qw(DumpFile);

use Kalaclista::Path;

my $rootdir = Kalaclista::Path->detect(qr{^bin$});
my $dist    = $rootdir->child("public/dist/images");
my $src     = $rootdir->child("src/images");
my $data    = $rootdir->child("cache/images/data");

sub paths {
  my $path = shift;

  my $dirname  = `dirname "${path}"`;
  my $basename = `basename "${path}"`;

  chomp($dirname);
  chomp($basename);

  $basename =~ s{\.[^.]+$}{};

  return ( $dirname, $basename );
}

sub resize {
  my $path   = shift;
  my $scale  = shift;
  my $resize = shift;

  my ( $width,   $height )   = size( $src->child($path)->path );
  my ( $dirname, $basename ) = paths($path);

  my $in  = $src->child($path);
  my $out = $dist->child("${dirname}/${basename}_${scale}.webp");

  $out->parent->mkpath;

  my $cmd = join q{ }, (
    "cwebp",
    ( $width >= $resize ? ( "-resize", $resize, 0 ) : () ),
    "-q",   100, $in->path,          '-o', $out->path,
    '2>&1', '|', "grep 'Dimension'", "|",  "cut -d ' ' -f4"
  );

  $height = `${cmd}`;
  chomp($height);
  $height = int($height);

  return { width => $resize, height => $height };
}

sub size {
  my $path = shift;

  my $meta = `identify "${path}" | head -n1 | cut -d ' ' -f3`;
  chomp($meta);

  my ( $width, $height ) = split qr{x}, $meta;

  return ( int($width), int($height) );
}

sub doing {
  my $path = shift;
  my $x1   = int(shift);
  my $x2   = int(shift);

  my ( $dirname, $basename ) = paths($path);

  my $image = $src->child($path)->path;

  $dist->child($dirname)->mkpath;
  $data->child($dirname)->mkpath;

  my $meta = {};

  if ( $path =~ m{\.gif$} ) {
    my ( $width, $height ) = size($image);

    $meta->{'1x'}  = { width => $width, height => $height };
    $meta->{'2x'}  = { width => $width, height => $height };
    $meta->{'gif'} = { width => $width, height => $height };
  }
  else {
    $meta->{'1x'} = resize( $path, "1x", $x1 );
    $meta->{'2x'} = resize( $path, "2x", $x2 );
  }

  DumpFile( $data->child("${dirname}/${basename}.yaml")->path, $meta );

  return 0;
}

sub testing {
  require Test2::V0;
  "Test2::V0"->import;

  is(
    [ paths("foo/bar.jpg") ],
    ["foo", "bar"],
    '`paths` subroutine is enable to get dirname and pathname',
  );

  is(
    [ size( $src->child("posts/2023/08/15/162025/1.jpg")->path ) ],
    [ 8160, 6120 ],
    '`size` subroutine can get to width and height from image file'
  );

  is(
    resize( "posts/2023/08/15/162025/1.jpg", "1x", 600 ),
    { width => 600, height => 450 },
    '`resize` subroutine can resize to image by `cwebp`',
  );

  ok(
    try_ok(sub { doing("posts/2023/08/15/162025/1.jpg", 600, 1200); }),
    'doing main process suceed',
  );

  ok(
    (-e $data->child("posts/2023/08/15/162025/1.yaml")->path),
    'make cache data succeed by main process'
  );
  
  done_testing();
  
  return 0;
}

sub main {
  exit( !exists $ENV{'HARNESS_ACTIVE'} ? doing(@ARGV) : testing );
}

main(@ARGV);
