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

my $posts  = WebSite::Context->init(qr{^t$})->dist('echos')->path;
my $parser = HTML5::DOM->new( { scripts => 1 } );

sub main {
  my @files = sort { $b cmp $a } grep { $_ =~ m</\d{4}/index.html$> } Kalaclista::Files->find($posts);
  my $begin = ( $files[-1] =~ m{/(\d{4})/index.html$} )[0];
  my $end   = ( $files[0]  =~ m{/(\d{4})/index.html$} )[0];

  for my $path (@files) {
    my $href = $path;
    $href =~ s{.+?(\d{4})/index\.html$}{https://the.kalaclista.com/echos/$1/};

    my $file = Kalaclista::Path->new( path => $path );
    my $html = $file->get;
    utf8::decode($html);

    my $dom = $parser->parse($html);

    # html > head
    is(
      $dom->at('link[rel="alternate"][type="application/rss+xml"]')->getAttribute('title'),
      'カラクリスタ・エコーズの RSS フィード',
    );

    is(
      $dom->at('link[rel="alternate"][type="application/rss+xml"]')->getAttribute('href'),
      'https://the.kalaclista.com/echos/index.xml'
    );

    is(
      $dom->at('link[rel="alternate"][type="application/atom+xml"]')->getAttribute('title'),
      'カラクリスタ・エコーズの Atom フィード',
    );

    is(
      $dom->at('link[rel="alternate"][type="application/atom+xml"]')->getAttribute('href'),
      'https://the.kalaclista.com/echos/atom.xml'
    );

    is(
      $dom->at('link[rel="alternate"][type="application/feed+json"]')->getAttribute('title'),
      'カラクリスタ・エコーズの JSON フィード',
    );

    is(
      $dom->at('link[rel="alternate"][type="application/feed+json"]')->getAttribute('href'),
      'https://the.kalaclista.com/echos/jsonfeed.json'
    );

    my $year    = ( $href =~ m{echos/(\d{4})/} )[0];
    my $title   = "${year}年の記事一覧";
    my $website = "カラクリスタ・エコーズ";
    my $summary = "${website}の${title}です";

    is( $dom->at('title')->textContent,                                "${title} - ${website}" );
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
          '@type'    => 'Blog',
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

          'mainEntityOfPage' => "https://the.kalaclista.com/echos/",

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
              'item'     => 'https://the.kalaclista.com/echos/',
              'name'     => 'カラクリスタ・エコーズ',
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
      ]
    );

    # html > body
    is( $dom->at('.entry__archives h1 a')->textContent,          "カラクリスタ・エコーズ" );
    is( $dom->at('.entry__archives h1 a')->getAttribute('href'), "https://the.kalaclista.com/echos/" );

    is( $dom->at('.entry__archives .entry__content p')->textContent, '『輝かしい青春』なんて失かった人の日記です' );

    is( $dom->at('.entry__archives .entry__content p + hr + strong')->textContent, "${year}年：" );

    for my $item ( $dom->find('.archives ul li')->@* ) {
      like( $item->at('time')->getAttribute('datetime'),              qr<\d{4}-\d{2}-\d{2}> );
      like( $item->at('time')->getAttribute('datetime')->textContent, qr<\d{4}-\d{2}-\d{2}：> );

      like( $item->at('a')->getAttribute('href'), qr<https://the\.kalaclista\.com/\d{4}/\d{2}/\d{2}/\d{6}/> );
    }

    is(
      $dom->at('.entry__archives .entry__content .archives + hr + p')->textContent,
      "過去ログ：" . ( join q{/}, sort { $b <=> $a } ( $begin .. $end ) )
    );

    for my $yr ( $begin .. $end ) {
      if ( $year == $yr ) {
        ok( $dom->at('.entry__archives .entry__content .archives + hr + p strong') );
        next;
      }

      is(
        $dom->at(".entry__archives .entry__content .archives + hr + p a[href\$='${yr}/']")->getAttribute('href'),
        "https://the.kalaclista.com/echos/${yr}/"
      );
    }
  }

  my $file = WebSite::Context->init(qr{^t$})->dist('echos/index.html');
  my $href = "https://the.kalaclista.com/echos/";

  my $html = $file->get;
  utf8::decode($html);

  my $dom = $parser->parse($html);

  # html > head
  is(
    $dom->at('link[rel="alternate"][type="application/rss+xml"]')->getAttribute('title'),
    'カラクリスタ・エコーズの RSS フィード',
  );

  is(
    $dom->at('link[rel="alternate"][type="application/rss+xml"]')->getAttribute('href'),
    'https://the.kalaclista.com/echos/index.xml'
  );

  is(
    $dom->at('link[rel="alternate"][type="application/atom+xml"]')->getAttribute('title'),
    'カラクリスタ・エコーズの Atom フィード',
  );

  is(
    $dom->at('link[rel="alternate"][type="application/atom+xml"]')->getAttribute('href'),
    'https://the.kalaclista.com/echos/atom.xml'
  );

  is(
    $dom->at('link[rel="alternate"][type="application/feed+json"]')->getAttribute('title'),
    'カラクリスタ・エコーズの JSON フィード',
  );

  is(
    $dom->at('link[rel="alternate"][type="application/feed+json"]')->getAttribute('href'),
    'https://the.kalaclista.com/echos/jsonfeed.json'
  );

  my $year    = $end;
  my $title   = "カラクリスタ・エコーズ";
  my $website = "カラクリスタ・エコーズ";
  my $summary = "『輝かしい青春』なんて失かった人の日記です";

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
        '@type'    => 'Blog',
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
            'item'     => 'https://the.kalaclista.com/echos/',
            'name'     => 'カラクリスタ・エコーズ',
            'position' => 2,
          }
        ],
      }
    ]
  );

  # html > body
  is( $dom->at('.entry__archives h1 a')->textContent,          "カラクリスタ・エコーズ" );
  is( $dom->at('.entry__archives h1 a')->getAttribute('href'), "https://the.kalaclista.com/echos/" );

  is( $dom->at('.entry__archives .entry__content p')->textContent, '『輝かしい青春』なんて失かった人の日記です' );

  is( $dom->at('.entry__archives .entry__content p + hr + strong')->textContent, "${year}年：" );

  for my $item ( $dom->find('.archives ul li')->@* ) {
    like( $item->at('time')->getAttribute('datetime'),              qr<\d{4}-\d{2}-\d{2}> );
    like( $item->at('time')->getAttribute('datetime')->textContent, qr<\d{4}-\d{2}-\d{2}：> );

    like( $item->at('a')->getAttribute('href'), qr<https://the\.kalaclista\.com/\d{4}/\d{2}/\d{2}/\d{6}/> );
  }

  is(
    $dom->at('.entry__archives .entry__content .archives + hr + p')->textContent,
    "過去ログ：" . ( join q{/}, sort { $b <=> $a } ( $begin .. $end ) )
  );

  for my $yr ( $begin .. $end ) {
    if ( $year == $yr ) {
      ok( $dom->at('.entry__archives .entry__content .archives + hr + p strong') );
      next;
    }

    is(
      $dom->at(".entry__archives .entry__content .archives + hr + p a[href\$='${yr}/']")->getAttribute('href'),
      "https://the.kalaclista.com/echos/${yr}/"
    );
  }

  done_testing;
}

main;
