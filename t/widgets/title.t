#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use URI::Fast;
use HTML5::DOM;

use Kalaclista::Variables;

use WebSite::Widgets::Title;

use WebSite::Context;
local $ENV{'KALACLISTA_ENV'} = 'production';
WebSite::Context->init(qr{^t$});

my $parser = HTML5::DOM->new();

sub parse {
  my $html = shift;
  utf8::decode($html);
  return $parser->parse($html)->at('body');
}

sub main {
  my $vars = Kalaclista::Variables->new(
    section  => '',
    contains => {
      posts => { label => 'ブログ' },
      echos => { label => '日記' },
      notes => { label => 'メモ帳' },
    },
  );

  my $banner = banner($vars);
  my $dom    = parse($banner);

  is( $dom->at('nav')->getAttribute('id'),      'global' );
  is( scalar $dom->find('#global > p > a')->@*, 1 );

  is(
    $dom->at('#global > p > a')->getAttribute('href'),
    'https://the.kalaclista.com/'
  );

  is(
    $dom->at('#global > p > a > img')->getAttribute('src'),
    'https://the.kalaclista.com/assets/avatar.svg'
  );

  is( $dom->at('#global > p > a > img')->getAttribute('width'),  50 );
  is( $dom->at('#global > p > a > img')->getAttribute('height'), 50 );

  for my $section (qw(posts echos notes)) {
    $vars->section($section);
    $dom = parse( banner($vars) );

    is( $dom->at('#global > p > span')->innerText, '→' );

    is(
      $dom->at('#global > p > a:last-child')->getAttribute('href'),
      "https://the.kalaclista.com/${section}/",
    );

    is(
      $dom->at('#global > p > a:last-child')->innerText,
      $vars->contains->{ $vars->section }->{'label'},
    );
  }

  done_testing;
}

main;
