#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use HTML5::DOM;
use JSON::Tiny qw(decode_json);

use Kalaclista::Directory;
use Kalaclista::Sequential::Files;

my $dist   = Kalaclista::Directory->new->rootdir->child("dist");
my $parser = HTML5::DOM->new( { scripts => 1 } );

sub testing_jsonld {
  my $data = shift;

  my $self = $data->[0];

  # context
  is( $self->{'@context'}, 'https://schema.org' );

  # author
  is(
    $self->{'author'},
    {
      '@type' => 'Person',
      email   => 'nyarla@kalaclista.com',
      name    => 'OKAMURA Naoki aka nyarla'
    }
  );

  is(
    $self->{'publisher'},
    {
      '@type' => 'Organization',
      'logo'  => {
        '@type' => 'ImageObject',
        'url'   => {
          '@type' => 'URL',
          'url'   => 'https://the.kalaclista.com/assets/avatar.png'
        }
      },
      'name' => 'the.kalaclista.com'
    }
  );

  my $tree = $data->[1];
  is( $tree->{'@context'}, 'https://schema.org' );
  is( $tree->{'@type'},    'BreadcrumbList' );
  is(
    $tree->{'itemListElement'}->[0],
    {
      '@type'    => 'ListItem',
      'item'     => 'https://the.kalaclista.com/',
      'name'     => 'カラクリスタ',
      'position' => 1
    }
  );

}

sub testing {
  my $file = shift;
  my $dom  = $parser->parse( $file->slurp_utf8 );

  # Headers
  # =======

  # charset
  is( $dom->at('meta[charset]')->getAttribute('charset'), 'utf-8' );

  # feeds
  my $rss20  = $dom->at('link[rel="alternate"][type="application/rss+xml"]');
  my $atom   = $dom->at('link[rel="alternate"][type="application/atom+xml"]');
  my $jsfeed = $dom->at('link[rel="alternate"][type="application/feed+json"]');

  like( $rss20->getAttribute('href'),  qr"/(posts|echos|notes)/index.xml" );
  like( $atom->getAttribute('href'),   qr"/(posts|echos|notes)/atom.xml" );
  like( $jsfeed->getAttribute('href'), qr"/(posts|echos|notes)/jsonfeed.json" );

  # assets
  is(
    $dom->at('link[rel="manifest"]')->getAttribute('href'),
    q<https://the.kalaclista.com/manifest.webmanifest>,
  );

  is(
    $dom->at('link[rel="icon"]')->getAttribute('href'),
    q<https://the.kalaclista.com/favicon.ico>,
  );

  is( $dom->at('link[rel="icon"][type="image/svg+xml"]')->getAttribute('href'),
    q<https://the.kalaclista.com/icon.svg> );

  is(
    $dom->at('link[rel="apple-touch-icon"]')->getAttribute('href'),
    q<https://the.kalaclista.com/apple-touch-icon.png>
  );

  # prelolad
  is(
    $dom->at('meta[http-equiv="x-dns-prefetch-control"]')
      ->getAttribute('content'),
    "on"
  );

  is(
    $dom->at('link[rel="preload"][as="script"]')->getAttribute('href'),
    "https://cdn.skypack.dev/budoux",
  );

  is( $dom->at('link[rel="preload"][as="style"]')->getAttribute('href'),
    "https://cdn.skypack.dev/normalize.css" );

  # style and script
  is(
    $dom->at('meta[name="viewport"]')->getAttribute('content'),
    "width=device-width,minimum-scale=1,initial-scale=1",
  );

  is(
    $dom->at('script[type="module"]')->getAttribute('src'),
    "https://the.kalaclista.com/assets/script.js",
  );

  is(
    $dom->at('link[rel="stylesheet"][href^="https://cdn"]')
      ->getAttribute('href'),
    "https://cdn.skypack.dev/normalize.css",
  );

  is(
    $dom->at('link[rel="stylesheet"][href^="https://the"]')
      ->getAttribute('href'),
    "https://the.kalaclista.com/assets/stylesheet.css",
  );

  # jsonld
  my $jsonld = $dom->at('script[type="application/ld+json"]')->textContent;
  utf8::encode($jsonld);
  testing_jsonld( decode_json($jsonld) );

  # Contents
  # ========

  # header
  # ------

  # title
  is( $dom->at('#global p a')->textContent, 'カラクリスタ', );

  is( $dom->at('#global p a')->getAttribute('href'),
    'https://the.kalaclista.com/' );

  # profile
  is( $dom->at('#profile figure p a')->getAttribute('href'),
    'https://the.kalaclista.com/nyarla/' );

  is(
    $dom->at('#profile figure p a img')->getAttribute('src'),
    'https://the.kalaclista.com/assets/avatar.svg'
  );

  is( $dom->at('#profile figcaption a')->getAttribute('href'),
    'https://the.kalaclista.com/nyarla/' );

  is( $dom->at('#profile figcaption a')->textContent, 'にゃるら（カラクリスタ）' );

  is(
    $dom->at('#profile nav p a[href^="https://github"]')->getAttribute('href'),
    'https://github.com/nyarla/'
  );
  is( $dom->at('#profile nav p a[href^="https://github"]')->textContent,
    'GitHub' );

  is( $dom->at('#profile nav p a[href^="https://zenn"]')->getAttribute('href'),
    'https://zenn.dev/nyarla' );
  is( $dom->at('#profile nav p a[href^="https://zenn"]')->textContent,
    'Zenn.dev' );

  is(
    $dom->at('#profile nav p a[href^="https://lapras"]')->getAttribute('href'),
    'https://lapras.com/public/nyarla'
  );
  is( $dom->at('#profile nav p a[href^="https://lapras"]')->textContent,
    'Lapras' );

  is( $dom->at('#profile nav p a[href^="https://note"]')->getAttribute('href'),
    'https://note.com/kalaclista/' );
  is( $dom->at('#profile nav p a[href^="https://note"]')->textContent, 'note' );

  is(
    $dom->at('#profile nav p a[href^="https://twitter"]')->getAttribute('href'),
    'https://twitter.com/kalaclista'
  );
  is( $dom->at('#profile nav p a[href^="https://twitter"]')->textContent,
    'Twitter' );

  is(
    $dom->at('#profile nav p a[href^="https://user.topia"]')
      ->getAttribute('href'),
    'https://user.topia.tv/5R9Y'
  );
  is( $dom->at('#profile nav p a[href^="https://user.topia"]')->textContent,
    'トピア' );

  # navigation
  is( $dom->at('#menu .kind a:nth-child(1)')->getAttribute('href'),
    'https://the.kalaclista.com/posts/' );
  is( $dom->at('#menu .kind a:nth-child(1)')->textContent, 'ブログ' );

  is( $dom->at('#menu .kind a:nth-child(2)')->getAttribute('href'),
    'https://the.kalaclista.com/echos/' );
  is( $dom->at('#menu .kind a:nth-child(2)')->textContent, '日記' );

  is( $dom->at('#menu .kind a:nth-child(3)')->getAttribute('href'),
    'https://the.kalaclista.com/notes/' );
  is( $dom->at('#menu .kind a:nth-child(3)')->textContent, 'メモ帳' );

  is( $dom->at('#menu .links a:nth-child(1)')->getAttribute('href'),
    "https://the.kalaclista.com/policies/" );
  is( $dom->at('#menu .links a:nth-child(1)')->textContent, "運営方針" );

  is( $dom->at('#menu .links a:nth-child(2)')->getAttribute('href'),
    "https://the.kalaclista.com/licenses/" );
  is( $dom->at('#menu .links a:nth-child(2)')->textContent, "権利情報" );

  is( $dom->at('#menu .links a:nth-child(3)')->getAttribute('href'),
    "https://cse.google.com/cse?cx=018101178788962105892:toz3mvb2bhr#gsc.tab=0"
  );
  is( $dom->at('#menu .links a:nth-child(3)')->textContent, "検索" );

  # footer
  # ------

  # copyright
  is( $dom->at('#copyright p a')->getAttribute('href'),
    'https://the.kalaclista.com/nyarla/' );

  is(
    $dom->at('#copyright p')->textContent,
    qq{(C) 2006-@{[ (localtime)[5] + 1900 ]} OKAMURA Naoki aka nyarla},
  );
}

sub main {
  my $runner = Kalaclista::Sequential::Files->new(
    handle => \&testing,
    result => sub { done_testing },
  );

  $runner->run( $dist->stringify, '**', 'index.html' );
}

main;
