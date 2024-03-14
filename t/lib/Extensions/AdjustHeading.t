#!/usr/bin/env perl

use v5.38;
use warnings;

use feature qw(state);

use Test2::V0;

use HTML5::DOM;
use URI::Fast;

use Kalaclista::Data::Entry;

use WebSite::Extensions::AdjustHeading qw(adjust);

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

subtest adjust => sub {
  my $html = <<'...';
<h1>h1</h1>
<h2>h2</h2>
<h3>h3</h3>
<h4>h4</h4>
<h5>h5</h5>
<h6>h6</h6>
...
  my $dom = dom $html;
  adjust $dom;

  my $tests = [
    { sel => 'h2',                    val => 'h1' },
    { sel => 'h3',                    val => 'h2' },
    { sel => 'h4',                    val => 'h3' },
    { sel => 'h5',                    val => 'h4' },
    { sel => 'h6',                    val => 'h5' },
    { sel => 'p > strong:only-child', val => 'h6' },
  ];

  for my $test ( $tests->@* ) {
    is $dom->at( $test->{'sel'} )->textContent, $test->{'val'};
  }
};

subtest transform => sub {
  my $entry  = entry;
  my $expect = WebSite::Extensions::AdjustHeading->transform($entry);

  is $entry, $expect;

  $entry = $entry->clone( dom => dom('<h1>h1</h1>') );
  $entry = WebSite::Extensions::AdjustHeading->transform($entry);

  isnt $entry, $expect;

  is $entry->dom->at('h2')->textContent, 'h1';
};

done_testing;
