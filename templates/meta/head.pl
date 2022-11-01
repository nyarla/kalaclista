use strict;
use warnings;
use utf8;

my $tables = {
  posts => [ 'Blog',    'BlogPosting' ],
  echos => [ 'Blog',    'BlogPosting' ],
  notes => [ 'WebSite', 'Article' ],
  pages => [ 'WebSite', 'WebPage' ],
};

sub types {
  my ( $kind, $section ) = @_;

  if ( $kind eq 'permalink' ) {
    if ( $section eq q{posts} || $section eq q{echos} || $section eq q{notes} ) {
      return $tables->{$section}->[1];
    }

    return $tables->{'pages'}->[1];
  }

  if ( $section eq q{posts} || $section eq q{echos} || $section eq q{notes} ) {
    return $tables->{$section}->[0];
  }

  return $tables->{'pages'}->[0];
}

sub item {
  my ( $item, $href, $type ) = @_;

  my %attr;
  @attr{qw( rel href )} = ( $item, $href );
  $attr{'type'} = $type if ( defined $type );

  return link_( \%attr );
}

my $author = {
  '@type' => 'Person',
  'email' => 'nyarla@kalaclista.com',
  'name'  => 'OKAMURA Naoki aka nyarla'
};

my $publisher = {
  '@type' => 'Organization',
  'logo'  => {
    '@type' => 'ImageObject',
    'url'   => {
      '@type' => 'URL',
      'url'   => 'https://the.kalaclista.com/assets/avatar.png'
    }
  },
  'name' => 'the.kalaclista.com',
};

my $charset  = meta( { charset => 'utf-8' } );
my $viewport = meta(
  {
    name    => 'viewport',
    content => 'width=device-width,minimum-scale=1,initial-scale=1'
  }
);

my $global = sub {
  my ( $vars, $baseURI ) = @_;

  my $title       = $vars->title;
  my $website     = $vars->website;
  my $description = $vars->description;

  my @scripts = (
    script( raw( $vars->data->{'js'} ) ),
    (
      ( $vars->data->{'loader'} ne q{} && $vars->href =~ m{/\d{4}/\d{2}/|notes/[^/]+/} )
      ? script( raw( $vars->data->{'loader'} ) )
      : q{}
    )
  );

  my @css = ( style( raw( $vars->data->{'css'} ) ) );

  my $docname = title( ( $title eq $website ) ? $title : "${title} - ${website}" );
  my $docdesc = meta( { name => 'description', content => $description } );

  my $hatena = link_( { rel => 'author', href => 'http://www.hatena.ne.jp/nyarla-net/' } );

  my $webmanifest = item( manifest => href( '/manifest.webmanifest', $baseURI ) );
  my $favicon     = item( icon     => href( '/favicon.ico',          $baseURI ) );
  my $svgicon     = item( icon => href( '/icon.svg', $baseURI ), 'image/svg+xml' );
  my $apple       = item( 'apple-touch-icon', href( '/apple-touch-icon.png', $baseURI ) );

  return (
    $charset,

    @scripts, @css,

    $viewport,
    $docname, $docdesc, $hatena,

    $webmanifest, $favicon, $svgicon, $apple,
  );
};

my $page = sub {
  my ( $vars, $baseURI ) = @_;

  my $meta        = $vars->entries->[0];
  my $title       = $vars->title;
  my $website     = $vars->website;
  my $description = $vars->description;
  my $section     = $vars->section;
  my $kind        = $vars->kind;
  my $permalink   = $vars->href;
  my $tree        = $vars->breadcrumb;

  my $parent = $tree->[ $tree->@* - 2 ]->{'href'};
  my $avatar = href( '/assets/avatar.png', $baseURI );

  my @css;
  if ( exists $meta->{'addon'}->{'style'}
    && ref $meta->{'addon'}->{'style'} eq 'ARRAY' ) {
    push @css, style( raw( join q{ }, $meta->addon->{'style'}->@* ) );
  }

  # document format
  my $canonical = link_( { rel => 'canonical', href => $permalink } );

  # document information

  my @ogp = (
    property( 'og:title',       $title ),
    property( 'og:site_name',   $website ),
    property( 'og:image',       $avatar ),
    property( 'og:url',         $permalink ),
    property( 'og:description', $description ),
  );

  if ( $kind eq 'permalink' ) {
    push @ogp, (
      property( 'og:type',           'article' ),
      property( 'og:published_time', $meta->date ),
      property( 'og:modified_time',  $meta->lastmod ),
      property( 'og:section',        $section ),
    );
  }
  else {
    push @ogp, property( 'og:type', 'website' ),;
  }

  my @twitter = (
    data_( 'twitter:card',        'summary' ),
    data_( 'twitter:site',        '@kalaclista' ),
    data_( 'twitter:title',       $title ),
    data_( 'twitter:description', $description ),
    data_( 'twitter:image',       $avatar ),
  );

  # document metadata
  my $prefix = ( $section eq 'pages' ) ? "" : "/${section}";
  my @feeds  = (
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

  my %jsonld;
  @jsonld{qw( title href type author publisher image parent )} = (
    $title,  $permalink, types( $kind, $section ),
    $author, $publisher, $avatar, $parent
  );
  my $jsonld = script(
    { type => 'application/ld+json' },
    raw( jsonld( \%jsonld, $tree->@* ) ),
  );

  return $canonical, @ogp, @twitter, $jsonld, @feeds;
};

my $head = sub {
  my ( $vars, $baseURI ) = @_;

  my @meta = $global->( $vars, $baseURI );
  push @meta, $page->( $vars, $baseURI ) if ( $vars->kind ne '404' );

  return head(@meta);
};

$head;
