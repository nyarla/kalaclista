#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use URI::Fast;
use HTML5::DOM;

use Kalaclista::Constants;
use WebSite::Widgets::Title;

Kalaclista::Constants->baseURI( URI::Fast->new('https://example.com') );

my $parser = HTML5::DOM->new();

sub main {
  my $banner = banner;
  utf8::decode($banner);

  my $dom = $parser->parse($banner)->at('body');

  is( $dom->at('header')->getAttribute('id'), 'global' );

  is( $dom->at('header > p > a')->getAttribute('href'), 'https://example.com/' );
  is( $dom->at('header > p > a')->textContent,          'カラクリスタ' );

  my $banner2 = banner;
  utf8::decode($banner2);

  is( $banner, $banner2 );

  done_testing;
}

main;
