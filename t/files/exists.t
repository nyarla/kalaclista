#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use Kalaclista::Directory;

my $dist = Kalaclista::Directory->new->rootdir->child("dist/public");

sub main {
  my @files = qw(
    ads.txt
    apple-touch-icon.png
    assets/avatar.png
    assets/avatar.svg
    favicon.ico
    icon-192.png
    icon-512.png
    icon.svg
    manifest.webmanifest
  );

  for my $fn (@files) {
    ok( $dist->child($fn)->is_file );
  }

  done_testing;
}

main;
