#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;

use HTML5::DOM;
use JSON::XS;

use Kalaclista::Constants;
use Kalaclista::Entry;
use Kalaclista::Files;

my $posts = Kalaclista::Constants->rootdir(qr{^t$})->child('public/dist/posts')->path;

my $parser = HTML5::DOM->new( { scripts => 1 } );

sub main {
  my @files = grep { $_ =~ m</\d{4}/index.html$> } Kalaclista::Files->find($posts);

  for my $path (@files) {
    my $href = $path;
    $href =~ s{.+?(\d{4})/index\.html$}{https://the.kalaclista.com/posts/$1/};

    my $file = Kalaclista::Path->new( path => $path );
    my $html = $file->get;
    utf8::decode($html);

    my $dom = $parser->parse($html);

    # html > head
    is(
      $dom->at('link[rel="alternate"][type="application/rss+xml"]')->getAttribute('title'),
      'カラクリスタ・ブログの RSS フィード',
    );

    is(
      $dom->at('link[rel="alternate"][type="application/rss+xml"]')->getAttribute('href'),
      'https://the.kalaclista.com/posts/index.xml'
    );

    is(
      $dom->at('link[rel="alternate"][type="application/atom+xml"]')->getAttribute('title'),
      'カラクリスタ・ブログの Atom フィード',
    );

    is(
      $dom->at('link[rel="alternate"][type="application/atom+xml"]')->getAttribute('href'),
      'https://the.kalaclista.com/posts/atom.xml'
    );

    is(
      $dom->at('link[rel="alternate"][type="application/feed+json"]')->getAttribute('title'),
      'カラクリスタ・ブログの JSON フィード',
    );

    is(
      $dom->at('link[rel="alternate"][type="application/feed+json"]')->getAttribute('href'),
      'https://the.kalaclista.com/posts/jsonfeed.json'
    );

    my $year    = ( $href =~ m{posts/(\d{4})/} )[0];
    my $title   = "${year}年の記事一覧";
    my $website = "カラクリスタ・ブログ";
    my $summary = "${website}の ${title}です";

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

          'mainEntityOfPage' => "https://the.kalaclista.com/posts/",

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
              'item'     => 'https://the.kalaclista.com/posts/',
              'name'     => 'カラクリスタ・ブログ',
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
    is( $dom->at('.entry__archives h1 a')->textContent,          "カラクリスタ・ブログ" );
    is( $dom->at('.entry__archives h1 a')->getAttribute('href'), "https://the.kalaclista.com/posts/" );

    is( $dom->at('.entry__archives .entry__content p')->textContent, '『輝かしい青春』なんて失かった人のブログです' );

    is( $dom->at('.entry__archives .entry__content p + hr + strong')->textContent, "${year}年：" );

    for my $item ( $dom->find('.archives ul li')->@* ) {
      like( $item->at('time')->getAttribute('datetime'),              qr<\d{4}-\d{2}-\d{2}> );
      like( $item->at('time')->getAttribute('datetime')->textContent, qr<\d{4}-\d{2}-\d{2}：> );

      like( $item->at('a')->getAttribute('href'), qr<https://the\.kalaclista\.com/\d{4}/\d{2}/\d{2}/\d{6}/> );
    }

    is(
      $dom->at('.entry__archives .entry__content .archives + hr + p')->textContent,
      "過去ログ：" . ( join q{ / }, sort { $b <=> $a } ( 2006 .. 2022 ) )
    );

    for my $yr ( 2006 .. 2022 ) {
      if ( $year == $yr ) {
        ok( $dom->at('.entry__archives .entry__content .archives + hr + p strong') );
        next;
      }

      is(
        $dom->at(".entry__archives .entry__content .archives + hr + p a[href\$='${yr}/']")->getAttribute('href'),
        "https://the.kalaclista.com/posts/${yr}/"
      );
    }
  }

  my $file = Kalaclista::Constants->rootdir(qr{^t$})->child('public/dist/posts/index.html');
  my $href = "https://the.kalaclista.com/posts/";

  my $html = $file->get;
  utf8::decode($html);

  my $dom = $parser->parse($html);

  # html > head
  is(
    $dom->at('link[rel="alternate"][type="application/rss+xml"]')->getAttribute('title'),
    'カラクリスタ・ブログの RSS フィード',
  );

  is(
    $dom->at('link[rel="alternate"][type="application/rss+xml"]')->getAttribute('href'),
    'https://the.kalaclista.com/posts/index.xml'
  );

  is(
    $dom->at('link[rel="alternate"][type="application/atom+xml"]')->getAttribute('title'),
    'カラクリスタ・ブログの Atom フィード',
  );

  is(
    $dom->at('link[rel="alternate"][type="application/atom+xml"]')->getAttribute('href'),
    'https://the.kalaclista.com/posts/atom.xml'
  );

  is(
    $dom->at('link[rel="alternate"][type="application/feed+json"]')->getAttribute('title'),
    'カラクリスタ・ブログの JSON フィード',
  );

  is(
    $dom->at('link[rel="alternate"][type="application/feed+json"]')->getAttribute('href'),
    'https://the.kalaclista.com/posts/jsonfeed.json'
  );

  my $year    = (localtime)[5] + 1900;
  my $title   = "カラクリスタ・ブログ";
  my $website = "カラクリスタ・ブログ";
  my $summary = "『輝かしい青春』なんて失かった人のブログです";

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
            'item'     => 'https://the.kalaclista.com/posts/',
            'name'     => 'カラクリスタ・ブログ',
            'position' => 2,
          }
        ],
      }
    ]
  );

  # html > body
  is( $dom->at('.entry__archives h1 a')->textContent,          "カラクリスタ・ブログ" );
  is( $dom->at('.entry__archives h1 a')->getAttribute('href'), "https://the.kalaclista.com/posts/" );

  is( $dom->at('.entry__archives .entry__content p')->textContent, '『輝かしい青春』なんて失かった人のブログです' );

  is( $dom->at('.entry__archives .entry__content p + hr + strong')->textContent, "${year}年：" );

  for my $item ( $dom->find('.archives ul li')->@* ) {
    like( $item->at('time')->getAttribute('datetime'),              qr<\d{4}-\d{2}-\d{2}> );
    like( $item->at('time')->getAttribute('datetime')->textContent, qr<\d{4}-\d{2}-\d{2}：> );

    like( $item->at('a')->getAttribute('href'), qr<https://the\.kalaclista\.com/\d{4}/\d{2}/\d{2}/\d{6}/> );
  }

  is(
    $dom->at('.entry__archives .entry__content .archives + hr + p')->textContent,
    "過去ログ：" . ( join q{ / }, sort { $b <=> $a } ( 2006 .. 2022 ) )
  );

  for my $yr ( 2006 .. 2022 ) {
    if ( $year == $yr ) {
      ok( $dom->at('.entry__archives .entry__content .archives + hr + p strong') );
      next;
    }

    is(
      $dom->at(".entry__archives .entry__content .archives + hr + p a[href\$='${yr}/']")->getAttribute('href'),
      "https://the.kalaclista.com/posts/${yr}/"
    );
  }

  done_testing;
}

main;
