#!/usr/bin/env perl

use v5.38;
use utf8;

use feature qw(state);

use Test2::V0;
use HTML5::DOM;

use WebSite::Context::URI  qw(href);
use WebSite::Widgets::Menu qw(sitemenu);

my sub dom : prototype($) { state $p ||= HTML5::DOM->new; $p->parse(shift)->body }
my $search = 'https://cse.google.com/cse?cx=018101178788962105892:toz3mvb2bhr#gsc.tab=0';

subtest menu => sub {
  my $html = sitemenu;
  utf8::decode($html);

  my $dom = dom $html;
  my $nav = $dom->at('nav#menu');

  is $dom->at('.section > a:nth-child(1)')->attr('href'), href('/posts/')->to_string;
  is $dom->at('.section > a:nth-child(1)')->text,         'ブログ';
  is $dom->at('.section > a:nth-child(2)')->attr('href'), href('/echos/')->to_string;
  is $dom->at('.section > a:nth-child(2)')->text,         '日記';
  is $dom->at('.section > a:nth-child(3)')->attr('href'), href('/notes/')->to_string;
  is $dom->at('.section > a:nth-child(3)')->text,         'メモ帳';

  is $dom->at('.help > a:nth-child(1)')->attr('href'), href('/nyarla/')->to_string;
  is $dom->at('.help > a:nth-child(1)')->text,         'プロフィール';
  is $dom->at('.help > a:nth-child(2)')->attr('href'), $search;
  is $dom->at('.help > a:nth-child(2)')->text,         '検索';
};

done_testing;
