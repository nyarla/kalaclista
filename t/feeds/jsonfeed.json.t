#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use JSON::XS qw(decode_json);

use WebSite::Context;

my $dist = WebSite::Context->init(qr{^t$})->dirs->distdir;

sub testing_feed {
  my ( $section, $json, $data ) = @_;

  my $prefix    = $section eq 'pages' ? ''                      : "/${section}";
  my $sectionRe = $section eq 'pages' ? '(?:posts|echos|notes)' : $section;

  is( $json->{'version'},     'https://jsonfeed.org/version/1.1', );
  is( $json->{'title'},       $data->{'website'} );
  is( $json->{'description'}, $data->{'description'} );
  is( $json->{'icon'},        'https://the.kalaclista.com/assets/avatar.png' );
  is( $json->{'favicon'},     'https://the.kalaclista.com/favicon.ico' );

  is(
    $json->{'authors'},
    [
      {
        name   => 'OKAMURA Naoki aka nyarla',
        url    => 'https://the.kalaclista.com/nyarla/',
        avatar => 'https://the.kalaclista.com/assets/avatar.png',
      }
    ]
  );

  is( $json->{'language'},      'ja_JP' );
  is( $json->{'home_page_url'}, "https://the.kalaclista.com${prefix}/" );
  is(
    $json->{'feed_url'},
    "https://the.kalaclista.com${prefix}/jsonfeed.json"
  );

  for my $item ( $json->{'items'}->@* ) {
    like(
      $item->{'id'},
      qr<https://the\.kalaclista\.com/${sectionRe}/(?:\d{4}/\d{2}/\d{2}\/d{6}|[^/]+/)>
    );

    like(
      $item->{'url'},
      qr<https://the\.kalaclista\.com/${sectionRe}/(?:\d{4}/\d{2}/\d{2}\/d{6}|[^/]+/)>
    );

    ok( $item->{'title'} ne q{} );
    ok( $item->{'content_html'} ne q{} );
    like(
      $item->{'date_published'},
      qr<\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[+-]\d{2}:\d{2}|Z)>
    );
    like(
      $item->{'date_modified'},
      qr<\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[+-]\d{2}:\d{2}|Z)>
    );
    is(
      $item->{'authors'},
      [
        {
          name   => 'OKAMURA Naoki aka nyarla',
          url    => 'https://the.kalaclista.com/nyarla/',
          avatar => 'https://the.kalaclista.com/assets/avatar.png',
        }
      ]
    );

    is( $item->{'language'}, 'ja_JP' );
  }

}

sub main {
  my $data = {
    pages => {
      website     => 'カラクリスタ',
      description => '『輝かしい青春』なんて失かった人の Web サイトです',
    },

    posts => {
      website     => 'カラクリスタ・ブログ',
      description => '『輝かしい青春』なんて失かった人のブログです',
    },
    echos => {
      website     => 'カラクリスタ・エコーズ',
      description => '『輝かしい青春』なんて失かった人の日記です',
    },
    notes => {
      website     => 'カラクリスタ・ノート',
      description => '『輝かしい青春』なんて失かった人のメモ帳です',
    },
  };

  for my $section (qw(posts echos notes)) {
    my $jsonfeed = $dist->child("${section}/jsonfeed.json")->get;
    my $json     = decode_json($jsonfeed);

    testing_feed( $section, $json, $data->{$section} );
  }

  testing_feed( 'pages', decode_json( $dist->child("/jsonfeed.json")->get ), $data->{'pages'} );

  done_testing;
}

main;
