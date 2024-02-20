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

  my $item = $entry->dom->at('.h-item');

  is( $item->at('a')->getAttribute('href'), "https://www.nerdfonts.com/" );

  is scalar( $item->find('a > p')->@* ), 2;

  done_testing;
}

main;
