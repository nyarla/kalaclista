#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use HTML5::DOM;
use URI;

use Kalaclista::Directory;
use Kalaclista::Template;
use Kalaclista::Entry

    my $parser = HTML5::DOM->new( { script => 1 } );
my $dirs = Kalaclista::Directory->instance(
  build => 'resources',
  data  => 'content/data',
);

my $extension = load( $dirs->templates_dir->child('extensions/affiliate.pl') );

sub main {
  my $path  = 'posts/2022/07/24/121254';
  my $entry = Kalaclista::Entry->new( $dirs->content_dir->child("/entries/${path}.md"), URI->new("https://the.kalaclista.com/${path}/") );

  $entry->register($extension);
  $entry->transform;

  my $item = $entry->dom->at('.content__card--affiliate');

  ok( $item->at('h1 > a') );
  ok( $item->at('p > a > img') );
  ok( scalar( $item->find('ul > li > a')->@* ), 2 );

  done_testing;
}

main;
