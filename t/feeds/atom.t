#!/usr/bin/env perl

use strict;
use warnings;

use Kalaclista::Directory;

use Data::Dumper qw(Dumper);

use Test2::V0;
use XML::LibXML;

my $dirs = Kalaclista::Directory->instance;
my $dist = $dirs->rootdir->child("dist/public");

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
    my $feed = $dist->child("${section}/atom.xml");
    my $xml  = XML::LibXML->load_xml( IO => $feed->openr );
    my $at   = at( $xml->documentElement );

    is( $at->('*[name()="title"]'), $data->{$section}->{'title'} );
    is(
      $at->('*[name()="subtitle"]'),
      $data->{$section}->{'title'} . "の最近の記事"
    );

    is(
      $at->('*[name()="link" and not(@rel)]/@href'),
      "https://the.kalaclista.com/${section}/"
    );

    is(
      $at->('*[name()="link" and contains(@rel, "self")]/@href'),
      "https://the.kalaclista.com/${section}/atom.xml"
    );

    is(
      $at->('*[name()="id"]'),
      "https://the.kalaclista.com/${section}/atom.xml"
    );

    is(
      $at->('*[name()="icon"]'),
      "https://the.kalaclista.com/assets/avatar.png"
    );

    is(
      $at->('*[name()="author"]/*[name()="name"]'),
      'OKAMURA Naoki aka nyarla'
    );
    is(
      $at->('*[name()="author"]/*[name()="email"]'),
      'nyarla@kalaclista.com'
    );
    is(
      $at->('*[name()="author"]/*[name()="uri"]'),
      'https://the.kalaclista.com/nyarla/'
    );

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
        qr<https://the\.kalaclista\.com/$section/(?:\d{4}/\d{2}/\d{2}/\d{6}|[^/]+)/>
      );

      like(
        $item->('*[name()="link"]/@href'),
        qr<https://the\.kalaclista\.com/$section/(?:\d{4}/\d{2}/\d{2}/\d{6}|[^/]+)/>
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

  my $feed = $dist->child('atom.xml');
  my $xml  = XML::LibXML->load_xml( IO => $feed->openr );
  my $at   = at( $xml->documentElement );

  is( $at->('*[name()="title"]'),    $data->{'pages'}->{'title'} );
  is( $at->('*[name()="subtitle"]'), $data->{'pages'}->{'title'} . "の最近の更新" );

  is(
    $at->('*[name()="link" and not(@rel)]/@href'),
    "https://the.kalaclista.com/"
  );

  is(
    $at->('*[name()="link" and contains(@rel, "self")]/@href'),
    "https://the.kalaclista.com/atom.xml"
  );

  is( $at->('*[name()="id"]'), "https://the.kalaclista.com/atom.xml" );

  is(
    $at->('*[name()="icon"]'),
    "https://the.kalaclista.com/assets/avatar.png"
  );

  is(
    $at->('*[name()="author"]/*[name()="name"]'),
    'OKAMURA Naoki aka nyarla'
  );
  is( $at->('*[name()="author"]/*[name()="email"]'), 'nyarla@kalaclista.com' );
  is(
    $at->('*[name()="author"]/*[name()="uri"]'),
    'https://the.kalaclista.com/nyarla/'
  );

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
      qr<https://the\.kalaclista\.com/(?:(?:posts|echos)/\d{4}/\d{2}/\d{2}/\d{6}|notes/[^/]+)/>
    );

    like(
      $item->('*[name()="link"]/@href'),
      qr<https://the\.kalaclista\.com/(?:(?:posts|echos)/\d{4}/\d{2}/\d{2}/\d{6}|notes/[^/]+)/>
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

  done_testing;
}

main;
