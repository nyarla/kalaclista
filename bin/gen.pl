#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Kalaclista::Constants;

use Module::Load qw(load);
use HTML5::DOM;
use URI::Escape::XS qw(uri_unescape);

my $parser = HTML5::DOM->new( { script => 1 } );

use Kalaclista::Entries;
use Kalaclista::Path;

use Kalaclista::Data::Page;
use Kalaclista::Data::WebSite;

use WebSite::Context;

use WebSite::Extensions::AdjustHeading;
use WebSite::Extensions::Affiliate;
use WebSite::Extensions::CodeSyntax;
use WebSite::Extensions::Furigana;
use WebSite::Extensions::Picture;
use WebSite::Extensions::WebSite;

use WebSite::Helper::Hyperlink qw(href);

my %generators = (
  'home'        => 'Kalaclista::Generators::Page',
  'index'       => 'Kalaclista::Generators::Page',
  'main.css'    => 'Kalaclista::Generators::Page',
  'permalinks'  => 'Kalaclista::Generators::Page',
  'sitemap.xml' => 'Kalaclista::Generators::SitemapXML',
);

sub init {
  my $c = WebSite::Context->init(qr{^bin$});

  $c->website(
    label     => 'カラクリスタ',
    title     => 'カラクリスタ',
    summary   => '『輝かしい青春』なんて失かった人の Web サイトです',
    permalink => href( '/', $c->baseURI ),
  );

  $c->sections(
    posts => {
      label     => 'ブログ',
      title     => 'カラクリスタ・ブログ',
      summary   => '『輝かしい青春』なんて失かった人のブログです',
      permalink => href( 'posts', $c->baseURI ),
    },
    echos => {
      label     => 'エコーズ',
      title     => 'カラクリスタ・エコーズ',
      summary   => '『輝かしい青春』なんて失かった人の日記です',
      permalink => href( 'echos', $c->baseURI ),
    },
    notes => {
      label     => 'メモ帳',
      title     => 'カラクリスタ・ノート',
      summary   => '『輝かしい青春』なんて失かった人のメモ帳です',
      permalink => href( 'notes', $c->baseURI ),
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

  $path =~ s{^/}{};
  $entry->href->path("/${path}");

  if ( $path =~ m{(posts|notes|echos)} ) {
    $entry->type($1);
  }
  else {
    $entry->type('pages');
  }

  $entry->register( sub { WebSite::Extensions::AdjustHeading->transform(@_) } );
  $entry->register( sub { WebSite::Extensions::CodeSyntax->transform(@_) } );
  $entry->register( sub { WebSite::Extensions::Picture->transform( @_, [ 640, 1280 ] ) } );
  $entry->register( sub { WebSite::Extensions::Furigana->transform(@_) } );
  $entry->register( sub { WebSite::Extensions::WebSite->transform(@_) } );
  $entry->register( sub { WebSite::Extensions::Affiliate->transform(@_) } );

  return $entry;
}

sub main {
  my $action = shift;
  my $c      = WebSite::Context->instance;

  my $contents = $c->dirs->src('entries/src');
  my $datadir  = $c->dirs->rootdir->child('content/data');    # FIXME
  my $distdir  = $c->dirs->distdir;
  my $srcdir   = $c->dirs->srcdir;

  my $entries = Kalaclista::Entries->instance( $contents->path );

  if ( $action eq 'sitemap.xml' ) {
    my $class = 'Kalaclista::Generators::SitemapXML';
    load($class);

    return $class->generate(
      file    => $distdir->child('sitemap.xml'),
      entries => $entries,
    );
  }

  if ( $action eq 'home' ) {
    my $class = 'Kalaclista::Generators::Page';
    load($class);

    my @entries = (
      sort { $b->date cmp $a->date }
      grep { my $t = $_->type; $t eq 'posts' || $t eq 'echos' || $t eq 'notes' }
      map  { fixup($_) } $entries->entries->@*
    )[ 0 .. 10 ];

    my $page = Kalaclista::Data::Page->new(
      title   => $c->website->title,
      section => 'pages',
      kind    => 'home',
      entries => [@entries],
      href    => URI::Fast->new( href( '/', $c->baseURI ) ),
    );

    $page->breadcrumb->push( title => $c->website->title, permalink => $c->website->permalink );

    $class->generate(
      dist     => $distdir->child('index.html'),
      template => 'WebSite::Templates::Home',
      vars     => $page,
    );

    my $feed = Kalaclista::Data::Page->new(
      title   => $c->website->title,
      section => 'pages',
      kind    => 'home',
      entries => [ map { $_->transform } @entries[ 0 .. 4 ] ],
      href    => URI::Fast->new( href( '/', $c->baseURI ) ),
    );
    for my $type (qw/ RSS20Feed AtomFeed JSONFeed /) {
      $class->generate(
        dist => $distdir->child(
          {
            RSS20Feed => 'index.xml',
            AtomFeed  => 'atom.xml',
            JSONFeed  => 'jsonfeed.json',
          }->{$type}
        ),
        template => "WebSite::Templates::${type}",
        vars     => $feed,
      );
    }

    $page = Kalaclista::Data::Page->new(
      title   => '404 not found',
      section => 'pages',
      kind    => '404',
      entries => [],
      href    => undef,
    );

    $class->generate(
      dist     => $distdir->child('404.html'),
      template => 'WebSite::Templates::NotFound',
      vars     => $page,
    );
  }

  if ( $action eq 'index' ) {
    my $class = 'Kalaclista::Generators::Page';
    load($class);

    my $section = shift;
    my @entries = grep { $_->type eq $section } map { fixup($_) } $entries->entries->@*;
    @entries =
        $section eq 'notes'
        ? ( sort { $b->lastmod cmp $a->lastmod } @entries )
        : ( sort { $b->date cmp $a->date } @entries );

    my %data = (
      title   => $c->sections->{$section}->title,
      section => $section,
      kind    => 'index',
      href    => URI::Fast->new( href( "/${section}/", $c->baseURI ) ),
    );

    if ( $section eq 'notes' ) {
      my $page = Kalaclista::Data::Page->new(
        %data, entries => [@entries],
      );

      $page->breadcrumb->push(
        title     => $c->website->title,
        permalink => $c->baseURI->to_string
      );

      $page->breadcrumb->push(
        title     => $c->sections->{$section}->title,
        permalink => href( "/${section}/", $c->baseURI ),
      );

      $class->generate(
        dist     => $distdir->child("${section}/index.html"),
        template => 'WebSite::Templates::Index',
        vars     => $page,
      );

      @entries = map { $_->transform } @entries[ 0 .. 4 ];
      $page    = Kalaclista::Data::Page->new(
        %data, entries => [@entries],
      );

      for my $type (qw/ RSS20Feed AtomFeed JSONFeed /) {
        $class->generate(
          dist => $distdir->child(
            {
              RSS20Feed => "${section}/index.xml",
              AtomFeed  => "${section}/atom.xml",
              JSONFeed  => "${section}/jsonfeed.json",
            }->{$type}
          ),
          template => "WebSite::Templates::${type}",
          vars     => $page,
        );
      }
    }
    else {
      my ($start) = $entries[-1]->date =~ m{^(\d{4})};
      my ($end)   = $entries[0]->date  =~ m{^(\d{4})};

      for my $year ( $start .. $end ) {
        my @contains = grep { $_->date =~ m{^$year} } @entries;

        if ( @contains == 0 ) {
          next;
        }

        my $page = Kalaclista::Data::Page->new(
          title   => qq<${year}年の記事一覧>,
          summary => $c->sections->{$section}->title . "の ${year}年の記事一覧です",
          section => $section,
          kind    => 'index',
          entries => [@contains],
          href    => URI::Fast->new( href( "/${section}/${year}/", $c->baseURI ) ),
          vars    => { start => $start, end => $end },
        );

        $page->breadcrumb->push(
          title     => $c->website->title,
          permalink => $c->baseURI->to_string
        );

        $page->breadcrumb->push(
          title     => $c->sections->{$section}->title,
          permalink => href( "/${section}/", $c->baseURI ),
        );

        $page->breadcrumb->push(
          title     => $page->title,
          permalink => $page->href->to_string,
        );

        my $dist = $distdir->child("${section}/${year}/index.html");
        $class->generate(
          dist     => $dist,
          template => 'WebSite::Templates::Index',
          vars     => $page,
        );

        if ( $year == $end ) {
          my $top = Kalaclista::Data::Page->new(
            title   => $c->sections->{$section}->title,
            summary => $c->sections->{$section}->summary,
            section => $section,
            kind    => 'home',
            entries => [@contains],
            href    => URI::Fast->new( href( "/${section}/", $c->baseURI ) ),
            vars    => { start => $start, end => $end },
          );

          $top->breadcrumb->push(
            title     => $c->website->title,
            permalink => $c->baseURI->to_string
          );

          $top->breadcrumb->push(
            title     => $c->sections->{$section}->title,
            permalink => href( "/${section}/", $c->baseURI ),
          );

          $class->generate(
            dist     => $distdir->child("${section}/index.html"),
            template => 'WebSite::Templates::Index',
            vars     => $top
          );

          @contains = map { $_->transform } @contains[ 0 .. 4 ];
          my $feed = Kalaclista::Data::Page->new(
            title   => $page->title,
            summary => $page->summary,
            section => $section,
            kind    => 'home',
            href    => href( "/${section}/", $c->baseURI ),
            entries => [@contains],
          );

          for my $type (qw/ RSS20Feed AtomFeed JSONFeed /) {
            $class->generate(
              dist => $distdir->child(
                {
                  RSS20Feed => "${section}/index.xml",
                  AtomFeed  => "${section}/atom.xml",
                  JSONFeed  => "${section}/jsonfeed.json",
                }->{$type}
              ),
              template => "WebSite::Templates::${type}",
              vars     => $feed,
            );
          }
        }
      }
    }
  }

  if ( $action eq 'permalinks' ) {
    my $class = 'Kalaclista::Generators::Page';
    load($class);

    my $year = shift;
    my @entries =
        grep { $_->date =~ m{^$year} }
        map { fixup($_) } $entries->entries->@*;

    for my $entry (@entries) {
      my $precompiled = do {
        my $path   = $entry->path;
        my $prefix = $srcdir->child('entries')->path;

        $path =~ s{$prefix/src}{$prefix/precompiled};

        my $content = Kalaclista::Path->new( path => $path )->get;
        utf8::decode($content);

        $content;
      };

      my $dom = $parser->parse($precompiled)->body;
      $entry->dom($dom);
      $entry->transform;

      my $summary =
          exists $entry->meta->{'summary'}
          ? $entry->meta->{'summary'}
          : ( $dom->at('.sep ~ *') // $dom->at('*:first-child') )->textContent . '……';

      my $page = Kalaclista::Data::Page->new(
        title   => $entry->title,
        summary => $summary,
        section => $entry->type,
        kind    => 'permalink',
        entries => [$entry],
        href    => $entry->href,
      );

      $page->breadcrumb->push(
        title     => $c->website->title,
        permalink => $c->baseURI->to_string,
      );

      if ( $entry->type ne 'pages' ) {
        $page->breadcrumb->push(
          title     => $c->sections->{ $entry->type }->title,
          permalink => $c->sections->{ $entry->type }->permalink . "/",
        );
      }

      $page->breadcrumb->push(
        title     => $entry->title,
        permalink => $entry->href->to_string,
      );

      my $path = $entry->href->path;
      $class->generate(
        dist     => $distdir->child("${path}index.html"),
        template => 'WebSite::Templates::Permalink',
        vars     => $page,
      );
    }
  }
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
