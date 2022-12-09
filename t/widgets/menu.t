#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use URI::Fast;
use HTML5::DOM;

use Kalaclista::Constants;
use WebSite::Widgets::Menu;

Kalaclista::Constants->baseURI( URI::Fast->new('https://example.com') );

my $parser = HTML5::DOM->new;
my $search = 'https://cse.google.com/cse?cx=018101178788962105892:toz3mvb2bhr#gsc.tab=0';

sub main {
  my $menu = sitemenu;
  utf8::decode($menu);

  my $dom = $parser->parse($menu)->at('body');

  is( $dom->at('nav')->getAttribute('id'),    'menu' );
  is( $dom->at('nav')->getAttribute('class'), 'entry__content' );

  ok( $dom->at('nav > hr:first-child') );

  is( $dom->at('nav > p:nth-child(2)')->getAttribute('class'), 'kind' );

  is( $dom->at('nav > p:nth-child(2) a:first-child')->getAttribute('href'), 'https://example.com/posts/' );
  is( $dom->at('nav > p:nth-child(2) a:first-child')->text,                 'ブログ' );

  is( $dom->at('nav > p:nth-child(2) a:nth-child(2)')->getAttribute('href'), 'https://example.com/echos/' );
  is( $dom->at('nav > p:nth-child(2) a:nth-child(2)')->text,                 '日記' );

  is( $dom->at('nav > p:nth-child(2) a:last-child')->getAttribute('href'), 'https://example.com/notes/' );
  is( $dom->at('nav > p:nth-child(2) a:last-child')->text,                 'メモ帳' );

  is( $dom->at('nav > p:nth-child(3)')->getAttribute('class'), 'links' );

  is( $dom->at('nav > p:nth-child(3) a:first-child')->getAttribute('href'), 'https://example.com/policies/' );
  is( $dom->at('nav > p:nth-child(3) a:first-child')->text,                 '運営方針' );

  is( $dom->at('nav > p:nth-child(3) a:nth-child(2)')->getAttribute('href'), 'https://example.com/licenses/' );
  is( $dom->at('nav > p:nth-child(3) a:nth-child(2)')->text,                 '権利情報' );

  is( $dom->at('nav > p:nth-child(3) a:last-child')->getAttribute('href'), $search );
  is( $dom->at('nav > p:nth-child(3) a:last-child')->text,                 '検索' );

  my $menu2 = sitemenu;
  utf8::decode($menu2);

  is( $menu, $menu2 );

  done_testing;
}

main;
