#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use URI::Fast;

use Kalaclista::Entry;

use WebSite::Extensions::CodeSyntax;
use WebSite::Context;

WebSite::Context->init(qr{^t$});

sub main {
  my $path  = 'posts/2021/11/01/121434';
  my $entry = Kalaclista::Entry->new(
    WebSite::Context->instance->dirs->src("entries/src/${path}.md")->path,
    URI::Fast->new("https://the.kalaclista.com/${path}/"),
  );

  $entry->register( sub { WebSite::Extensions::CodeSyntax->transform(@_) } );
  $entry->transform;

  my $item = $entry->dom->at('pre > code');

  ok( $item->at('span.Statement') );
  is( ref $entry->addon('style'), 'ARRAY' );

  done_testing;
}

main;
