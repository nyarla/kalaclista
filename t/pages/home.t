#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use HTML5::DOM;
use JSON::XS;

use Kalaclista::Path;

my $parser = HTML5::DOM->new( { scripts => 1 } );

sub main {
  my $html = Kalaclista::Path->detect(qr{^t$})->child('public/dist/index.html')->get;
  utf8::decode($html);
  my $dom = $parser->parse($html);

  # html > head
  is(
    $dom->at('link[rel="alternate"][type="application/rss+xml"]')->getAttribute('title'),
    'カラクリスタの RSS フィード',
  );

  is(
    $dom->at('link[rel="alternate"][type="application/rss+xml"]')->getAttribute('href'),
    'https://the.kalaclista.com/index.xml'
  );

  is(
    $dom->at('link[rel="alternate"][type="application/atom+xml"]')->getAttribute('title'),
    'カラクリスタの Atom フィード',
  );

  is(
    $dom->at('link[rel="alternate"][type="application/atom+xml"]')->getAttribute('href'),
    'https://the.kalaclista.com/atom.xml'
  );

  is(
    $dom->at('link[rel="alternate"][type="application/feed+json"]')->getAttribute('title'),
    'カラクリスタの JSON フィード',
  );

  is(
    $dom->at('link[rel="alternate"][type="application/feed+json"]')->getAttribute('href'),
    'https://the.kalaclista.com/jsonfeed.json'
  );

  my $title   = $dom->at('.entry header h1')->textContent;
  my $website = 'カラクリスタ';
  my $summary = '『輝かしい青春』なんて失かった人の Web サイトです';
  my $href    = 'https://the.kalaclista.com/';

  is( $dom->at('title')->textContent,                                "${website}" );
  is( $dom->at('meta[name="description"]')->getAttribute('content'), $summary );
  is( $dom->at('link[rel="canonical"]')->getAttribute('href'),       $href );

  is( $dom->at('meta[property="og:title"]')->getAttribute('content'), $website );
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

        'headline' => $website,
        'image'    => {
          '@type'      => 'ImageObject',
          'contentUrl' => 'https://the.kalaclista.com/assets/avatar.png'
        },

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
        ],
      }
    ]
  );

  # html > body
  is(
    $dom->at('.entry__home .entry__content p:first-child a')->getAttribute('href'),
    'https://the.kalaclista.com/nyarla/'
  );

  my $list = $dom->at('.entry__home .entry__content h2:nth-child(4) ~ ul');

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

  my $feeds = $dom->at('.entry__home .entry__content h2:nth-child(4) ~ ul ~ ul');

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
