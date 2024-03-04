#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use HTML5::DOM;
use JSON::XS;
use URI::Fast;
use Text::HyperScript::HTML5 qw(head);

use Kalaclista::Entry;
use Kalaclista::Data::Page;

use WebSite::Widgets::Metadata;
use WebSite::Helper::Hyperlink qw(href);

use WebSite::Context;
local $ENV{'KALACLISTA_ENV'} = 'production';
WebSite::Context->init(qr{^t$});
WebSite::Context->instance->website(
  title => 'カラクリスタ',
);
WebSite::Context->instance->sections(
  posts => { title => 'カラクリスタ・ブログ' },
  echos => { title => 'カラクリスタ・エコーズ' },
  notes => { title => 'カラクリスタ・ノート' },
);

my $parser = HTML5::DOM->new( { scripts => 1 } );

sub testing_types {
  for my $section (qw(posts echos notes pages others)) {
    for my $kind (qw( permalink others )) {
      my $type = WebSite::Widgets::Metadata::types( $kind, $section );

      if ( $kind eq 'permalink' ) {
        if ( $section eq 'posts' ) {
          is( $type, 'BlogPosting' );
          next;
        }

        if ( $section eq 'echos' ) {
          is( $type, 'BlogPosting' );
          next;
        }

        if ( $section eq 'notes' ) {
          is( $type, 'Article' );
          next;
        }

        if ( $section eq 'pages' ) {
          is( $type, 'WebPage' );
          next;
        }

        is( $type, 'WebPage' );
      }
      else {
        if ( $section eq 'posts' ) {
          is( $type, 'Blog' );
          next;
        }

        if ( $section eq 'echos' ) {
          is( $type, 'Blog' );
          next;
        }

        if ( $section eq 'notes' ) {
          is( $type, 'WebSite' );
          next;
        }

        if ( $section eq 'pages' ) {
          is( $type, 'WebSite' );
          next;
        }

        is( $type, 'WebSite' );
      }
    }
  }
}

sub testing_global {
  my $page   = Kalaclista::Data::Page->new;
  my $global = head( WebSite::Widgets::Metadata::global($page) );
  utf8::decode($global);

  my $dom = $parser->parse($global)->at('head');

  is( $dom->at('meta[charset]')->getAttribute('charset'), 'utf-8' );
  is(
    $dom->at('meta[name="viewport"]')->getAttribute('content'),
    'width=device-width,minimum-scale=1,initial-scale=1',
  );

  is( $dom->at('link[rel="manifest"]')->getAttribute('href'),                          'https://the.kalaclista.com/manifest.webmanifest' );
  is( $dom->at('link[rel="icon"][type="images/svg+xml"]')->getAttribute('href'),       'https://the.kalaclista.com/icon.svg' );
  is( $dom->at('link[rel="icon"]:not([type="images/svg+xml"])')->getAttribute('href'), 'https://the.kalaclista.com/favicon.ico' );
  is( $dom->at('link[rel="apple-touch-icon"]')->getAttribute('href'),                  'https://the.kalaclista.com/apple-touch-icon.png' );
  is( $dom->at('link[rel="author"]')->getAttribute('href'),                            'http://www.hatena.ne.jp/nyarla-net/' );

  my $global2 = head( WebSite::Widgets::Metadata::global($page) );
  utf8::decode($global2);

  is( $global, $global2 );
}

sub testing_in_section {
  my %websites = (
    posts => 'カラクリスタ・ブログ',
    echos => 'カラクリスタ・エコーズ',
    notes => 'カラクリスタ・ノート',
  );

  for my $section (qw(posts echos notes pages)) {
    my $page = Kalaclista::Data::Page->new(
      section => $section,
    );

    my $head = head( WebSite::Widgets::Metadata::in_section($page) );
    utf8::decode($head);

    my $dom   = $parser->parse($head)->at('head');
    my $title = exists $websites{$section} ? $websites{$section} : WebSite::Context->instance->website->title;

    is(
      $dom->at('link[rel="alternate"][type="application/rss+xml"]')->getAttribute('title'),
      "${title}の RSS フィード",
    );
    is(
      $dom->at('link[rel="alternate"][type="application/atom+xml"]')->getAttribute('title'),
      "${title}の Atom フィード",
    );
    is(
      $dom->at('link[rel="alternate"][type="application/feed+json"]')->getAttribute('title'),
      "${title}の JSON フィード",
    );

    if ( $section ne q{pages} ) {
      is(
        $dom->at('link[rel="alternate"][type="application/rss+xml"]')->getAttribute('href'),
        "https://the.kalaclista.com/${section}/index.xml",
      );
      is(
        $dom->at('link[rel="alternate"][type="application/atom+xml"]')->getAttribute('href'),
        "https://the.kalaclista.com/${section}/atom.xml",
      );
      is(
        $dom->at('link[rel="alternate"][type="application/feed+json"]')->getAttribute('href'),
        "https://the.kalaclista.com/${section}/jsonfeed.json",
      );
    }
    else {
      is(
        $dom->at('link[rel="alternate"][type="application/rss+xml"]')->getAttribute('href'),
        "https://the.kalaclista.com/index.xml",
      );
      is(
        $dom->at('link[rel="alternate"][type="application/atom+xml"]')->getAttribute('href'),
        "https://the.kalaclista.com/atom.xml",
      );
      is(
        $dom->at('link[rel="alternate"][type="application/feed+json"]')->getAttribute('href'),
        "https://the.kalaclista.com/jsonfeed.json",
      );
    }

    my $head2 = head( WebSite::Widgets::Metadata::in_section($page) );
    utf8::decode($head2);

    is( $head, $head2 );
  }
}

sub testing_page_on_permalink {
  my %global = (
    is_production => 1,
    website       => 'カラクリスタ',
    description   => '『輝かしい青春』なんて失かった人の Web サイトです',
    contains      => {
      posts => {
        label       => 'ブログ',
        website     => 'カラクリスタ・ブログ',
        description => '『輝かしい青春』なんて失かった人のブログです'
      },
    },
    data => {},
  );

  my $c       = WebSite::Context->instance;
  my $content = $c->entries->parent->child("precompiled/posts/2022/01/05/131308.md")->load;
  utf8::decode($content);

  my $entry = Kalaclista::Entry->new(
    path => $c->entries->child('posts/2022/01/05/131308.md'),
    href => URI::Fast->new( href( '/posts/2022/01/05/131308/', $c->baseURI ) ),
  );

  $entry->load if !$entry->loaded;
  $entry->src($content);

  my $permalink = Kalaclista::Data::Page->new(
    title   => $entry->title,
    summary => $entry->dom->at('*:first-child')->textContent . '……',
    section => 'posts',
    kind    => 'permalink',
    entries => [$entry],
    href    => URI::Fast->new( $entry->href ),
  );

  $permalink->breadcrumb->push(
    title     => 'カラクリスタ',
    permalink => WebSite::Context->instance->baseURI->to_string,
  );

  $permalink->breadcrumb->push(
    title     => $global{'contains'}->{'posts'}->{'website'},
    permalink => 'https://the.kalaclista.com/posts/',
  );

  $permalink->breadcrumb->push(
    title     => $entry->title,
    permalink => $entry->href->to_string,
  );

  my $head = head( WebSite::Widgets::Metadata::page($permalink) );
  utf8::decode($head);

  my $dom = $parser->parse($head)->at('head');

  is( $dom->at('title')->textContent,                                $entry->title . ' - ' . 'カラクリスタ・ブログ' );
  is( $dom->at('meta[name="description"]')->getAttribute('content'), $entry->dom->at('*:first-child')->textContent . "……" );

  is( $dom->at('link[rel="canonical"]')->getAttribute('href'), 'https://the.kalaclista.com/posts/2022/01/05/131308/' );

  is( $dom->at('meta[property="og:title"]')->getAttribute('content'),     $entry->title );
  is( $dom->at('meta[property="og:site_name"]')->getAttribute('content'), 'カラクリスタ・ブログ' );
  is( $dom->at('meta[property="og:image"]')->getAttribute('content'),     'https://the.kalaclista.com/assets/avatar.png' );
  is( $dom->at('meta[property="og:url"]')->getAttribute('content'),       $entry->href->to_string );

  is( $dom->at('meta[property="og:type"]')->getAttribute('content'),           'article' );
  is( $dom->at('meta[property="og:published_time"]')->getAttribute('content'), $entry->date );
  is( $dom->at('meta[property="og:modified_time"]')->getAttribute('content'),  $entry->updated );
  is( $dom->at('meta[property="og:section"]')->getAttribute('content'),        'posts' );

  is( $dom->at('meta[name="twitter:card"]')->getAttribute('content'),        'summary' );
  is( $dom->at('meta[name="twitter:site"]')->getAttribute('content'),        '@kalaclista' );
  is( $dom->at('meta[name="twitter:title"]')->getAttribute('content'),       $entry->title . ' - ' . 'カラクリスタ・ブログ' );
  is( $dom->at('meta[name="twitter:description"]')->getAttribute('content'), $entry->dom->at('*:first-child')->textContent . '……' );
  is( $dom->at('meta[name="twitter:image"]')->getAttribute('content'),       'https://the.kalaclista.com/assets/avatar.png' );

  my $json = $dom->at('script[type="application/ld+json"]')->textContent;
  utf8::encode($json);
  my $payload = JSON::XS::decode_json($json);

  is(
    $payload, [
      {
        '@context' => 'https://schema.org',
        '@id'      => 'https://the.kalaclista.com/posts/2022/01/05/131308/',
        '@type'    => 'BlogPosting',
        'author'   => {
          '@type' => 'Person',
          'email' => 'nyarla@kalaclista.com',
          'name'  => 'OKAMURA Naoki aka nyarla',
          'url'   => 'https://the.kalaclista.com/nyarla/'
        },

        'headline' => $entry->title,
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
            'item'     => 'https://the.kalaclista.com/posts/2022/01/05/131308/',
            'name'     => $entry->title,
            'position' => 3,
          }
        ],
      }
    ]
  );
}

sub main {
  testing_types;
  testing_global;
  testing_in_section;
  testing_page_on_permalink;

  done_testing;
}

main;
