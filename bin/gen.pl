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
  'home'        => 'Kalaclista::Generators::Page',
  'images'      => 'Kalaclista::Generators::WebP',
  'index'       => 'Kalaclista::Generators::Page',
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
      'stylesheet'        => $const->rootdir->child('public/bundle/main.css')->get,
      'script'            => $const->rootdir->child('public/bundle/main.js')->get,
      'script.production' => $const->rootdir->child('public/bundle/ads.js')->get,
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

  if ( $path =~ m{(posts|notes|echos)} ) {
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
  my $entry = shift;
  return $entry;
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

  if ( $action eq 'home' ) {
    my $class = $generators{$action};
    load($class);

    my %t;
    my @entries =
        map { transform($_) }
        ( sort { $b->date cmp $a->date } grep { $_->type =~ m{posts|echos|notes} } map { fixup($_) } $entries->entries->@* )[ 0 .. 10 ];

    my $vars = $const->vars;
    $vars->title( $vars->website );
    $vars->section('pages');
    $vars->kind('home');
    $vars->entries( \@entries );
    $vars->href( URI::Fast->new( href( "/", $const->baseURI ) ) );

    my @tree = (
      {
        name => 'カラクリスタ',
        href => $const->baseURI->to_string
      },
    );

    $vars->breadcrumb( \@tree );

    my $path = "/index.html";
    my $out  = $distdir->child($path);

    $class->generate(
      dist     => $out,
      template => 'WebSite::Templates::Home',
      vars     => $vars,
    );

    for my $feed (qw( index.xml atom.xml jsonfeed.json )) {
      $path = "${feed}";
      $out  = $distdir->child($path);
      my $tmpl =
          'WebSite::Templates::' . ( ( $feed eq 'index.xml' ) ? 'RSS20Feed' : ( $feed eq 'atom.xml' ) ? 'AtomFeed' : "JSONFeed" );

      $class->generate(
        dist     => $out,
        template => $tmpl,
        vars     => $vars,
      );
    }

    $vars->title('404 not found');
    $vars->description('ページが見つかりません');
    $vars->section('pages');
    $vars->kind('404');
    $vars->entries( [] );
    $vars->href(undef);
    $vars->breadcrumb( [] );

    $class->generate(
      dist     => $distdir->child('404.html'),
      template => 'WebSite::Templates::NotFound',
      vars     => $vars,
    );
  }

  if ( $action eq 'index' ) {
    my $class = $generators{$action};
    load($class);

    my $section = shift;

    if ( $section eq 'notes' ) {
      my @entries = map { transform($_) }
          grep { $_->type eq $section }
          map { fixup($_) } $entries->entries->@*;

      my $vars = $const->vars;
      $vars->title( $vars->contains->{$section}->{'website'} );
      $vars->summary( $vars->contains->{$section}->{'description'} );
      $vars->description( $vars->contains->{$section}->{'description'} );
      $vars->section($section);
      $vars->kind('index');
      $vars->entries( \@entries );
      $vars->href( URI::Fast->new( href( "/${section}/", $const->baseURI ) ) );

      my @tree = (
        {
          name => 'カラクリスタ',
          href => $const->baseURI->to_string
        },
        {
          name => $vars->contains->{$section}->{'website'},
          href => href( "/${section}/", $const->baseURI )
        },
      );

      $vars->breadcrumb( \@tree );

      my $path = "${section}/index.html";
      my $out  = $distdir->child($path);

      $class->generate(
        dist     => $out,
        template => 'WebSite::Templates::Index',
        vars     => $vars,
      );

      for my $feed (qw( index.xml atom.xml jsonfeed.json )) {
        $path = "${section}/${feed}";
        $out  = $distdir->child($path);
        my $tmpl =
            'WebSite::Templates::' . ( ( $feed eq 'index.xml' ) ? 'RSS20Feed' : ( $feed eq 'atom.xml' ) ? 'AtomFeed' : "JSONFeed" );

        $class->generate(
          dist     => $out,
          template => $tmpl,
          vars     => $vars,
        );
      }

      return 1;
    }

    for my $year ( 2006 .. ( (localtime)[5] + 1900 ) ) {
      my @entries = map { transform($_) }
          grep { $_->date =~ m{^$year} && $_->type eq $section }
          map { fixup($_) } $entries->entries->@*;

      if ( @entries == 0 ) {
        next;
      }

      my $vars = $const->vars;
      $vars->title("${year}年の記事一覧");
      $vars->summary( $vars->contains->{$section}->{'website'} . "の ${year}年の記事一覧です" );
      $vars->section($section);
      $vars->kind('index');
      $vars->entries( \@entries );
      $vars->href( URI::Fast->new( href( "/${section}/${year}/", $const->baseURI ) ) );

      my @tree = (
        {
          name => 'カラクリスタ',
          href => $const->baseURI->to_string
        },
        {
          name => $vars->contains->{$section}->{'website'},
          href => href( "/${section}/", $const->baseURI )
        },
        {
          name => $vars->title,
          href => href( "/${section}/${year}/", $const->baseURI )
        },
      );

      $vars->breadcrumb( \@tree );

      my $path = "${section}/${year}/index.html";
      my $out  = $distdir->child($path);

      $class->generate(
        dist     => $out,
        template => 'WebSite::Templates::Index',
        vars     => $vars,
      );

      if ( $year == ( (localtime)[5] + 1900 ) ) {
        $vars->title( $vars->contains->{$section}->{'website'} );
        $vars->description( $vars->contains->{$section}->{'description'} );
        $vars->summary( $vars->contains->{$section}->{'description'} );
        $vars->kind('home');
        $vars->href( URI::Fast->new( href( "/${section}/", $const->baseURI ) ) );

        pop @tree;
        $vars->breadcrumb( \@tree );

        $path = "${section}/index.html";
        $out  = $distdir->child($path);

        $class->generate(
          dist     => $out,
          template => 'WebSite::Templates::Index',
          vars     => $vars,
        );

        for my $feed (qw( index.xml atom.xml jsonfeed.json )) {
          $path = "${section}/${feed}";
          $out  = $distdir->child($path);
          my $tmpl =
              'WebSite::Templates::' . ( ( $feed eq 'index.xml' ) ? 'RSS20Feed' : ( $feed eq 'atom.xml' ) ? 'AtomFeed' : "JSONFeed" );

          $class->generate(
            dist     => $out,
            template => $tmpl,
            vars     => $vars,
          );
        }
      }
    }
    return 1;
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
