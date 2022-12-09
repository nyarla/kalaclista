#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;

use HTML5::DOM;
use URI::Fast;

BEGIN {
  use Kalaclista::Constants;
  Kalaclista::Constants->rootdir(qr{^t$});
}

use Kalaclista::Entry;

use WebSite::Extensions::Affiliate;

sub main {
  my $path  = 'posts/2022/07/24/121254';
  my $entry = Kalaclista::Entry->new(
    Kalaclista::Constants->rootdir->child("content/entries/${path}.md")->path,
    URI::Fast->new("https://the.kalaclista.com/${path}/"),
  );

  $entry->register( sub { WebSite::Extensions::Affiliate->transform(@_) } );
  $entry->transform;

  my $item = $entry->dom->at('.content__card--affiliate');

  ok( $item->at('h1 > a') );
  ok( $item->at('p > a > img') );
  ok( scalar( $item->find('ul > li > a')->@* ), 2 );

  done_testing;
}

main;
