#!/usr/bin/env perl

use v5.38;
use utf8;

use feature qw(state);

use Test2::V0;
use HTML5::DOM;
use YAML::XS qw(Load);

use Kalaclista::Data::Entry;
use Kalaclista::Data::Page;
use Kalaclista::Data::WebSite;

use Kalaclista::HyperScript qw(head);

use WebSite::Context::WebSite qw(section);
use WebSite::Context::URI     qw(href);
use WebSite::Context::Path    qw(cachedir);

use WebSite::Helper::Digest qw(digest);

use WebSite::Widgets::Metadata qw(type rel feed cardinfo common feeds jsonld notfound);

my sub dom : prototype($) { state $dom ||= HTML5::DOM->new; $dom->parse(shift) }

subtest type => sub {
  my $tests = [
    { kind => 'permalink', section => 'posts', expect => 'BlogPosting' },
    { kind => 'permalink', section => 'echos', expect => 'BlogPosting' },
    { kind => 'permalink', section => 'notes', expect => 'Article' },
    { kind => 'permalink', section => 'pages', expect => 'WebPage' },

    { kind => 'index', section => 'posts', expect => 'Blog' },
    { kind => 'index', section => 'echos', expect => 'Blog' },
    { kind => 'index', section => 'notes', expect => 'WebSite' },
    { kind => 'index', section => 'pages', expect => 'WebSite' },

    { kind => 'home', section => 'posts', expect => 'Blog' },
    { kind => 'home', section => 'echos', expect => 'Blog' },
    { kind => 'home', section => 'notes', expect => 'WebSite' },
    { kind => 'home', section => 'pages', expect => 'WebSite' },
  ];

  for my $test ( $tests->@* ) {
    is type( $test->{'kind'}, $test->{'section'} ), $test->{'expect'};
  }
};

subtest rel => sub {
  is
      rel( stylesheet => 'https://example.com/main.css' )->to_string,
      '<link href="https://example.com/main.css" rel="stylesheet" />';

  is
      rel( alternate => 'https://example.com/atom.xml', 'application/atom+xml' )->to_string,
      '<link href="https://example.com/atom.xml" rel="alternate" type="application/atom+xml" />';
};

subtest feed => sub {
  my $tests = [
    { section => 'posts', title => 'カラクリスタ・ブログ' },
    { section => 'echos', title => 'カラクリスタ・エコーズ' },
    { section => 'notes', title => 'カラクリスタ・ノート' },
    { section => 'pages', title => 'カラクリスタ' },
  ];

  for my $test ( $tests->@* ) {
    my $title   = $test->{'title'};
    my $section = $test->{'section'};
    my ( $rss20, $atom, $json ) = feed $test->{'section'};
    my $prefix = $section ne q|pages| ? "/${section}" : "";

    is
        $rss20->to_string,
qq|<link href="@{[ href("$prefix/index.xml")->to_string ]}" rel="alternate" title="${title}の RSS フィード" type="application/rss+xml" />|;

    is
        $atom->to_string,
qq|<link href="@{[ href("$prefix/atom.xml")->to_string ]}" rel="alternate" title="${title}の Atom フィード" type="application/atom+xml" />|;

    is
        $json->to_string,
qq|<link href="@{[ href("$prefix/jsonfeed.json")->to_string ]}" rel="alternate" title="${title}の JSON フィード" type="application/feed+json" />|;
  }
};

subtest cardinfo => sub {
  my sub entry {
    my $section = shift;
    return Kalaclista::Data::Entry->new(
      title   => qq|これは ${section} のテスト記事です|,
      summary => qq|これは ${section} の概要です|,
      section => $section,
      draft   => !!0,
      date    => '2023-01-01T00:00:00Z',
      lastmod => '2024-01-01T00:00:00Z',
      href    => href('/posts/2023/01/01/000000/'),
    );
  }

  my sub page {
    my ( $kind, $section, $path, $website ) = @_;
    my $title   = $kind eq q|permalink| ? qq|これは ${section} のテスト記事です| : $website->title;
    my $summary = $kind eq q|permalink| ? qq|これは ${section} の概要です|    : $website->summary;
    my $entry   = entry $_->[1];

    my $page = Kalaclista::Data::Page->new(
      title   => $title,
      summary => $summary,
      kind    => $kind,
      section => $section,
      href    => href($path),
      entries => [$entry],
    );

    $page->breadcrumb->push(
      label   => 'カラクリスタ',
      title   => 'カラクリスタ',
      summary => '『輝かしい青春』なんて失かった人の Web サイトです',
      href    => href('/'),
    );

    if ( $page->section ne q{pages} ) {
      $page->breadcrumb->push(
        label   => $website->label,
        title   => $website->title,
        summary => $website->summary,
        href    => $website->href,
      );
    }

    if ( $kind eq q|permalink| ) {
      $page->breadcrumb->push(
        label   => section( $entry->section )->label,
        title   => $entry->title,
        summary => $entry->summary,
        href    => $entry->href,
      );
    }

    return $page;
  }

  my $tests = [
    (
      map {
        +{
          kind    => $_->[0],
          page    => page( $_->@*, section( $_->[1] ) ),
          website => section( $_->[1] ),
        },
      } (
        [qw|permalink posts /2023/01/01/000000/|],
        [qw|permalink echos /2023/01/01/000000/|],
        [qw|permalink notes /this-is-a-test/|],
        [qw|permalink pages /nyarla/|],
        [qw|index posts /2024/|],
        [qw|index echos /2024/|],
        [qw|home posts /posts/|],
        [qw|home echos /echos/|],
        [qw|home notes /notes/|],
        [qw|home pages /|],
      )
    )
  ];

  for my $test ( $tests->@* ) {
    my ( $kind, $page, $website ) = @{$test}{qw/ kind page website /};

    my $dom = dom( head( cardinfo $kind, $page, $website )->to_string )->at('head');

    my $title =
        $kind eq q|permalink|
        ? "これは @{[ $page->section ]} のテスト記事です - @{[ $website->title ]}"
        : $website->title;
    my $summary = $kind eq q|permalink| ? $page->summary : $website->summary;

    is $dom->at('title')->text,                                      $title;
    is $dom->at('meta[name="description"]')->attr('content'),        $summary;
    is $dom->at('meta[property="og:title"]')->attr('content'),       $page->title;
    is $dom->at('meta[property="og:site_name"]')->attr('content'),   $website->title;
    is $dom->at('meta[property="og:image"]')->attr('content'),       href('/assets/avatar.png')->to_string;
    is $dom->at('meta[property="og:url"]')->attr('content'),         $page->href->to_string;
    is $dom->at('meta[property="og:description"]')->attr('content'), $summary;
    is $dom->at('meta[property="og:locale"]')->attr('content'),      'ja_JP';

    is $dom->at('meta[name="twitter:card"]')->attr('content'),  'summary';
    is $dom->at('meta[name="twitter:site"]')->attr('content'),  '@kalaclista';
    is $dom->at('meta[name="twitter:title"]')->attr('content'), $title;
    is $dom->at('meta[name="twitter:description"]')->attr('content'), ( $kind eq q|permalink| ? $page->summary : $website->summary );
    is $dom->at('meta[name="twitter:image"]')->attr('content'), href('/assets/avatar.png')->to_string;

    my $jsonld = $dom->at('script[type="application/ld+json"]')->innerHTML;
    utf8::encode($jsonld);
    my $json = Load($jsonld);

    my $self       = $json->[0];
    my $breadcrumb = $json->[1];

    my $prefix = $page->section ne q{pages} ? "/@{[ $page->section ]}/" : "";

    is $self, +{
      '@context' => 'https://schema.org',
      '@id'      => $page->href->to_string,
      '@type'    => type( $page->kind, $page->section ),
      headline   => $page->title,
      author     => {
        '@type' => 'Person',
        name    => 'OKAMURA Naoki aka nyarla',
        email   => 'nyarla@kalaclista.com',
        url     => 'https://the.kalaclista.com/nyarla/',
      },
      publisher => {
        '@type' => 'Organization',
        logo    => {
          '@type'    => 'ImageObject',
          contentUrl => 'https://the.kalaclista.com/assets/avatar.png'
        },
      },
      image => href('/assets/avatar.png')->to_string,

      ( $kind ne 'home' ) ? ( mainEntityOfPage => href($prefix)->to_string ) : (),
    };

    my @breadcrumb = (
      {
        '@type'  => 'ListItem',
        name     => $page->breadcrumb->index(0)->title,
        item     => $page->breadcrumb->index(0)->href->to_string,
        position => 1,
      },
    );

    if ( $page->section ne 'pages' ) {
      push @breadcrumb, {
        '@type'  => 'ListItem',
        name     => $page->breadcrumb->index(1)->title,
        item     => $page->breadcrumb->index(1)->href->to_string,
        position => 2,
      };

      if ( $page->kind eq 'permalink' ) {
        push @breadcrumb, {
          '@type'  => 'ListItem',
          name     => $page->breadcrumb->index(2)->title,
          item     => $page->breadcrumb->index(2)->href->to_string,
          position => 3,
        };
      }
    }
    else {
      if ( $page->kind eq 'permalink' ) {
        push @breadcrumb, {
          '@type'  => 'ListItem',
          name     => $page->breadcrumb->index(1)->title,
          item     => $page->breadcrumb->index(1)->href->to_string,
          position => 2,
        };
      }
    }

    is $breadcrumb, +{
      '@context'      => 'https://schema.org',
      '@type'         => 'BreadcrumbList',
      itemListElement => [@breadcrumb],
    };

    if ( $kind eq q|permalink| ) {
      is $dom->at('meta[property="og:type"]')->attr('content'),              'article';
      is $dom->at('meta[property="og:published_time"]')->attr('content'),    $page->entries->[0]->date;
      is $dom->at('meta[property="og:modified_time"]')->attr('content'),     $page->entries->[0]->lastmod;
      is $dom->at('meta[property="og:section"]')->attr('content'),           $page->section;
      is $dom->at('meta[property="og:author:first_name"]')->attr('content'), 'Naoki';
      is $dom->at('meta[property="og:author:last_name"]')->attr('content'),  'OKAMURA';
    }
    else {
      is $dom->at('meta[property="og:type"]')->attr('content'),    'website';
      is $dom->at('meta[property="og:section"]')->attr('content'), $page->section;
      ok !$dom->at('meta[property="og:published_time"]');
      ok !$dom->at('meta[property="og:modified_time"]');
      ok !$dom->at('meta[property="og:author:first_name"]');
      ok !$dom->at('meta[property="og:author:last_name"]');
    }
  }
};

subtest common => sub {
  my $dom = dom( head(common)->to_string )->at('head');

  is $dom->at('meta[charset]')->attr('charset'),         'utf-8';
  is $dom->at('meta[name="viewport"]')->attr('content'), 'width=device-width,initial-scale=1';

  is $dom->at('link[rel="manifest"]')->attr('href'),         href('/manifest.webmanifest')->to_string;
  is $dom->at('link[rel="icon"]:not([type])')->attr('href'), href('/favicon.ico')->to_string;
  is $dom->at('link[rel="icon"][type]')->attr('href'),       href('/icon.svg')->to_string;
  is $dom->at('link[rel="icon"][type]')->attr('type'),       'image/svg+xml';
  is $dom->at('link[rel="author"]')->attr('href'),           'http://www.hatena.ne.jp/nyarla-net/';
  is $dom->at('link[rel="stylesheet"]')->attr('href'),
      href(qq|/main-@{[ digest(cachedir->child('css/main.css')->path) ]}.css|)->to_string;
};

subtest feeds => sub {
  for my $section (qw|posts echos notes pages|) {
    my $prefix = $section ne q|pages| ? "/${section}" : "";
    my $dom    = dom( head( feeds $section )->to_string )->at('head');

    is $dom->at('link[rel="alternate"][type="application/rss+xml"]')->attr('href'),   href("${prefix}/index.xml")->to_string;
    is $dom->at('link[rel="alternate"][type="application/atom+xml"]')->attr('href'),  href("${prefix}/atom.xml")->to_string;
    is $dom->at('link[rel="alternate"][type="application/feed+json"]')->attr('href'), href("${prefix}/jsonfeed.json")->to_string;
  }
};

subtest notfound => sub {
  my $page = Kalaclista::Data::Page->new(
    title   => q{404 not found},
    summary => q{},
    kind    => "404",
    section => q{},
    href    => href("/"),
    entries => [],
  );

  my $dom = dom( head( notfound($page) )->to_string )->at('head');

  is $dom->at('title')->text,                               '404 not found - カラクリスタ';
  is $dom->at('meta[name="description"]')->attr('content'), 'ページが見つかりません';
};

done_testing;
