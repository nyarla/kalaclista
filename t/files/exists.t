#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use Kalaclista::Path;

my $dist = Kalaclista::Path->detect(qr{^t$})->child('public/dist');

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
    ok( -e $dist->child($fn)->path );
  }

  done_testing;
}

main;
