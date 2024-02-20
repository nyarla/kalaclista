#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use URI::Fast;
use URI::Escape qw(uri_escape_utf8);

use Kalaclista::Entry;

use WebSite::Context;
use WebSite::Extensions::Picture;

local $ENV{'KALACLISTA_ENV'} = 'production';
my $c = WebSite::Context->init(qr{^t$});

sub entry {
  my $path    = shift;
  my $content = $c->entries->parent->child("precompiled/${path}.md")->get;
  utf8::encode($content);

  my $entry = Kalaclista::Entry->new(
    src  => $content,
    href => URI::Fast->new("https://the.kalaclista.com/${path}/"),
  );

  $entry->add_transformer( sub { WebSite::Extensions::Picture->transform( @_, [ 640, 1280 ] ) } );
  $entry->transform;

  return $entry;
}

subtest blog => sub {
  my $path  = 'posts/2022/03/09/184033';
  my $entry = entry($path);

  my $item = $entry->dom->at('.h-item');

  is(
    $item->getAttribute('href'),
    "https://the.kalaclista.com/images/${path}/1_1x.webp",
  );

  is( $item->at('img')->getAttribute('height'), 582 );
  is( $item->at('img')->getAttribute('width'),  640 );
  is(
    $item->at('img')->getAttribute('src'),
    "https://the.kalaclista.com/images/$path/1_1x.webp",
  );

  is(
    $item->at('img')->getAttribute('srcset'),
    join(
      q{, }, qq<https://the.kalaclista.com/images/${path}/1_1x.webp 640w>,
      qq<https://the.kalaclista.com/images/${path}/1_2x.webp 1280w>,
    ),
  );

  is(
    $item->at('img')->getAttribute('sizes'),
    join(
      q{, }, qq<(max-width: 640px) 640px>,
      q<(max-width: 1280px) 1280px>,
    ),
  );

};

subtest notes => sub {
  my $path  = '自作キーボード';
  my $entry = entry("notes/${path}");

  my $item = $entry->dom->at('.h-item');
  my $fn   = uri_escape_utf8($path);

  is(
    $item->getAttribute('href'),
    "https://the.kalaclista.com/images/notes/${fn}/1_1x.webp",
  );

  is( $item->at('img')->getAttribute('height'), 288 );
  is( $item->at('img')->getAttribute('width'),  640 );
  is(
    $item->at('img')->getAttribute('src'),
    "https://the.kalaclista.com/images/notes/${fn}/1_1x.webp",
  );

  is(
    $item->at('img')->getAttribute('srcset'),
    join(
      q{, }, qq<https://the.kalaclista.com/images/notes/${fn}/1_1x.webp 640w>,
      qq<https://the.kalaclista.com/images/notes/${fn}/1_2x.webp 1280w>,
    ),
  );

  is(
    $item->at('img')->getAttribute('sizes'),
    join(
      q{, }, qq<(max-width: 640px) 640px>,
      q<(max-width: 1280px) 1280px>,
    ),
  );

  done_testing;
};

done_testing;
