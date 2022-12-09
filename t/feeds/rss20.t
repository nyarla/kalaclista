#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use XML::LibXML;

use Kalaclista::Path;

my $dist = Kalaclista::Path->detect(qr{^t$})->child("public/dist");

sub at {
  my $xml = shift;
  return sub {
    my $xpath = shift;
    return $xml->find($xpath)->[0]->textContent;
  };
}

sub testing_feed {
  my $section = shift;
  my $xml     = shift;
  my $data    = shift;

  my $prefix    = $section eq 'pages' ? ''                      : "/${section}";
  my $sectionRe = $section eq 'pages' ? '(?:posts|echos|notes)' : $section;

  my $at = at( $xml->find('//channel')->[0] );

  is( $at->('title'), $data->{'website'} );

  is( $at->('atom:link[@type]/@href'), "https://the.kalaclista.com${prefix}/" );
  is( $at->('atom:link[@type]/@type'), 'application/rss+xml' );

  is( $at->('atom:link[@rel]/@href'), "https://the.kalaclista.com${prefix}/index.xml" );
  is( $at->('atom:link[@rel]/@rel'),  'self' );

  is( $at->('description'),    $data->{'description'} );
  is( $at->('managingEditor'), 'OKAMURA Naoki aka nyarla (nyarla@kalaclista.com)' );
  is( $at->('webMaster'),      'OKAMURA Naoki aka nyarla (nyarla@kalaclista.com)' );

  is( $at->('copyright'), '(c) 2006-' . ( (localtime)[5] + 1900 ) . " OKAMURA Naoki" );

  my $datetimeRe = qr<\w+ \d{2} \w+ \d{4} \d{2}:\d{2}:\d{2} (?:[-+]\d{4})>;
  my $hrefRe     = qr{^https://the\.kalaclista\.com/${sectionRe}/};

  like( $at->('lastBuildDate'), $datetimeRe );

  my $count = 0;
  for my $item ( $xml->findnodes('//channel/item') ) {
    $count++;
    my $node = at($item);

    ok( $node->('title') ne q{} );
    ok( $node->('description') ne q{} );

    is( $node->('link'), $node->('guid') );
    like( $node->('link'),    $hrefRe );
    like( $node->('pubDate'), $datetimeRe );
  }

  is( $count, 5 );
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
    my $feed = $dist->child("${section}/index.xml");
    my $xml  = XML::LibXML->load_xml( string => $feed->get );

    testing_feed( $section, $xml, $data->{$section} );
  }

  testing_feed( 'pages', XML::LibXML->load_xml( string => $dist->child('/index.xml')->get ), $data->{'pages'} );

  done_testing;
}

main;
