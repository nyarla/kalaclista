#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use HTML5::DOM;
use URI;

use Kalaclista::Directory;
use Kalaclista::Template;
use Kalaclista::Entry::Meta;
use Kalaclista::Entry::Content;

my $parser = HTML5::DOM->new( { script => 1 } );
my $dirs   = Kalaclista::Directory->instance(
  build => 'resources',
  data  => 'content/data',
);

my $extension = load( $dirs->templates_dir->child('extensions/affiliate.pl') );

sub transformer {
  my $path = shift;
  my $meta = Kalaclista::Entry::Meta->load(
    src  => $dirs->build_dir->child("contents/${path}.yaml"),
    href => URI->new("https://the.kalaclista.com/${path}/"),
  );

  return $extension->($meta);
}

sub main {
  my $path    = 'posts/2022/07/24/121254';
  my $content = Kalaclista::Entry::Content->load(
    src => $dirs->build_dir->child("contents/${path}.md"), );

  my $tansformer = transformer($path);

  $content->transform($tansformer);

  my $item = $content->dom->at('.content__card--affiliate');

  ok( $item->at('h1 > a') );
  ok( $item->at('p > a > img') );
  ok( scalar( $item->find('ul > li > a')->@* ), 2 );

  done_testing;
}

main;
