#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;

use XML::LibXML;
use URI::Fast;

use WebSite::Context::URI  qw(href);
use WebSite::Context::Path qw(distdir);

my sub xml {
  return XML::LibXML->load_xml( string => distdir->child(shift)->load );
}

my sub node {
  my $node = shift;
  return sub {
    my $xpath = shift;
    return $node->find($xpath)->[0]->textContent;
  };
}

subtest atomfeed => sub {
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

  for my $section (qw(posts echos notes home)) {
    my $filename = $section ne q{home} ? "$section/atom.xml" : "atom.xml";
    my $website  = $section ne q{home} ? href("/$section/")  : href('/');
    my $href     = href($filename);
    my $xml      = xml($filename)->documentElement;
    my sub at { state $node ||= node($xml); $node->(@_) }

    is at('*[name()="title"]'),    $data->{$section}->{'title'};
    is at('*[name()="subtitle"]'), $data->{$section}->{'summary'};

    is at('*[name()="link" and contains(@rel, "self")]/@href'), $href->to_string;
    is at('*[name()="link" and not(@rel)]/@href'),              $website->to_string;

    is at('*[name()="id"]'),   $href->to_string;
    is at('*[name()="icon"]'), href('/assets/avatar.png')->to_string;

    is at('*[name()="author"]/*[name()="name"]'),  'OKAMURA Naoki aka nyarla';
    is at('*[name()="author"]/*[name()="email"]'), 'nyarla@kalaclista.com';
    is at('*[name()="author"]/*[name()="uri"]'),   'https://the.kalaclista.com/nyarla/';

    like at('*[name()="updated"]'), qr/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[-+]\d{2}:\d{2}|Z)/;

    for my $entry ( $xml->findnodes('//*[name()="entry"]') ) {
      my sub item { state $node ||= node($entry); $node->(@_) }

      ok item('*[name()="title"]') ne q{};

      like
          item('*[name()="id"]'),
          qr<https?://[^/]+/(?:(?:(?:posts|echos)/\d{4}/\d{2}/\d{2}/\d{6}/)|notes/(?:[^/]+)/)>;

      like
          item('*[name()="link"]/@href'),
          qr<https?://[^/]+/(?:(?:(?:posts|echos)/\d{4}/\d{2}/\d{2}/\d{6}/)|notes/(?:[^/]+)/)>;

      is item('*[name()="author"]/*[name()="name"]'),  'OKAMURA Naoki aka nyarla';
      is item('*[name()="author"]/*[name()="email"]'), 'nyarla@kalaclista.com';
      is item('*[name()="author"]/*[name()="uri"]'),   'https://the.kalaclista.com/nyarla/';

      like item('*[name()="updated"]'), qr/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[-+]\d{2}:\d{2}|Z)/;

      ok item('*[name()="content"]') ne q{};
      is item('*[name()="content"]/@type'), q|html|;
    }
  }
};

done_testing;
