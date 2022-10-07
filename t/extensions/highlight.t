#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use HTML5::DOM;
use URI;

use Kalaclista::Directory;
use Kalaclista::Template;
use Kalaclista::Entry;

my $parser = HTML5::DOM->new( { script => 1 } );
my $dirs   = Kalaclista::Directory->instance(
  build => 'resources',
  data  => 'content/data',
);

my $extension = load( $dirs->templates_dir->child('extensions/highlight.pl') );

sub main {
  my $path  = 'posts/2021/11/01/121434';
  my $entry = Kalaclista::Entry->new( $dirs->content_dir->child("entries/${path}.md"), URI->new("https://the.kalaclista.com/${path}/") );

  $entry->register($extension);
  $entry->transform;

  my $item = $entry->dom->at('pre > code');

  ok( $item->at('span.Statement') );
  is( ref $entry->addon('style'), 'ARRAY' );

  done_testing;
}

main;
