#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;

use HTML5::DOM;
use URI::Fast;

use Kalaclista::Entry;

use WebSite::Extensions::Affiliate;
use WebSite::Context;

my $instance = WebSite::Context->init(qr{^t$});

sub main {
  my $path  = 'posts/2022/07/24/121254';
  my $entry = Kalaclista::Entry->new(
    src => $instance->entries->parent->child("precompiled/${path}.md")->get,
  );

  $entry->add_transformer( sub { WebSite::Extensions::Affiliate->transform(@_) } );
  $entry->transform;

  my $item = $entry->dom->at('.content__card--affiliate');

  ok( $item->at('h2 > a') );
  ok( scalar( $item->find('ul > li > a')->@* ), 2 );

  done_testing;
}

main;
