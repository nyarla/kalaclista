#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;

use HTML5::DOM;
use JSON::XS;

use Kalaclista::Entry;
use Kalaclista::Files;

use WebSite::Context;

my $parser = HTML5::DOM->new( { scripts => 1 } );

sub main {
  my $file = WebSite::Context->init(qr{^t$})->dist('notes/index.html');
  my $href = "https://the.kalaclista.com/notes/";

  my $html = $file->load;
  utf8::decode($html);

  my $dom = $parser->parse($html);

  # html > head
  is(
    $dom->at('link[rel="alternate"][type="application/rss+xml"]')->getAttribute('title'),
    'カラクリスタ・ノートの RSS フィード',
  );

  is(
    $dom->at('link[rel="alternate"][type="application/rss+xml"]')->getAttribute('href'),
    'https://the.kalaclista.com/notes/index.xml'
  );

  is(
    $dom->at('link[rel="alternate"][type="application/atom+xml"]')->getAttribute('title'),
    'カラクリスタ・ノートの Atom フィード',
  );

  is(
    $dom->at('link[rel="alternate"][type="application/atom+xml"]')->getAttribute('href'),
    'https://the.kalaclista.com/notes/atom.xml'
  );

  is(
    $dom->at('link[rel="alternate"][type="application/feed+json"]')->getAttribute('title'),
    'カラクリスタ・ノートの JSON フィード',
  );

  is(
    $dom->at('link[rel="alternate"][type="application/feed+json"]')->getAttribute('href'),
    'https://the.kalaclista.com/notes/jsonfeed.json'
  );

  my $title   = "カラクリスタ・ノート";
  my $website = "カラクリスタ・ノート";
  my $summary = "『輝かしい青春』なんて失かった人のメモ帳です";

  is( $dom->at('title')->textContent,                                "${website}" );
  is( $dom->at('meta[name="description"]')->getAttribute('content'), $summary );
  is( $dom->at('link[rel="canonical"]')->getAttribute('href'),       $href );

  is( $dom->at('meta[property="og:title"]')->getAttribute('content'), $title );
  is( $dom->at('meta[property="og:type"]')->getAttribute('content'),  'website' );
  is( $dom->at('meta[property="og:image"]')->getAttribute('content'), 'https://the.kalaclista.com/assets/avatar.png' );
  is( $dom->at('meta[property="og:url"]')->getAttribute('content'),   $href );

  is( $dom->at('meta[property="og:description"]')->getAttribute('content'), $summary );
  is( $dom->at('meta[property="og:locale"]')->getAttribute('content'),      'ja_JP' );
  is( $dom->at('meta[property="og:site_name"]')->getAttribute('content'),   $website );

  my $json = $dom->at('script[type="application/ld+json"]')->textContent;
  utf8::encode($json);
  my $payload = JSON::XS::decode_json($json);

  is(
    $payload, [
      {
        '@context' => 'https://schema.org',
        '@id'      => $href,
        '@type'    => 'WebSite',
        'author'   => {
          '@type' => 'Person',
          'email' => 'nyarla@kalaclista.com',
          'name'  => 'OKAMURA Naoki aka nyarla',
          'url'   => 'https://the.kalaclista.com/nyarla/'
        },

        'headline' => $title,
        'image'    => {
          '@type'      => 'ImageObject',
          'contentUrl' => 'https://the.kalaclista.com/assets/avatar.png'
        },

        'mainEntityOfPage' => "https://the.kalaclista.com",

        'publisher' => {
          '@type' => 'Organization',
          'logo'  => {
            '@type'      => 'ImageObject',
            'contentUrl' => 'https://the.kalaclista.com/assets/avatar.png',
          },
        },
      },
      {
        '@context'        => 'https://schema.org',
        '@type'           => 'BreadcrumbList',
        'itemListElement' => [
          {
            '@type'    => 'ListItem',
            'item'     => 'https://the.kalaclista.com',
            'name'     => 'カラクリスタ',
            'position' => 1,
          },
          {
            '@type'    => 'ListItem',
            'item'     => 'https://the.kalaclista.com/notes/',
            'name'     => 'カラクリスタ・ノート',
            'position' => 2,
          }
        ],
      }
    ]
  );

  # html > body
  is( $dom->at('.entry__archives h1 a')->textContent,          "カラクリスタ・ノート" );
  is( $dom->at('.entry__archives h1 a')->getAttribute('href'), "https://the.kalaclista.com/notes/" );

  is( $dom->at('.entry__archives .entry__content p')->textContent, '『輝かしい青春』なんて失かった人のメモ帳です' );

  for my $item ( $dom->find('.archives ul li')->@* ) {
    like( $item->at('time')->getAttribute('datetime'),              qr<\d{4}-\d{2}-\d{2}> );
    like( $item->at('time')->getAttribute('datetime')->textContent, qr<\d{4}-\d{2}-\d{2}：> );

    like( $item->at('a')->getAttribute('href'), qr<https://the\.kalaclista\.com/\d{4}/\d{2}/\d{2}/\d{6}/> );
  }

  done_testing;
}

main;
