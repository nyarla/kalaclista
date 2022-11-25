#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use URI::Fast;
use HTML5::DOM;

use Kalaclista::Constants;
use WebSite::Widgets::Profile;

Kalaclista::Constants->baseURI( URI::Fast->new('https://example.com') );

my $parser = HTML5::DOM->new;

sub main {
  my $profile = profile;
  utf8::decode($profile);

  my $dom = $parser->parse($profile)->at('body');

  is( $dom->at('section')->getAttribute('id'), 'profile' );

  is( $dom->at('figure > p > a')->getAttribute('href'),          'https://example.com/nyarla/' );
  is( $dom->at('figure > p > a > img')->getAttribute('src'),     'https://example.com/assets/avatar.svg' );
  is( $dom->at('figure > p > a > img')->getAttribute('width'),   96 );
  is( $dom->at('figure > p > a > img')->getAttribute('height'),  96 );
  is( $dom->at('figure > p > a > img')->getAttribute('alt'),     'アバターアイコン兼ロゴ' );
  is( $dom->at('figure > figcaption > a')->getAttribute('href'), 'https://example.com/nyarla/' );
  is( $dom->at('figure > figcaption > a')->text,                 'にゃるら（カラクリスタ）' );

  is( $dom->at('section > section')->getAttribute('class'), 'entry__content' );
  is( $dom->find('section > section > p')->length,          2 );

  is( $dom->at('nav > p > a:nth-child(1)')->getAttribute('href'), 'https://github.com/nyarla/' );
  is( $dom->at('nav > p > a:nth-child(1)')->text,                 'GitHub' );

  is( $dom->at('nav > p > a:nth-child(2)')->getAttribute('href'), 'https://zenn.dev/nyarla' );
  is( $dom->at('nav > p > a:nth-child(2)')->text,                 'Zenn' );

  is( $dom->at('nav > p > a:nth-child(3)')->getAttribute('href'), 'https://trickle.day/nyarla' );
  is( $dom->at('nav > p > a:nth-child(3)')->text,                 'Trickle' );

  is( $dom->at('nav > p > a:nth-child(4)')->getAttribute('href'), 'https://user.topia.tv/5R9Y' );
  is( $dom->at('nav > p > a:nth-child(4)')->text,                 'トピア' );

  my $profile2 = profile;
  utf8::decode($profile2);

  is( $profile, $profile2 );

  done_testing;
}

main;
