#!/usr/bin/env perl

use v5.38;
use utf8;

use feature qw(state);

use Test2::V0;
use URI::Fast;
use HTML5::DOM;

use WebSite::Widgets::Profile qw(profile);

use WebSite::Context;
use WebSite::Context::URI qw(href);

my sub dom : prototype($) { state $p ||= HTML5::DOM->new; $p->parse(shift)->body }

subtest profile => sub {
  my $html = profile;
  utf8::decode($html);
  my $dom = dom $html;

  my $figure = $dom->at('section#profile')->at('figure');
  is $figure->at('p > a')->attr('href'),          href('/nyarla/')->to_string;
  is $figure->at('p > a > img')->attr('src'),     href('/assets/avatar.svg')->to_string;
  is $figure->at('p > a > img')->attr('width'),   96;
  is $figure->at('p > a > img')->attr('height'),  96;
  is $figure->at('p > a > img')->attr('alt'),     '';
  is $figure->at('figcaption > a')->attr('href'), href('/nyarla/')->to_string;
  is $figure->at('figcaption > a')->text,         'にゃるら（カラクリスタ）';

  my $section = $dom->at('#profile > section');
  is $section->find('p')->length, 2;

  my $nav = $dom->at('nav');
  my $web = $nav->at('p:nth-child(1)');
  my $sns = $nav->at('p:nth-child(2)');

  is $web->at('a:nth-child(1)')->attr('href'), 'https://github.com/nyarla/';
  is $web->at('a:nth-child(1)')->text,         'GitHub';
  is $web->at('a:nth-child(3)')->attr('href'), 'https://zenn.dev/nyarla';
  is $web->at('a:nth-child(3)')->text,         'Zenn';
  is $web->at('a:nth-child(5)')->attr('href'), 'https://sizu.me/nyarla';
  is $web->at('a:nth-child(5)')->text,         'しずかなインターネット';

  is $sns->at('a:nth-child(1)')->attr('href'), 'https://kalaclista.com/@nyarla';
  is $sns->at('a:nth-child(1)')->text,         'GoToSocial';
  is $sns->at('a:nth-child(3)')->attr('href'), 'https://misskey.io/@nyarla';
  is $sns->at('a:nth-child(3)')->text,         'Misskey.io';
};

done_testing;
