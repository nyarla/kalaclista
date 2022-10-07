#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use URI;

use Kalaclista::Directory;
use Kalaclista::Template;
use Kalaclista::Entry;

my $dirs = Kalaclista::Directory->instance(
  build => 'resources',
  data  => 'content/data',
);

my $extension = load( $dirs->templates_dir->child('extensions/website.pl') );

sub main {
  my $path  = 'notes/NERDFonts';
  my $entry = Kalaclista::Entry->new( $dirs->content_dir->child("entries/${path}.md"), URI->new("https://the.kalaclista.com/${path}/") );

  $entry->register($extension);
  $entry->transform;

  my $item = $entry->dom->at('.content__card--website');

  is( $item->at('a')->getAttribute('href'), "https://www.nerdfonts.com/" );

  ok( $item->at('a > h1') );
  ok( $item->at('a > p') );
  ok( $item->at('a > blockquote') );

  done_testing;
}

main;
