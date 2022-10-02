#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use HTML5::DOM;
use JSON::Tiny qw(decode_json);

use Kalaclista::Directory;

my $dist   = Kalaclista::Directory->instance->distdir;
my $parser = HTML5::DOM->new( { script => 1 } );

sub jsonld {
  my $data = shift;

  my $self = $data->[0];

  is( $self->{'@id'},             'https://the.kalaclista.com/' );
  is( $self->{'headline'},        'カラクリスタ' );
  is( $self->{'@type'},           'WebSite' );
  is( $self->{'mainEntryOfPage'}, { '@id' => 'https://the.kalaclista.com/' } );
}

sub main {
  my $file = $dist->child('index.html');
  my $dom  = $parser->parse( $file->slurp_utf8 );

  # title
  is( $dom->at('title')->textContent, 'カラクリスタ' );
  is(
    $dom->at('meta[property="og:site_name"]')->getAttribute('content'),
    $dom->at('title')->textContent,
  );

  is(
    $dom->at('meta[property="og:title"]')->getAttribute('content'),
    $dom->at('title')->textContent,
  );
  is(
    $dom->at('meta[name="twitter:title"]')->getAttribute('content'),
    $dom->at('title')->textContent,
  );

  # description
  is(
    $dom->at('meta[name="description"]')->getAttribute('content'),
    '『輝かしい青春』なんて失かった人の Web サイトです。'
  );

  is(
    $dom->at('meta[name="description"]')->getAttribute('content'),
    $dom->at('meta[property="og:description"]')->getAttribute('content'),
  );

  is(
    $dom->at('meta[name="twitter:description"]')->getAttribute('content'),
    $dom->at('meta[property="og:description"]')->getAttribute('content'),
  );

  # permalink
  is(
    $dom->at('link[rel="canonical"]')->getAttribute('href'),
    'https://the.kalaclista.com/',
  );

  is(
    $dom->at('meta[property="og:url"]')->getAttribute('content'),
    $dom->at('link[rel="canonical"]')->getAttribute('href')
  );

  # metadata
  is(
    $dom->at('meta[property="og:type"]')->getAttribute('content'),
    "website"
  );

  is(
    $dom->at('meta[name="twitter:card"]')->getAttribute('content'),
    "summary"
  );

  is(
    $dom->at('meta[name="twitter:site"]')->getAttribute('content'),
    '@kalaclista'
  );

  # image
  is(
    $dom->at('meta[property="og:image"]')->getAttribute('content'),
    "https://the.kalaclista.com/assets/avatar.png"
  );

  is(
    $dom->at('meta[name="twitter:image"]')->getAttribute('content'),
    "https://the.kalaclista.com/assets/avatar.png"
  );

  my $jsonld = $dom->at('script[type="application/ld+json"]')->textContent;
  utf8::encode($jsonld);
  jsonld( decode_json($jsonld) );

  # contents
  is(
    $dom->at('.entry__home .entry__content p:first-child a')->getAttribute('href'),
    'https://the.kalaclista.com/nyarla/'
  );

  my $list = $dom->at('.entry__home .entry__content h1:nth-child(4) ~ ul');

  is(
    $list->at('li:nth-child(1) a')->getAttribute('href'),
    'https://the.kalaclista.com/posts/',
  );

  is(
    $list->at('li:nth-child(2) a')->getAttribute('href'),
    'https://the.kalaclista.com/echos/',
  );

  is(
    $list->at('li:nth-child(3) a')->getAttribute('href'),
    'https://the.kalaclista.com/notes/',
  );

  my $feeds = $dom->at('.entry__home .entry__content h1:nth-child(4) ~ ul ~ ul');

  is(
    $feeds->at('li:nth-child(1) a:nth-child(1)')->getAttribute('href'),
    'https://the.kalaclista.com/index.xml',
  );

  is(
    $feeds->at('li:nth-child(1) a:nth-child(2)')->getAttribute('href'),
    'https://the.kalaclista.com/atom.xml',
  );

  is(
    $feeds->at('li:nth-child(1) a:nth-child(3)')->getAttribute('href'),
    'https://the.kalaclista.com/jsonfeed.json',
  );

  is(
    $feeds->at('li:nth-child(2) a:nth-child(1)')->getAttribute('href'),
    'https://the.kalaclista.com/posts/index.xml',
  );

  is(
    $feeds->at('li:nth-child(2) a:nth-child(2)')->getAttribute('href'),
    'https://the.kalaclista.com/posts/atom.xml',
  );

  is(
    $feeds->at('li:nth-child(2) a:nth-child(3)')->getAttribute('href'),
    'https://the.kalaclista.com/posts/jsonfeed.json',
  );

  is(
    $feeds->at('li:nth-child(3) a:nth-child(1)')->getAttribute('href'),
    'https://the.kalaclista.com/echos/index.xml',
  );

  is(
    $feeds->at('li:nth-child(3) a:nth-child(2)')->getAttribute('href'),
    'https://the.kalaclista.com/echos/atom.xml',
  );

  is(
    $feeds->at('li:nth-child(3) a:nth-child(3)')->getAttribute('href'),
    'https://the.kalaclista.com/echos/jsonfeed.json',
  );

  is(
    $feeds->at('li:nth-child(4) a:nth-child(1)')->getAttribute('href'),
    'https://the.kalaclista.com/notes/index.xml',
  );

  is(
    $feeds->at('li:nth-child(4) a:nth-child(2)')->getAttribute('href'),
    'https://the.kalaclista.com/notes/atom.xml',
  );

  is(
    $feeds->at('li:nth-child(4) a:nth-child(3)')->getAttribute('href'),
    'https://the.kalaclista.com/notes/jsonfeed.json',
  );

  for my $item ( $dom->find('.entry__home .entry__content ul.archives')->@* ) {
    is(
      $item->at('li time')->getAttribute('datetime'),
      $item->at('li time')->textContent,
    );

    like(
      $item->at('li a:not(.title)')->getAttribute('href'),
      qr<https://the\.kalaclista\.com/(?:posts|echos|notes)/>
    );

    like( $item->at('li a:not(.title)')->textContent, qr<ブログ|日記|メモ帳> );

    like(
      $item->at('li a.title')->getAttribute('href'),
      qr<https://the\.kalaclista\.com/(?:(?:posts|echos)/\d{4}/\d{2}/\d{2}/\d{6}|notes/[^/]+)/>
    );
  }

  my $contact = $dom->at('.entry__home .entry__content ul.archives ~ ul');

  is(
    $contact->at('li:nth-child(1) a')->getAttribute('href'),
    'mailto:nyarla@kalaclista.com'
  );

  is(
    $contact->at('li:nth-child(2) a')->getAttribute('href'),
    'https://twitter.com/kalaclista/'
  );

  done_testing;
}

main;
