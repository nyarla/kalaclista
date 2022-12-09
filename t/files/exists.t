#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;

use Kalaclista::Path;
use Kalaclista::Files;
use Kalaclista::Entries;
use Kalaclista::Constants;

my $content = Kalaclista::Path->detect(qr{^t$})->child('content');
my $dist    = Kalaclista::Path->detect(qr{^t$})->child('public/dist');

sub static {
  return qw(
    ads.txt
    apple-touch-icon.png
    assets/avatar.png
    assets/avatar.svg
    favicon.ico
    icon-192.png
    icon-512.png
    icon.svg
    manifest.webmanifest
    robots.txt
  );
}

sub feed {
  return qw(
    echos/index.xml
    echos/atom.xml
    echos/jsonfeed.json

    posts/index.xml
    posts/atom.xml
    posts/jsonfeed.json

    notes/index.xml
    notes/atom.xml
    notes/jsonfeed.json

    atom.xml
    index.xml
    jsonfeed.json
  );
}

sub fixup {
  my $entry = shift;

  my $path = $entry->href->path;

  if ( $entry->slug ne q{} ) {
    my $slug = $entry->slug;
    utf8::decode($slug);
    $slug =~ s{ }{-}g;
    $path = qq(/notes/${slug}/);
  }

  if ( $path =~ m{/index} ) {
    $path =~ s{/index}{/};
  }

  $entry->href->path($path);

  return $entry;
}

sub generated {
  Kalaclista::Constants->baseURI('https://example.com');

  my $entries =
      map { fixup($_) } Kalaclista::Entries->instance( $content->child('entries')->path );

  return map { $dist->child( $_->href->path . '/index.html' ) } $entries->entries->@*;
}

sub main {
  my @files = ( static, feed );

  for my $fn (@files) {
    ok( -e $dist->child($fn)->path, $dist->child($fn)->path );
  }

  done_testing;
}

main;
