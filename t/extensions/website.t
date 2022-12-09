#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use URI::Fast;

BEGIN {
  use Kalaclista::Constants;
  Kalaclista::Constants->rootdir(qr{^t$});
}

use Kalaclista::Entry;

use WebSite::Extensions::WebSite;

my $rootdir = Kalaclista::Path->detect(qr{^t$});
my $content = $rootdir->child("content/entries");

sub main {
  my $path  = 'notes/NERDFonts';
  my $entry = Kalaclista::Entry->new(
    $content->child("${path}.md")->path,
    URI::Fast->new("https://the.kalaclista.com/${path}/"),
  );

  $entry->register( sub { WebSite::Extensions::WebSite->transform(@_) } );
  $entry->transform;

  my $item = $entry->dom->at('.content__card--website');

  is( $item->at('a')->getAttribute('href'), "https://www.nerdfonts.com/" );

  ok( $item->at('a > h1') );
  ok( $item->at('a > p') );
  ok( $item->at('a > blockquote') );

  done_testing;
}

main;
