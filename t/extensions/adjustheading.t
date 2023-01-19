#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use HTML5::DOM;
use URI::Fast;

use Kalaclista::Path;
use Kalaclista::Entry;

use WebSite::Extensions::AdjustHeading;

my $parser  = HTML5::DOM->new( { script => 1 } );
my $content = Kalaclista::Path->detect(qr{^t$})->child('content/entries/nyarla.md');
my $entry   = Kalaclista::Entry->new(
  $content->path,
  URI::Fast->new("https://the.kalaclista.com/nyarla/"),
);

my $target = $parser->parse(
  q{
<h1>h1</h1>
<h2>h2</h2>
<h3>h3</h3>
<h4>h4</h4>
<h5>h5</h5>
<h6>h6</h6>
}

)->at('body');

sub main {
  $entry->register( sub { WebSite::Extensions::AdjustHeading->transform(@_) } );
  $entry->{'dom'} = $target;

  $entry->transform;

  is( $entry->dom->at('h2')->innerText,                    'h1' );
  is( $entry->dom->at('h3')->innerText,                    'h2' );
  is( $entry->dom->at('h4')->innerText,                    'h3' );
  is( $entry->dom->at('h5')->innerText,                    'h4' );
  is( $entry->dom->at('h6')->innerText,                    'h5' );
  is( $entry->dom->at('p > strong:only-child')->innerText, 'h6' );

  done_testing;
}

main;
