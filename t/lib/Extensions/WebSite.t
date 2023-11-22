#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use URI::Fast;

use Kalaclista::Entry;

use WebSite::Context;
use WebSite::Extensions::WebSite;

my $context = WebSite::Context->init(qr{^t$});

sub main {
  my $path  = 'notes/NERDFonts';
  my $entry = Kalaclista::Entry->new(
    src  => $context->entries->parent->child("precompiled/${path}.md")->get,
    href => URI::Fast->new("https://the.kalaclista.com/${path}/"),
  );

  $entry->add_transformer( sub { WebSite::Extensions::WebSite->transform(@_) } );
  $entry->transform;

  my $item = $entry->dom->at('.content__card--website');

  is( $item->at('a')->getAttribute('href'), "https://www.nerdfonts.com/" );

  ok( $item->at('a > h2') );
  ok( $item->at('a > p') );
  ok( $item->at('a > blockquote') );

  done_testing;
}

main;
