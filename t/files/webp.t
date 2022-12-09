#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;

use Kalaclista::Path;
use Kalaclista::Files;

my $dist = Kalaclista::Path->detect(qr{^t$})->child('public/dist/images');

sub main {
  my @files = grep { $_ =~ m{\.(png|jpeg|jpg|gif)$} } Kalaclista::Files->find( $dist->path );

  for my $image (@files) {
    my $fn = ( $image =~ m{/([^/]+?)\.\w+$} )[0];

    next if ( $fn =~ m{thumb} );    # FIXME: temporary solution

    if ( $image =~ m{\.gif$} ) {
      my $path = Kalaclista::Path->new( path => $image );

      ok( !-e $path->parent->child("${fn}_1x.webp")->path );
      ok( !-e $path->parent->child("${fn}_2x.webp")->path );

      next;
    }

    my $path = Kalaclista::Path->new( path => $image );

    ok( -e $path->parent->child("${fn}_1x.webp")->path );
    ok( -e $path->parent->child("${fn}_2x.webp")->path );
  }

  done_testing;
}

main;
