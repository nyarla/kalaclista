#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;

use Kalaclista::Files;
use WebSite::Context;

my $c = WebSite::Context->init(qr{^t$});

my $src  = $c->src('images');
my $dist = $c->dist('images');

subtest compiled => sub {
  my $prefix = $src->path;
  my @files  = Kalaclista::Files->find($prefix);

  for my $file (@files) {
    $file =~ s{$prefix/}{};
    next if $file =~ m{^\.git};

    my ( $path, $ext ) = ( $file =~ m{(.+)\.([^.]+)$} );

    if ( $ext eq 'gif' ) {
      ok !-e $dist->child("${path}_1x.webp")->path, $file;
      ok !-e $dist->child("${path}_2x.webp")->path, $file;
      next;
    }

    ok -e $dist->child("${path}_1x.webp")->path, $file;
    ok -e $dist->child("${path}_2x.webp")->path, $file;
  }
};

done_testing;
