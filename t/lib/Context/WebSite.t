#!/usr/bin/env perl

use v5.38;
use utf8;

use WebSite::Context::URI     qw(href);
use WebSite::Context::WebSite qw(website posts echos notes);

use Test2::V0;

subtest website => sub {
  is website->label,           'カラクリスタ';
  is website->title,           'カラクリスタ';
  is website->summary,         '『輝かしい青春』なんて失かった人の Web サイトです';
  is website->href->to_string, href('')->to_string;
};

subtest posts => sub {
  is posts->label,           'ブログ';
  is posts->title,           'カラクリスタ・ブログ';
  is posts->summary,         '『輝かしい青春』なんて失かった人のブログです';
  is posts->href->to_string, href('/posts/')->to_string;
};

subtest echos => sub {
  is echos->label,           '日記';
  is echos->title,           'カラクリスタ・エコーズ';
  is echos->summary,         '『輝かしい青春』なんて失かった人の日記です';
  is echos->href->to_string, href('/echos/')->to_string;
};

subtest notes => sub {
  is notes->label,           'メモ帳';
  is notes->title,           'カラクリスタ・ノート';
  is notes->summary,         '『輝かしい青春』なんて失かった人のメモ帳です';
  is notes->href->to_string, href('/notes/')->to_string;
};

done_testing;
