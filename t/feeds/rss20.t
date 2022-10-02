#!/usr/bin/env perl

use strict;
use warnings;

use Kalaclista::Directory;

use Test2::V0;
use XML::LibXML;

my $dirs = Kalaclista::Directory->instance;
my $dist = $dirs->rootdir->child("dist");

my $config = do $dirs->rootdir->child('config.pl')->stringify;
my $data   = $config->{'data'};

sub at {
  my $xml = shift;
  return sub {
    my $xpath = shift;
    return $xml->find($xpath)->[0]->textContent;
  };
}

sub main {
  for my $section (qw(posts echos notes)) {
    my $feed = $dist->child("${section}/index.xml");
    my $xml  = XML::LibXML->load_xml( IO => $feed->openr );

    my $channel = $xml->find('//channel')->[0];
    my $at      = at($channel);

    is( $at->('title'), $data->{$section}->{'title'} );

    is(
      $at->('atom:link[@type]/@href'),
      "https://the.kalaclista.com/${section}/"
    );

    is( $at->('atom:link[@type]/@type'), 'application/rss+xml' );

    is(
      $at->('atom:link[@rel]/@href'),
      "https://the.kalaclista.com/${section}/index.xml"
    );

    is( $at->('atom:link[@rel]/@rel'), 'self' );

    is( $at->('description'), $data->{$section}->{'title'} . 'の最近の記事' );
    is(
      $at->('managingEditor'),
      'OKAMURA Naoki aka nyarla (nyarla@kalaclista.com)'
    );
    is(
      $at->('webMaster'),
      'OKAMURA Naoki aka nyarla (nyarla@kalaclista.com)'
    );

    is( $at->('copyright'), '(c) 2006-2022 OKAMURA Naoki' );

    my $dtRe = qr<\w+ \d{2} \w+ \d{4} \d{2}:\d{2}:\d{2} (?:[-+]\d{4})>;

    like( $at->('lastBuildDate'), $dtRe );

    for my $item ( $channel->findnodes('item') ) {
      my $node = at($item);
      ok( $node->('title') ne q{} );
      ok( $node->('description') ne q{} );
      is( $node->('link'), $node->('guid') );
      like( $node->('pubDate'), $dtRe );
    }
  }

  my $xml     = XML::LibXML->load_xml( IO => $dist->child('index.xml')->openr );
  my $channel = $xml->find('//channel')->[0];
  my $at      = at($channel);

  is( $at->('title'),                  $data->{'pages'}->{'title'} );
  is( $at->('atom:link[@type]/@href'), "https://the.kalaclista.com/" );
  is( $at->('atom:link[@type]/@type'), 'application/rss+xml' );
  is( $at->('atom:link[@rel]/@href'),  "https://the.kalaclista.com/index.xml" );
  is( $at->('atom:link[@rel]/@rel'),   'self' );
  is( $at->('description'),            $data->{'pages'}->{'title'} . 'の最近の更新' );
  is(
    $at->('managingEditor'),
    'OKAMURA Naoki aka nyarla (nyarla@kalaclista.com)'
  );
  is( $at->('webMaster'), 'OKAMURA Naoki aka nyarla (nyarla@kalaclista.com)' );
  is( $at->('copyright'), '(c) 2006-2022 OKAMURA Naoki' );

  my $dtRe = qr<\w+ \d{2} \w+ \d{4} \d{2}:\d{2}:\d{2} (?:[-+]\d{4})>;

  like( $at->('lastBuildDate'), $dtRe );

  for my $item ( $channel->findnodes('item') ) {
    my $node = at($item);
    ok( $node->('title') ne q{} );
    ok( $node->('description') ne q{} );
    is( $node->('link'), $node->('guid') );
    like( $node->('pubDate'), $dtRe );
  }
  done_testing;
}

main;
