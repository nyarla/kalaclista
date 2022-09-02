#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use URI;

use Kalaclista::Directory;
use Kalaclista::Template;
use Kalaclista::Entry::Meta;
use Kalaclista::Entry::Content;

my $dirs = Kalaclista::Directory->instance(
  build => 'resources',
  data  => 'content/data',
);

my $extension = load( $dirs->templates_dir->child('extensions/website.pl') );

sub main {
  my $path = 'notes/NERDFonts';
  my $meta = Kalaclista::Entry::Meta->load(
    src  => $dirs->build_dir->child("contents/${path}.yaml"),
    href => URI->new("https://the.kalaclista.com/${path}/"),
  );

  my $content = Kalaclista::Entry::Content->load(
    src => $dirs->build_dir->child("contents/${path}.md"), );

  my $transformer = $extension->($meta);
  $content->transform($transformer);

  my $item = $content->dom->at('.content__card--website');

  is( $item->at('a')->getAttribute('href'), "https://www.nerdfonts.com/" );

  ok( $item->at('a > h1') );
  ok( $item->at('a > p') );
  ok( $item->at('a > blockquote') );

  done_testing;
}

main;
