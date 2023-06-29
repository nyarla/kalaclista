package WebSite::Widgets::Metadata;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(metadata);

use Kalaclista::HyperScript;
use WebSite::Helper::Hyperlink qw(href);

use Kalaclista::Constants;

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
  state @result;
  return @result if ( @result != 0 );

  my $baseURI = Kalaclista::Constants->baseURI;
  my $vars    = shift;

  @result = (
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

    link_( { rel => 'stylesheet', href => href( '/main.css', $baseURI ) . '?v=0.0.3' } ),
  );

  return @result;
}

sub in_section {
  state %cache;

  my $vars = shift;

  return $cache{ $vars->section }->@*
      if ( exists $cache{ $vars->section } );

  my $baseURI = Kalaclista::Constants->baseURI;
  my $website = $vars->section =~ m{^(?:posts|echos|notes)$} ? $vars->contains->{ $vars->section }->{'website'} : $vars->website;
  my $prefix  = $vars->section =~ m{^(?:posts|echos|notes)$} ? "/" . $vars->section                             : q{};
  my @result  = (
    feed(
      "${website}の RSS フィード",
      href( "${prefix}/index.xml", $baseURI ),
      "application/rss+xml"
    ),
    feed(
      "${website}の Atom フィード",
      href( "${prefix}/atom.xml", $baseURI ),
      "application/atom+xml"
    ),
    feed(
      "${website}の JSON フィード",
      href( "${prefix}/jsonfeed.json", $baseURI ),
      "application/feed+json"
    ),
  );

  $cache{ $vars->section } = \@result;

  return @result;
}

sub page {
  my $vars = shift;

  my $title   = $vars->title;
  my $website = $vars->section =~ m{^(?:posts|echos|notes)$} ? $vars->contains->{ $vars->section }->{'website'} : $vars->website;
  my $avatar  = href( '/assets/avatar.png', $vars->href );
  my $href    = $vars->href->to_string;
  my $section = $vars->section;
  my $kind    = $vars->kind;
  my $tree    = $vars->breadcrumb;

  my $meta   = $vars->entries->[0];
  my $parent = $tree->[ $tree->@* - 2 ]->{'href'};

  my $docname = $title eq $website ? $title             : "${title} - ${website}";
  my $docdesc = $title eq $website ? $vars->description : $vars->summary;

  my @ogp = (
    property( 'og:title',       $title ),
    property( 'og:site_name',   $website ),
    property( 'og:image',       $avatar ),
    property( 'og:url',         $href ),
    property( 'og:description', $docdesc ),
    property( 'og:locale',      'ja_JP' ),
  );

  if ( $kind eq 'permalink' ) {
    push @ogp, (
      property( 'og:type',              'article' ),
      property( 'og:published_time',    $meta->date ),
      property( 'og:modified_time',     $meta->lastmod ),
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

  if ( $tree->@* == 1 ) {
    delete $jsonld{'parent'};
  }

  my @css;
  if ( ref( my $addon = $vars->entries->[0]->addon('style') ) ) {
    push @css, map { style( raw($_) ) } $addon->@*;
  }

  return (
    title($docname),
    meta( { name => 'description', content => $docdesc } ),

    link_( { rel => 'canonical', href => $href } ),

    @ogp, @twitter,

    script( { type => 'application/ld+json' }, raw( jsonld( \%jsonld, $vars->breadcrumb->@* ) ) ),
    @css,
  );
}

sub notfound {
  my $vars = shift;

  return (
    title( $vars->title . ' - ' . $vars->website ),
    meta( { name => 'description', content => $vars->description } ),
  );
}

sub metadata {
  my $vars = shift;

  return head(
    global($vars),
    in_section($vars),
    ( $vars->kind ne '404' ? page($vars) : notfound($vars) ),
  );
}

1;
