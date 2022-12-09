#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use HTML5::DOM;
use URI::Fast;

use Kalaclista::Path;
use Kalaclista::Entry;

use WebSite::Extensions::Furigana;

my $parser  = HTML5::DOM->new( { script => 1 } );
my $content = Kalaclista::Path->detect(qr{^t$})->child('content/entries/nyarla.md');
my $entry   = Kalaclista::Entry->new(
  $content->path,
  URI::Fast->new("https://the.kalaclista.com/nyarla/"),
);

my $simple  = $parser->parse('<p>{無|ム}</p>')->at('body');
my $complex = $parser->parse('<p>{夏目漱石|なつ|め|そう|せき}</p>')->at('body');

sub main {
  $entry->register( sub { WebSite::Extensions::Furigana->transform(@_) } );
  $entry->{'dom'} = $simple;

  $entry->transform;

  is( $entry->dom->at('p')->html, '<p><ruby>無<rt>ム</rt></ruby></p>' );

  $entry->{'dom'} = $complex;
  $entry->transform;

  is(
    $entry->dom->at('p')->html,
'<p><ruby>夏<rp>（</rp><rt>なつ</rt><rp>）</rp>目<rp>（</rp><rt>め</rt><rp>）</rp>漱<rp>（</rp><rt>そう</rt><rp>）</rp>石<rp>（</rp><rt>せき</rt><rp>）</rp></ruby></p>'
  );

  done_testing;
}

main;
