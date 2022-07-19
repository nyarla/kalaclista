#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use HTML5::DOM;
use URI;
use URI::Escape qw(uri_escape_utf8);

use Kalaclista::Directory;
use Kalaclista::Template;
use Kalaclista::Entry::Meta;
use Kalaclista::Entry::Content;

my $parser = HTML5::DOM->new( { script => 1 } );
my $dirs   = Kalaclista::Directory->instance(
  build => 'resources',
  data  => 'content/data',
);
my $path = '/posts/2022/03/09/184033';

$ENV{'URL'} = 'https://the.kalaclista.com';

my $extension = load( $dirs->templates_dir->child('extensions/images.pl') );

sub transformter {
  my $path = shift;
  my $meta = Kalaclista::Entry::Meta->load(
    src  => $dirs->build_dir->child("${path}.yaml"),
    href => URI->new("https://the.kalaclista.com/${path}/"),
  );

  return $extension->($meta);
}

subtest origin => sub {
  my $path    = 'posts/2022/03/09/184033';
  my $content = Kalaclista::Entry::Content->load(
    src => $dirs->build_dir->child("${path}.md"), );

  my $transformer = transformter($path);

  $content->transform($transformer);

  my $item = $content->dom->at('.entry__card--thumbnail');

  is(
    $item->getAttribute('href'),
    "https://the.kalaclista.com/images/${path}/1.png",
  );

  is( $item->at('img')->getAttribute('height'), 582 );
  is( $item->at('img')->getAttribute('width'),  581 );

  is(
    $item->at('img')->getAttribute('src'),
    "https://the.kalaclista.com/images/${path}/1.png",
  );

  ok( !$item->at('img')->getAttribute('srcset') );

  done_testing;
};

subtest x1 => sub {
  my $path    = 'posts/2013/06/28/002453';
  my $content = Kalaclista::Entry::Content->load(
    src => $dirs->build_dir->child("$path.md") );

  my $transformer = transformter($path);
  $content->transform($transformer);

  my $item = $content->dom->at('.entry__card--thumbnail');

  is(
    $item->getAttribute('href'),
    "https://the.kalaclista.com/images/${path}/1.jpg",
  );

  is( $item->at('img')->getAttribute('height'), 449 );
  is( $item->at('img')->getAttribute('width'),  700 );

  is(
    $item->at('img')->getAttribute('src'),
    "https://the.kalaclista.com/images/${path}/1_thumb_1x.png",
  );

  is(
    $item->at('img')->getAttribute('srcset'),
'https://the.kalaclista.com/images/posts/2013/06/28/002453/1_thumb_1x.png 1x',
  );

  done_testing;
};

subtest x2 => sub {
  my $path    = '自作キーボード';
  my $content = Kalaclista::Entry::Content->load(
    src => $dirs->build_dir->child("notes/$path.md") );

  my $transformer = transformter("notes/$path");
  $content->transform($transformer);

  my $item = $content->dom->at('.entry__card--thumbnail');

  is(
    $item->getAttribute('href'),
"https://the.kalaclista.com/images/notes/@{[ uri_escape_utf8($path) ]}/1.jpg",
  );

  is( $item->at('img')->getAttribute('height'), 315 );
  is( $item->at('img')->getAttribute('width'),  700 );

  is(
    $item->at('img')->getAttribute('src'),
    "https://the.kalaclista.com/images/notes/$path/1_thumb_1x.png",
  );

  is( $item->at('img')->getAttribute('srcset'),
qq{https://the.kalaclista.com/images/notes/$path/1_thumb_2x.png 2x, https://the.kalaclista.com/images/notes/$path/1_thumb_1x.png 1x}
  );

  done_testing;
};

done_testing;
