#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use HTML5::DOM;

use Kalaclista::Path;

my $dist = Kalaclista::Path->detect(qr{^t$});

my $parser = HTML5::DOM->new( { scripts => 1 } );

sub main {
  my $html = $dist->child('public/dist/404.html')->get;
  utf8::decode($html);

  my $dom = $parser->parse($html);

  is( $dom->at('title')->textContent, '404 not found - カラクリスタ' );
  is(
    $dom->at('meta[name="description"]')->getAttribute('content'),
    'ページが見つかりません'
  );

  is(
    $dom->at('.entry__notfound a')->getAttribute('href'),
    "https://cse.google.com/cse?cx=018101178788962105892:toz3mvb2bhr#gsc.tab=0"
  );

  done_testing;
}

main;
