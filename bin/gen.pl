#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Module::Load qw(load);

use Kalaclista::Constants;
use Kalaclista::Entries;
use Kalaclista::Path;

my %generators = (
  'images'      => 'Kalaclista::Generators::WebP',
  'sitemap.xml' => 'Kalaclista::Generators::SitemapXML',
);

my $const = 'Kalaclista::Constants';

sub init {
  $const->baseURI( $ENV{'URL'} // 'https://the.kalaclista.com' );
  $const->rootdir(qr{^bin$});
}

sub main {
  my $action = shift;

  my $contents = $const->rootdir->child('content/entries');
  my $datadir  = $const->rootdir->child('content/data');
  my $distdir  = $const->rootdir->child('dist2/public');
  my $images   = $const->rootdir->child('content/assets/images');

  my $entries = Kalaclista::Entries->instance( $contents->path );

  if ( $action eq 'sitemap.xml' ) {
    my $class = $generators{$action};
    load($class);

    return $class->generate(
      path => $distdir->child('sitemap.xml'),
      src  => $entries,
    );
  }

  if ( $action eq 'images' ) {
    my $class = $generators{$action};
    load($class);

    return $class->generate(
      distdir => $distdir->child('images'),
      images  => $images,
      datadir => $datadir->child('pictures'),
      scales  => [ [ '1x', 700 ], [ '2x', 1400 ] ],
    );
  }

  return 1;
}

local $@;
eval {
  init;
  main(@ARGV);
};

if ($@) {
  die "application failed: ${@}";
}

exit 0;
