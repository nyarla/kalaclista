#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Module::Load qw(load);

use Kalaclista::Constants;
use Kalaclista::Entries;
use Kalaclista::Path;
use Kalaclista::Variables;

use WebSite::Helper::Hyperlink qw(href);

my %generators = (
  'images'      => 'Kalaclista::Generators::WebP',
  'permalinks'  => 'Kalaclista::Generators::Page',
  'sitemap.xml' => 'Kalaclista::Generators::SitemapXML',
);

my $const = 'Kalaclista::Constants';

sub init {
  $const->baseURI( $ENV{'URL'} // 'https://the.kalaclista.com' );
  $const->rootdir(qr{^bin$});
  $const->vars(
    is_production => ( $const->baseURI->to_string eq 'https://the.kalaclista.com' ),
    website       => 'カラクリスタ',
    description   => '『輝かしい青春』なんて失かった人の Web サイトです',
    data          => {

      # FIXME
      'stylesheet'        => $const->rootdir->child('resources/assets/main.css')->get,
      'script'            => $const->rootdir->child('resources/assets/main.js')->get,
      'script.production' => $const->rootdir->child('resources/assets/ads.js')->get,
    },
    contains => {
      posts => {
        label       => 'ブログ',
        website     => 'カラクリスタ・ブログ',
        description => '『輝かしい青春』なんて失かった人のブログです'
      },
      echos => {
        label       => '日記',
        website     => 'カラクリスタ・エコーズ',
        description => '『輝かしい青春』なんて失かった人の日記です'
      },
      notes => {
        label       => 'メモ帳',
        website     => 'カラクリスタ・ノート',
        description => '『輝かしい青春』なんて失かった人のメモ帳です'
      },
    },
  );
}

sub fixup {
  my $entry = shift;

  my $path = $entry->href->path;

  if ( $entry->slug ne q{} ) {
    my $slug = $entry->slug;
    utf8::decode($slug);
    $slug =~ s{ }{-}g;
    $path = qq(/notes/${slug}/);
  }

  if ( $path =~ m{/index} ) {
    $path =~ s{/index}{/};
  }

  $entry->href->path($path);

  if ( $path =~ m{^/?(posts|notes|echos)/} ) {
    $entry->type($1);
  }
  else {
    $entry->type('pages');
  }

  # for my $extension (@extensions) {
  #   $entry->register($extension);
  # }

  return $entry;
}

sub transform {
}

sub main {
  my $action = shift;

  my $contents = $const->rootdir->child('content/entries');
  my $datadir  = $const->rootdir->child('content/data');
  my $distdir  = $const->rootdir->child('public/dist');
  my $images   = $const->rootdir->child('content/assets/images');

  my $entries = Kalaclista::Entries->instance( $contents->path );

  if ( $action eq 'sitemap.xml' ) {
    my $class = $generators{$action};
    load($class);

    return $class->generate(
      file    => $distdir->child('sitemap.xml'),
      entries => $entries,
    );
  }

  if ( $action eq 'images' ) {
    my $class = $generators{$action};
    load($class);

    return $class->generate(
      distdir => $distdir->child('images'),
      images  => $images,
      datadir => $datadir->child('pictures'),
      scales  => [ [ '1x', 700 ], [ '2x', 1400 ] ],
    );
  }

  if ( $action eq 'permalinks' ) {
    my $class = $generators{$action};
    load($class);

    my $year = shift;
    my @entries =
        grep { $_->date =~ m{^$year} }
        map { fixup($_) } $entries->entries->@*;

    for my $entry (@entries) {
      transform($entry);

      my $vars = $const->vars;
      $vars->title( $entry->title );
      $vars->summary( $entry->dom->at('*:first-child')->textContent . '……' );
      $vars->section( $entry->type );
      $vars->kind('permalink');
      $vars->entries( [$entry] );
      $vars->href( $entry->href );

      my @tree = (
        { name => 'カラクリスタ', href => $const->baseURI->to_string },
      );

      if ( $entry->type ne 'pages' ) {
        push @tree, +{
          name => $vars->contains->{ $entry->type }->{'website'},
          href => href( '/' . $entry->type . '/', $const->baseURI ),
        };
      }

      push @tree, +{
        name => $entry->title,
        href => $entry->href->to_string,
      };

      $vars->breadcrumb( \@tree );

      my $path = $entry->href->path;
      $path .= "index.html";

      my $out = $distdir->child($path);
      $class->generate(
        dist     => $out,
        template => 'WebSite::Templates::Permalink',
        vars     => $vars
      );
    }

    return 1;
  }

  return 1;
}

local $@;
eval {
  init;
  main(@ARGV);
};

if ($@) {
  die "application failed: ${@}";
}

exit 0;
