package WebSite::Widgets::Metadata;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(metadata);

use Kalaclista::HyperScript;

use WebSite::Helper::Hyperlink qw(href);

use WebSite::Context;

my %tables = (
  posts => [ 'Blog',    'BlogPosting' ],
  echos => [ 'Blog',    'BlogPosting' ],
  notes => [ 'WebSite', 'Article' ],
  pages => [ 'WebSite', 'WebPage' ],
);

my $author = {
  '@type' => 'Person',
  'email' => 'nyarla@kalaclista.com',
  'name'  => 'OKAMURA Naoki aka nyarla',
  'url'   => 'https://the.kalaclista.com/nyarla/',
};

my $publisher = {
  '@type' => 'Organization',
  'logo'  => {
    '@type'      => 'ImageObject',
    'contentUrl' => 'https://the.kalaclista.com/assets/avatar.png',
  },
};

sub types {
  my ( $kind, $section ) = @_;

  if ( $kind eq 'permalink' ) {
    if ( $section eq q{posts} || $section eq q{echos} || $section eq q{notes} ) {
      return $tables{$section}->[1];
    }

    return $tables{'pages'}->[1];
  }

  if ( $section eq q{posts} || $section eq q{echos} || $section eq q{notes} ) {
    return $tables{$section}->[0];
  }

  return $tables{'pages'}->[0];
}

sub item {
  my ( $item, $href, $type ) = @_;

  my %attr;
  @attr{qw( rel href )} = ( $item, $href );
  $attr{'type'} = $type if ( defined $type );

  return link_( \%attr );
}

sub global {
  state $result;
  return $result->@* if ( defined $result );

  my $digest  = time;
  my $baseURI = WebSite::Context->instance->baseURI;

  $result ||= [];
  push $result->@*, (
    meta( { charset => 'utf-8' } ),
    meta(
      {
        name    => 'viewport',
        content => 'width=device-width,minimum-scale=1,initial-scale=1'
      }
    ),
    item( manifest           => href( '/manifest.webmanifest', $baseURI ) ),
    item( icon               => href( '/favicon.ico',          $baseURI ) ),
    item( icon               => href( '/icon.svg',             $baseURI ), 'images/svg+xml' ),
    item( 'apple-touch-icon' => href( '/apple-touch-icon.png', $baseURI ) ),

    link_( { rel => 'author', href => 'http://www.hatena.ne.jp/nyarla-net/' } ),

    link_( { rel => 'stylesheet', href => href( "/main.css", $baseURI ) } ),
  );

  return $result->@*;
}

sub in_section {
  state $cache ||= {};

  my $page = shift;

  return $cache->{ $page->section }->@*
      if ( exists $cache->{ $page->section } );

  my $c = WebSite::Context->instance;
  my $website =
      ( $page->section eq 'posts' || $page->section eq 'echos' || $page->section eq 'notes' )
      ? $c->sections->{ $page->section }
      : $c->website;
  my $prefix = ( $website != $c->website ) ? '/' . $page->section : q{};
  my @result = (
    feed(
      "@{[ $website->title ]}の RSS フィード",
      href( "${prefix}/index.xml", $c->baseURI ),
      "application/rss+xml"
    ),
    feed(
      "@{[ $website->title ]}の Atom フィード",
      href( "${prefix}/atom.xml", $c->baseURI ),
      "application/atom+xml"
    ),
    feed(
      "@{[ $website->title ]}の JSON フィード",
      href( "${prefix}/jsonfeed.json", $c->baseURI ),
      "application/feed+json"
    ),
  );

  $cache->{ $page->section } = [@result];
  return @result;
}

sub page {
  my $c    = WebSite::Context->instance;
  my $page = shift;

  my $title   = $page->title;
  my $website = (
    ( $page->section eq 'posts' || $page->section eq 'echos' || $page->section eq 'notes' )
    ? $c->sections->{ $page->section }
    : $c->website
  );

  my $avatar  = href( '/assets/avatar.png', $page->href );
  my $href    = $page->href->to_string;
  my $section = $page->section;
  my $kind    = $page->kind;
  my $tree    = $page->breadcrumb;
  my $meta    = $page->entries->[0];
  my $parent  = $tree->index( $tree->length - 2 )->permalink;

  my $docname = $title eq $website->title ? $title            : "${title} - @{[ $website->title ]}";
  my $docdesc = $title eq $website->title ? $website->summary : $page->summary;

  my @ogp = (
    property( 'og:title',       $title ),
    property( 'og:site_name',   $website->title ),
    property( 'og:image',       $avatar ),
    property( 'og:url',         $href ),
    property( 'og:description', $docdesc ),
    property( 'og:locale',      'ja_JP' ),
  );

  if ( $kind eq 'permalink' ) {
    push @ogp, (
      property( 'og:type',              'article' ),
      property( 'og:published_time',    $meta->date ),
      property( 'og:modified_time',     $meta->updated ),
      property( 'og:section',           $section ),
      property( 'og:author:first_name', 'Naoki' ),
      property( 'og:author:last_name',  'OKAMURA' ),
    );
  }
  else {
    push @ogp, property( 'og:type', 'website' );
  }

  my @twitter = (
    data_( 'twitter:card',        'summary' ),
    data_( 'twitter:site',        '@kalaclista' ),
    data_( 'twitter:title',       $docname ),
    data_( 'twitter:description', $docdesc, ),
    data_( 'twitter:image',       $avatar ),
  );

  my %jsonld;
  @jsonld{qw( title href type author publisher image parent )} =
      ( $title, $href, types( $kind, $section ), $author, $publisher, { '@type' => 'ImageObject', contentUrl => $avatar }, $parent );

  if ( $tree->length == 1 ) {
    delete $jsonld{'parent'};
  }

  my @css;
  if ( ref( my $css = $page->entries->[0]->meta('css') ) eq 'ARRAY' ) {
    push @css, map { style( raw($_) ) } $css->@*;
  }

  my @breadcrumb =
      map {
        {
          name => $page->breadcrumb->index($_)->title,
          href => $page->breadcrumb->index($_)->permalink
        }
      } ( 0 .. $page->breadcrumb->length - 1 );
  return (
    title($docname),
    meta( { name => 'description', content => $docdesc } ),

    link_( { rel => 'canonical', href => $href } ),

    @ogp, @twitter,

    script(
      { type => 'application/ld+json' },
      raw( jsonld( {%jsonld}, @breadcrumb ) )
    ),
    @css,
  );
}

sub notfound {
  my $page = shift;
  my $c    = WebSite::Context->instance;

  return (
    title( $page->title . ' - ' . $c->website->title ),
    meta( { name => 'description', content => "ページが見つかりません" } ),
  );
}

sub metadata {
  my $page = shift;

  return head(
    global(),
    in_section($page),
    ( $page->kind ne '404' ? page($page) : notfound($page) ),
  );
}

1;
