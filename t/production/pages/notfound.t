#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use HTML5::DOM;

use Kalaclista::Path;

use WebSite::Context;
local $ENV{'KALACLISTA_ENV'} = 'production';

my $dist   = WebSite::Context->init(qr{^t$})->dirs->distdir;
my $parser = HTML5::DOM->new( { scripts => 1 } );

sub main {
  my $html = $dist->child('404.html')->get;
  utf8::decode($html);

  my $dom = $parser->parse($html);

  is( $dom->at('title')->textContent, 'ページが見つかりません - カラクリスタ' );
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
