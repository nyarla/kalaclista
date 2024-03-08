#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;
use YAML::XS qw(LoadFile);

use WebSite::Context::Environment qw(env);
use WebSite::Context::URI         qw(href);
use WebSite::Context::Path        qw(distdir);
use WebSite::Loader::Entry        qw(prop entries);

subtest jsonfeed => sub {
  my $data = {
    home => {
      title   => 'カラクリスタ',
      summary => '『輝かしい青春』なんて失かった人の Web サイトです',
    },

    posts => {
      title   => 'カラクリスタ・ブログ',
      summary => '『輝かしい青春』なんて失かった人のブログです',
    },
    echos => {
      title   => 'カラクリスタ・エコーズ',
      summary => '『輝かしい青春』なんて失かった人の日記です',
    },
    notes => {
      title   => 'カラクリスタ・ノート',
      summary => '『輝かしい青春』なんて失かった人のメモ帳です',
    },
  };

  my $author = {
    name   => 'OKAMURA Naoki aka nyarla',
    url    => 'https://the.kalaclista.com/nyarla/',
    avatar => 'https://the.kalaclista.com/assets/avatar.png'
  };

  my $map = {};
  entries {
    for my $file (@_) {
      my $prop = prop $file;
      $map->{ $prop->href->to_string }++;
    }
  };

  for my $section (qw(posts echos notes home)) {
    my $filename = $section ne q{home} ? "${section}/jsonfeed.json" : "jsonfeed.json";
    my $prefix   = $section ne q{home} ? "$section/"                : "/";
    my $file     = distdir->child($filename);
    next if !-e $file->path && env->test;

    my $json = LoadFile( $file->path );

    subtest $section => sub {
      is $json->{'version'},       'https://jsonfeed.org/version/1.1';
      is $json->{'title'},         $data->{$section}->{'title'};
      is $json->{'description'},   $data->{$section}->{'summary'};
      is $json->{'icon'},          'https://the.kalaclista.com/assets/avatar.png';
      is $json->{'favicon'},       'https://the.kalaclista.com/favicon.ico';
      is $json->{'authors'},       [$author];
      is $json->{'language'},      'ja_JP';
      is $json->{'home_page_url'}, href($prefix)->to_string;
      is $json->{'feed_url'},      href($filename)->to_string;

      for my $item ( $json->{'items'}->@* ) {
        ok exists $map->{ $item->{'id'} };
        ok exists $map->{ $item->{'url'} };

        like
            $item->{'date_published'},
            qr/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[+-]\d{2}:\d{2}|Z)/;

        like
            $item->{'date_modified'},
            qr/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[+-]\d{2}:\d{2}|Z)/;

        is $item->{'authors'},  [$author];
        is $item->{'language'}, 'ja_JP';
      }
    };
  }
};

done_testing;
