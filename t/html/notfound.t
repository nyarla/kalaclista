#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use HTML5::DOM;

use Kalaclista::Directory;

my $dirs   = Kalaclista::Directory->instance;
my $parser = HTML5::DOM->new( { scripts => 1 } );

sub main {
  my $page = $dirs->distdir->child('404.html')->slurp_utf8;
  my $dom  = $parser->parse($page);

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
