#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use HTML5::DOM;
use URI::Fast;

use Kalaclista::Path;
use Kalaclista::Entry;

use WebSite::Context;
use WebSite::Extensions::Furigana;

my $c = WebSite::Context->init(qr{^t$});

my $entry = Kalaclista::Entry->new();

my $simple  = '<p>{無|ム}</p>';
my $complex = '<p>{夏目漱石|なつ|め|そう|せき}</p>';

sub main {
  $entry->add_transformer( sub { WebSite::Extensions::Furigana->transform(@_) } );
  $entry->src($simple);

  $entry->transform;

  is( $entry->dom->at('p')->html, '<p><ruby>無<rt>ム</rt></ruby></p>' );

  $entry->src($complex);
  $entry->transform;

  is(
    $entry->dom->at('p')->html,
'<p><ruby>夏<rp>（</rp><rt>なつ</rt><rp>）</rp>目<rp>（</rp><rt>め</rt><rp>）</rp>漱<rp>（</rp><rt>そう</rt><rp>）</rp>石<rp>（</rp><rt>せき</rt><rp>）</rp></ruby></p>'
  );

  done_testing;
}

main;
