#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use URI::Fast;

use Kalaclista::Entry;

use WebSite::Helper::Hyperlink qw(href);
use WebSite::Extensions::CodeSyntax;
use WebSite::Context;

my $c = WebSite::Context->init(qr{^t$});

sub main {
  my $path  = 'posts/2021/11/01/121434';
  my $entry = Kalaclista::Entry->new(
    href => URI::Fast->new("https://the.kalaclista.com/${path}/"),
    src  => $c->entries->parent->child("precompiled/${path}.md")->get,
    path => $c->entries->child("${path}.md"),
  );

  $entry->add_transformer( sub { WebSite::Extensions::CodeSyntax->transform(@_) } );
  $entry->transform;

  my $item = $entry->dom->at('pre > code');

  ok( $item->at('span.Statement') );
  is( ref $entry->meta('css'), 'ARRAY' );

  done_testing;
}

main;
