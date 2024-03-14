#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;

use XML::LibXML;
use URI::Fast;

use WebSite::Context::URI         qw(href);
use WebSite::Context::Path        qw(distdir);
use WebSite::Context::Environment qw(env);

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

subtest 'rss20feed' => sub {
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

  my $dateRE = qr|\w+ \d{2} \w+ \d{4} \d{2}:\d{2}:\d{2} (?:[-+]\d{4})|;

  for my $section (qw|posts echos notes home|) {
    last if $section ne q|posts| && env->test;

    my $filename = $section ne q{home} ? "$section/index.xml" : "index.xml";
    my $website  = $section ne q{home} ? href("/$section/")   : href('/');
    my $href     = href($filename);
    my $xml      = xml($filename)->find('//channel')->[0];
    my sub at { state $node ||= node($xml); $node->(@_) }

    is at('title'), $data->{$section}->{'title'};

    is at('atom:link[@type]/@href'), $website->to_string;
    is at('atom:link[@type]/@type'), 'application/rss+xml';

    is at('atom:link[@rel]/@href'), $href->to_string;
    is at('atom:link[@rel]/@rel'),  'self';

    is at('description'),    $data->{$section}->{'summary'};
    is at('managingEditor'), 'OKAMURA Naoki aka nyarla (nyarla@kalaclista.com)';
    is at('webMaster'),      'OKAMURA Naoki aka nyarla (nyarla@kalaclista.com)';
    is at('copyright'),      "(c) 2006-@{[ (localtime)[5] +1900]} OKAMURA Naoki";

    like at('lastBuildDate'), $dateRE;

    for my $entry ( xml($filename)->findnodes('//channel/item') ) {
      my sub item { state $item ||= node($entry); $item->(shift) }

      ok item('title') ne q{};
      ok item('description') ne q{};

      is item('link'), item('guid');
      like
          item('link'),
          qr<https?://[^/]+/(?:(?:(?:posts|echos)/\d{4}/\d{2}/\d{2}/\d{6}/)|notes/(?:[^/]+)/)>;

      like item('pubDate'), $dateRE;
    }
  }
};

done_testing;
