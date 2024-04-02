#!/usr/bin/env perl

use v5.38;
use utf8;

use feature qw(state);

use Test2::V0;

use YAML::XS qw(DumpFile LoadFile);

use WebSite::Context::Environment qw(env);
use WebSite::Context::Path        qw(distdir srcdir cachedir);

my sub src   { state $dir ||= srcdir->child('images');   $dir }
my sub dist  { state $dir ||= distdir->child('images');  $dir }
my sub cache { state $dir ||= cachedir->child('images'); $dir }

sub splitpath {
  my $path = shift;
  my $root = shift;

  my $dirname  = $path->parent->to_string;
  my $basename = $path->to_string;

  my $prefix = $root->to_string;

  $dirname  =~ s|$prefix/||;
  $basename =~ s|$prefix/$dirname/||;
  $basename =~ s{\.[^.]+$}{};

  return ( $dirname, $basename );
}

sub getSize {
  my $path = (shift)->to_string;
  die "No such file or directory: ${path}" if !-e $path;

  my $size = `identify '${path}' | head -n1 | cut -d' ' -f3`;
  chomp($size);

  my ( $width, $height ) = split qr/x/, $size;
  return ( int($width), int($height) );
}

sub mkWebP {
  my $path  = shift;
  my $scale = shift;
  my $size  = shift;

  my ( $width, undef ) = getSize($path);
  my ( $dirname, $basename ) = splitpath( $path, src );

  my $dist = dist->child("${dirname}/${basename}_${scale}.webp");
  $dist->parent->mkpath;

  my $cmd = join q{ }, (
    "cwebp",
    ( $width >= $size ? ( '-resize', $size, 0 ) : () ),
    qw(-q 100), $path->to_string, '-o', $dist->to_string,
    '2>&1', '|', q(grep 'Dimension' | cut -d' ' -f4),
  );

  my $height = `${cmd}`;
  chomp($height);

  return ( $size, $height );
}

sub copyGif {
  my $path  = shift;
  my $scale = shift;

  my ( $dirname, $basename ) = splitpath( $path, src );

  my $dist = dist->child("${dirname}/${basename}_${scale}.gif");
  $dist->parent->mkpath;

  system( q|cp|, $path->to_string, $dist->to_string );
}

sub doing {
  my $path = src->child(shift);
  my $x1   = shift;
  my $x2   = shift;

  my ( $width, $height );
  my $meta = {};
  if ( $path->to_string !~ m{\.gif$} ) {
    ( $width, $height ) = mkWebP( $path, '1x', $x1 );
    $meta->{'1x'} = { width => $width, height => $height };

    ( $width, $height ) = mkWebP( $path, '2x', $x2 );
    $meta->{'2x'} = { width => $width, height => $height };
  }
  else {
    ( $width, $height ) = getSize($path);
    copyGif( $path, '1x' );
    copyGif( $path, '2x' );

    $meta->{'1x'}  = { width => $width, height => $height };
    $meta->{'2x'}  = { width => $width, height => $height };
    $meta->{'gif'} = { width => $width, height => $height };
  }

  my ( $dirname, $basename ) = splitpath( $path, src );
  my $cache = cache->child("${dirname}/${basename}.yaml");
  $cache->parent->mkpath;

  DumpFile( $cache->path, $meta );

  return 0;
}

sub testing {
  subtest splitpath => sub {
    my $path = Kalaclista::Path->new( path => '/path/to/dir/name.png' );
    my $root = Kalaclista::Path->new( path => '/path/to' );

    is [ splitpath( $path, $root ) ], [qw/dir name/];
  };

  subtest getSize => sub {
    env->production && subtest production => sub {
      subtest jpg => sub {
        my $path = src->child('posts/2023/08/15/162025/1.jpg');
        my ( $width, $height ) = getSize($path);

        is $width,  8160;
        is $height, 6120;
      };

      subtest gif => sub {
        my $path = src->child('posts/2015/09/01/003355/1.gif');
        my ( $width, $height ) = getSize($path);

        is $width,  256;
        is $height, 256;
      };
    };

    env->test && subtest test => sub {
      subtest png => sub {
        my $path = src->child('foo/bar/1.png');
        my ( $width, $height ) = getSize($path);

        is $width,  2048;
        is $height, 2048;
      };

      subtest gif => sub {
        my $path = src->child('foo/bar/2.gif');
        my ( $width, $height ) = getSize($path);

        is $width,  256;
        is $height, 256;
      };
    };
  };

  subtest mkWebP => sub {
    env->production && subtest test => sub {
      my $path = src->child('posts/2023/08/15/162025/1.jpg');
      my ( $width, $height ) = mkWebP( $path, '1x', 640 );

      is $width,  640;
      is $height, 480;

      my ( $dirname, $basename ) = splitpath( $path, src );
      my $dist = dist->child("${dirname}/${basename}_1x.webp");

      ok -e $dist->path;
      like $dist->path, qr{public/production/images/posts/2023/08/15/162025/};
    };

    env->test && subtest test => sub {
      my $path = src->child('foo/bar/1.png');
      my ( $width, $height ) = mkWebP( $path, '1x', 640 );

      is $width,  640;
      is $height, 640;

      my ( $dirname, $basename ) = splitpath( $path, src );
      my $dist = dist->child("${dirname}/${basename}_1x.webp");

      ok -e $dist->path;
      like $dist->path, qr{public/test/images/foo/bar/};
    };
  };

  subtest copyGif => sub {
    env->production && subtest production => sub {
      my $path = src->child('posts/2015/09/01/003355/1.gif');
      copyGif( $path, '1x' );

      my $dist = dist->child('posts/2015/09/01/003355/1_1x.gif');
      ok -e $dist->path;
    };

    env->test && subtest test => sub {
      my $path = src->child('foo/bar/2.gif');
      copyGif( $path, '1x' );

      my $dist = dist->child('foo/bar/2_1x.gif');
      ok -e $dist->path;
      like $dist->path, qr{public/test/images/foo/bar/};
    };
  };

  subtest doing => sub {
    env->production && subtest png => sub {
      doing( 'posts/2023/08/15/162025/1.jpg', 640, 1280 );

      ok -e dist->child('posts/2023/08/15/162025/1_1x.webp')->path;
      ok -e dist->child('posts/2023/08/15/162025/1_2x.webp')->path;

      is LoadFile( cache->child('posts/2023/08/15/162025/1.yaml')->path ), {
        '1x' => { width => 640,  height => 480 },
        '2x' => { width => 1280, height => 960 },
      };

      doing( 'posts/2015/09/01/003355/1.gif', 640, 1280 );

      ok -e dist->child('posts/2015/09/01/003355/1_1x.gif')->path;
      ok -e dist->child('posts/2015/09/01/003355/1_1x.gif')->path;

      is LoadFile( cache->child('posts/2015/09/01/003355/1.yaml')->path ), {
        '1x'  => { width => 256, height => 256 },
        '2x'  => { width => 256, height => 256 },
        'gif' => { width => 256, height => 256 },
      };
    };

    env->test && subtest png => sub {
      doing( 'foo/bar/1.png', 640, 1280 );

      ok -e dist->child('foo/bar/1_1x.webp')->path;
      ok -e dist->child('foo/bar/1_2x.webp')->path;

      is LoadFile( cache->child('foo/bar/1.yaml')->path ), {
        '1x' => { width => 640,  height => 640 },
        '2x' => { width => 1280, height => 1280 },
      };

      doing( 'foo/bar/2.gif', 640, 1280 );

      ok -e dist->child('foo/bar/2_1x.gif')->path;
      ok -e dist->child('foo/bar/2_2x.gif')->path;

      is LoadFile( cache->child('foo/bar/2.yaml')->path ), {
        '1x'  => { width => 256, height => 256 },
        '2x'  => { width => 256, height => 256 },
        'gif' => { width => 256, height => 256 },
      };
    };
  };

  done_testing;

  return 0;
}

sub main {
  exit( !exists $ENV{'HARNESS_ACTIVE'} ? doing(@ARGV) : testing );
}

main(@ARGV);
