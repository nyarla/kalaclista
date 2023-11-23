#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use XML::LibXML;

use Kalaclista::Path;
use WebSite::Context;

my $dist = WebSite::Context->init(qr{^t$})->dist;

sub at {
  my $xml = shift;

  return sub {
    my $xpath = shift;

    return $xml->find($xpath)->[0]->textContent;
  };
}

sub testing_feed {
  my ( $section, $xml, $data ) = @_;

  my $at        = at( $xml->documentElement );
  my $sectionRe = $section ne 'pages' ? $section      : '(?:posts|echos|notes)';
  my $prefix    = $section ne 'pages' ? "/${section}" : q{};

  is( $at->('*[name()="title"]'),    $data->{'website'} );
  is( $at->('*[name()="subtitle"]'), $data->{'description'} );

  is(
    $at->('*[name()="link" and not(@rel) ]/@href'),
    "https://the.kalaclista.com${prefix}/"
  );

  is(
    $at->('*[name()="link" and contains(@rel, "self")]/@href'),
    "https://the.kalaclista.com${prefix}/atom.xml"
  );

  is( $at->('*[name()="id"]'), "https://the.kalaclista.com${prefix}/atom.xml" );

  is( $at->('*[name()="icon"]'), "https://the.kalaclista.com/assets/avatar.png" );

  is( $at->('*[name()="author"]/*[name()="name"]'),  "OKAMURA Naoki aka nyarla" );
  is( $at->('*[name()="author"]/*[name()="email"]'), 'nyarla@kalaclista.com' );
  is( $at->('*[name()="author"]/*[name()="uri"]'),   'https://the.kalaclista.com/nyarla/' );

  like(
    $at->('*[name()="updated"]'),
    qr<\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[+-]\d{2}:\d{2}|Z)>
  );

  my @entries = $xml->findnodes('//*[name()="entry"]');
  is( scalar(@entries), 5 );

  for my $entry (@entries) {
    my $item = at($entry);

    ok( $item->('*[name()="title"]') ne q{} );
    like(
      $item->('*[name()="id"]'),
      qr<https://the\.kalaclista\.com/$sectionRe/(?:\d{4}/\d{2}/\d{2}/\d{6}|[^/]+)/>
    );

    like(
      $item->('*[name()="link"]/@href'),
      qr<https://the\.kalaclista\.com/$sectionRe/(?:\d{4}/\d{2}/\d{2}/\d{6}|[^/]+)/>
    );

    is(
      $item->('*[name()="author"]/*[name()="name"]'),
      'OKAMURA Naoki aka nyarla'
    );
    is(
      $item->('*[name()="author"]/*[name()="email"]'),
      'nyarla@kalaclista.com'
    );
    is(
      $item->('*[name()="author"]/*[name()="uri"]'),
      'https://the.kalaclista.com/nyarla/'
    );

    like(
      $item->('*[name()="updated"]'),
      qr<\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[+-]\d{2}:\d{2}|Z)>
    );

    ok( $item->('*[name()="content"]') ne q{} );
    is( $item->('*[name()="content"]/@type'), q{html} );
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
    my $xml = XML::LibXML->load_xml( string => $dist->child("${section}/atom.xml")->get );
    testing_feed( $section, $xml, $data->{$section} );
  }

  testing_feed( 'pages', XML::LibXML->load_xml( string => $dist->child('/atom.xml')->get ), $data->{'pages'} );

  done_testing;
}

main;
