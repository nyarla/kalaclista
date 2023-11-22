#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use HTML5::DOM;

use WebSite::Widgets::Analytics;

my $parser = HTML5::DOM->new( { scripts => 1 } );

sub main {
  my $analytics = analytics;
  utf8::decode($analytics);

  my $dom = $parser->parse($analytics);

  ok( $dom->at('script') );

  like( $dom->at('script')->text, qr<'G-[A-Z0-9]{10}'> );

  my $analytics2 = analytics;
  utf8::decode($analytics2);

  is( $analytics, $analytics2 );

  done_testing;
}

main;
