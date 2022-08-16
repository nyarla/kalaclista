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

my $extension = load( $dirs->templates_dir->child('extensions/highlight.pl') );

sub main {
  my $path = 'posts/2021/11/01/121434';
  my $meta = Kalaclista::Entry::Meta->load(
    src  => $dirs->build_dir->child("contents/${path}.yaml"),
    href => URI->new("https://the.kalaclista.com/${path}/"),
  );
  my $content = Kalaclista::Entry::Content->load(
    src => $dirs->build_dir->child("contents/${path}.md"), );

  my $transformer = $extension->($meta);
  $content->transform($transformer);

  my $item = $content->dom->at('pre > code');

  ok( $item->at('span.Statement') );
  is( ref $meta->addon->{'style'}, 'ARRAY' );

  done_testing;
}

main;
