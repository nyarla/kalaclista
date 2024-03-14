#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;

use HTML5::DOM;
use URI::Fast;

use Kalaclista::Data::Entry;

use WebSite::Extensions::Furigana qw(furigana apply);

my sub dom : prototype($) { state $p ||= HTML5::DOM->new; $p->parse(shift)->body }
my sub entry {
  state $entry ||= Kalaclista::Data::Entry->new(
    title   => '',
    summary => '',
    section => '',
    date    => '',
    lastmod => '',
    href    => URI::Fast->new('https://example.com/test'),
  );

  return $entry;
}

subtest furigana => sub {
  subtest single => sub {
    my $text = furigana '無​|​ム';
    is $text, q|<ruby>無<rt>ム</rt></ruby>|;
  };

  subtest multiple => sub {
    my $text = furigana '夏目漱石|なつ|め|そう|せき';
    is $text,
q|<ruby>夏<rp>（</rp><rt>なつ</rt><rp>）</rp>目<rp>（</rp><rt>め</rt><rp>）</rp>漱<rp>（</rp><rt>そう</rt><rp>）</rp>石<rp>（</rp><rt>せき</rt><rp>）</rp></ruby>|;
  };
};

subtest apply => sub {
  my $text = '{無|む}';
  my $ruby = q|<ruby>無<rt>む</rt></ruby>|;

  for my $el (qw|h1 h2 h3 h4 h5 h6 p li dt dd|) {
    my $dom = dom qq|<${el}>${text}</${el}>|;
    apply $dom;

    is $dom->at($el)->innerHTML, $ruby;
  }
};

subtest transform => sub {
  my $entry  = entry;
  my $expect = WebSite::Extensions::Furigana->transform($entry);

  is $entry, $expect;

  $entry = $entry->clone( dom => dom('<p>{無|む}</p>') );
  $entry = WebSite::Extensions::Furigana->transform($entry);

  isnt $entry, $expect;

  is $entry->dom->at('p')->innerHTML, q|<ruby>無<rt>む</rt></ruby>|;
};

done_testing;
