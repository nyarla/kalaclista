#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Kalaclista::Directory;

use Test2::V0;
use JSON::XS qw(decode_json);

my $dirs = Kalaclista::Directory->instance;
my $dist = $dirs->rootdir->child("dist");

my $config = do $dirs->rootdir->child('config.pl')->stringify;
my $data   = $config->{'data'};

sub main {
  for my $section (qw(posts echos notes)) {
    my $jsonfeed = $dist->child("${section}/jsonfeed.json")->slurp;
    my $json     = decode_json($jsonfeed);

    is( $json->{'version'},     'https://jsonfeed.org/version/1.1', );
    is( $json->{'title'},       $data->{$section}->{'title'} );
    is( $json->{'description'}, $data->{$section}->{'title'} . 'の最近の記事' );
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
    is( $json->{'home_page_url'}, "https://the.kalaclista.com/${section}/" );
    is(
      $json->{'feed_url'},
      "https://the.kalaclista.com/${section}/jsonfeed.json"
    );

    for my $item ( $json->{'items'}->@* ) {
      like(
        $item->{'id'},
        qr<https://the\.kalaclista\.com/${section}/(?:\d{4}/\d{2}/\d{2}\/d{6}|[^/]+/)>
      );

      like(
        $item->{'url'},
        qr<https://the\.kalaclista\.com/${section}/(?:\d{4}/\d{2}/\d{2}\/d{6}|[^/]+/)>
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

  my $jsonfeed = $dist->child("jsonfeed.json")->slurp;
  my $json     = decode_json($jsonfeed);

  is( $json->{'version'},     'https://jsonfeed.org/version/1.1', );
  is( $json->{'title'},       $data->{'pages'}->{'title'} );
  is( $json->{'description'}, $data->{'pages'}->{'title'} . 'の最近の更新' );
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
  is( $json->{'home_page_url'}, "https://the.kalaclista.com/" );
  is( $json->{'feed_url'},      "https://the.kalaclista.com/jsonfeed.json" );

  for my $item ( $json->{'items'}->@* ) {
    like(
      $item->{'id'},
      qr<https://the\.kalaclista\.com/(?:(?:posts|echos)/\d{4}/\d{2}/\d{2}\/\d{6}/|notes/[^/]+/)>
    );

    like(
      $item->{'url'},
      qr<https://the\.kalaclista\.com/(?:(?:posts|echos)/\d{4}/\d{2}/\d{2}\/\d{6}/|notes/[^/]+/)>
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

  done_testing;
}

main;
