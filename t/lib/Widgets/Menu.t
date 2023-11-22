#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use URI::Fast;
use HTML5::DOM;

use WebSite::Widgets::Menu;

use WebSite::Context;
local $ENV{'KALACLISTA_ENV'} = 'production';
WebSite::Context->init(qr{^t$});

my $parser = HTML5::DOM->new;
my $search = 'https://cse.google.com/cse?cx=018101178788962105892:toz3mvb2bhr#gsc.tab=0';

sub main {
  my $menu = sitemenu;
  utf8::decode($menu);

  my $dom = $parser->parse($menu)->at('body');

  is( $dom->at('nav')->getAttribute('id'), 'menu' );

  is( $dom->at('nav > .section > a:first-child')->getAttribute('href'), 'https://the.kalaclista.com/posts/' );
  is( $dom->at('nav > .section > a:first-child')->text,                 'ブログ' );

  is( $dom->at('nav > .section a:nth-child(2)')->getAttribute('href'), 'https://the.kalaclista.com/echos/' );
  is( $dom->at('nav > .section a:nth-child(2)')->text,                 '日記' );

  is( $dom->at('nav > .section a:last-child')->getAttribute('href'), 'https://the.kalaclista.com/notes/' );
  is( $dom->at('nav > .section a:last-child')->text,                 'メモ帳' );

  is( $dom->at('nav > .help a:first-child')->getAttribute('href'), 'https://the.kalaclista.com/nyarla/' );
  is( $dom->at('nav > .help a:first-child')->text,                 'プロフィール' );

  is( $dom->at('nav > .help a:last-child')->getAttribute('href'), $search );
  is( $dom->at('nav > .help a:last-child')->text,                 '検索' );

  my $menu2 = sitemenu;
  utf8::decode($menu2);

  is( $menu, $menu2 );

  done_testing;
}

main;
