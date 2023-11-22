#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;

use HTML5::DOM;
use JSON::XS;
use URI::Escape qw(uri_escape_utf8);

use Kalaclista::Entry;
use Kalaclista::Files;

use WebSite::Context;
local $ENV{'KALACLISTA_ENV'} = 'production';

my $posts  = WebSite::Context->init(qr{^t$})->dirs->dist('notes')->path;
my $parser = HTML5::DOM->new( { scripts => 1 } );

sub main {
  my @files = grep { $_ =~ m</notes/[^/]+/index.html> } Kalaclista::Files->find($posts);

  for my $path (@files) {
    my $href = $path;
    utf8::decode($href);
    $href =~ s{.+?notes/([^/]+)/index\.html$}{"https://the.kalaclista.com/notes/" . uri_escape_utf8($1) . "/"}e;

    my $file = Kalaclista::Path->new( path => $path );
    my $html = $file->get;
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

    my $title   = $dom->at('.entry header h1')->textContent;
    my $website = 'カラクリスタ・ノート';

    is( $dom->at('title')->textContent, "${title} - ${website}" );
    ok( $dom->at('meta[name="description"]')->getAttribute('content') ne q{} );
    is( $dom->at('link[rel="canonical"]')->getAttribute('href'), $href );

    is( $dom->at('meta[property="og:title"]')->getAttribute('content'), $title );
    is( $dom->at('meta[property="og:type"]')->getAttribute('content'),  'article' );
    is( $dom->at('meta[property="og:image"]')->getAttribute('content'), 'https://the.kalaclista.com/assets/avatar.png' );
    is( $dom->at('meta[property="og:url"]')->getAttribute('content'),   $href );

    ok( $dom->at('meta[property="og:description"]')->getAttribute('content') ne q{} );
    is( $dom->at('meta[property="og:locale"]')->getAttribute('content'),    'ja_JP' );
    is( $dom->at('meta[property="og:site_name"]')->getAttribute('content'), $website );

    like(
      $dom->at('meta[property="og:published_time"]')->getAttribute('content'),
      qr<\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[-+]\d{2}:\d{2}|Z)>
    );
    like(
      $dom->at('meta[property="og:modified_time"]')->getAttribute('content'),
      qr<\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[-+]\d{2}:\d{2}|Z)>
    );

    is( $dom->at('meta[property="og:author:first_name"]')->getAttribute('content'), 'Naoki' );
    is( $dom->at('meta[property="og:author:last_name"]')->getAttribute('content'),  'OKAMURA' );
    is( $dom->at('meta[property="og:section"]')->getAttribute('content'),           'notes' );

    my $json = $dom->at('script[type="application/ld+json"]')->textContent;
    utf8::encode($json);
    my $payload = JSON::XS::decode_json($json);

    is(
      $payload, [
        {
          '@context' => 'https://schema.org',
          '@id'      => $href,
          '@type'    => 'Article',
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

          'mainEntityOfPage' => "https://the.kalaclista.com/notes/",

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
            },
            {
              '@type'    => 'ListItem',
              'item'     => $href,
              'name'     => $title,
              'position' => 3,
            }
          ],
        }
      ],
    );

    # html > body
    like( $dom->at('.entry header p time')->getAttribute('datetime'), qr<\d{4}-\d{2}-\d{2}> );
    like( $dom->at('.entry header p time')->textContent,              qr<更新：\d{4}-\d{2}-\d{2}> );
    like( $dom->at('.entry header p span')->textContent,              qr<読了まで：約\d+分> );

    is( $dom->at('.entry header h1 a')->textContent,          $title );
    is( $dom->at('.entry header h1 a')->getAttribute('href'), $href );
  }

  done_testing;
}

main;
