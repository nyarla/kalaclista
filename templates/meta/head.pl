my $budoux    = 'https://cdn.skypack.dev/budoux';
my $normalize = 'https://cdn.skypack.dev/normalize.css';

my $tables = {
  posts => [ 'Blog',    'BlogPosting' ],
  echos => [ 'Blog',    'BlogPosting' ],
  notes => [ 'WebSite', 'Article' ],
  pages => [ 'WebSite', 'WebPage' ],
};

no warnings 'redefine';

sub types {
  my ( $kind, $section ) = @_;

  if ( $kind eq 'permalink' ) {
    if ( $section eq q{posts} || $section eq q{echos} || $section eq q{notes} )
    {
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

use warnings 'redefine';

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

my $head = sub {
  my ( $vars, $baseURI ) = @_;

  my $meta        = $vars->entries->[0]->[0];
  my $title       = $vars->title;
  my $website     = $vars->website;
  my $description = $vars->description;
  my $section     = $vars->section;
  my $kind        = $vars->kind;
  my $permalink   = $vars->href;
  my $tree        = $vars->breadcrumb;

  my $parent = $tree->[ $tree->@* - 2 ]->{'href'};
  my $avatar = href( '/assets/avatar.png', $baseURI );

  # prefetch and preload
  my $dns =
    meta( { 'http-equiv' => 'x-dns-prefetch-control', content => 'on' } );
  my $prefetch =
    link_( { rel => 'dns-prefetch', href => 'https://cdn.skypack.dev/' } );
  my @preloads = (
    link_( { rel => 'preload', href => $budoux,    as => 'script' } ),
    link_( { rel => 'preload', href => $normalize, as => 'style' } ),
  );

  my $script =
    script( { src => href( '/assets/script.js', $baseURI ), type => 'module' },
    "" );
  my @css = (
    link_(
      {
        rel  => 'stylesheet',
        href => $normalize,
      }
    ),
    link_(
      {
        rel  => 'stylesheet',
        href => href( '/assets/stylesheet.css', $baseURI )
      }
    ),
  );

  if ( exists $meta->{'addon'}->{'style'}
    && ref $meta->{'addon'}->{'style'} eq 'ARRAY' )
  {
    push @css, style( raw( join q{ }, $meta->addon->{'style'}->@* ) );
  }

  # document format
  my $charset   = meta( { charset => 'utf-8' } );
  my $canonical = link_( { rel => 'canonical', href => $permalink } );
  my $viewport  = meta(
    {
      name    => 'viewport',
      content => 'width=device-width,minimum-scale=1,initial-scale=1'
    }
  );

  # document information
  my $docname =
    title( ( $title eq $website ) ? $title : "${title} - ${website}" );
  my $docdesc = meta( { name => 'description', content => $description } );

  my @ogp = (
    property( 'og:title',       $title ),
    property( 'og:site_name',   $website ),
    property( 'og:image',       $avatar ),
    property( 'og:url',         $permalink ),
    property( 'og:type',        'website' ),
    property( 'og:description', $description ),
  );

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

  my $webmanifest =
    item( manifest => href( '/manifest.webmanifest', $baseURI ) );
  my $favicon = item( icon => href( '/favicon.ico', $baseURI ) );
  my $svgicon = item( icon => href( '/icon.svg', $baseURI ), 'image/svg+xml' );
  my $apple =
    item( 'apple-touch-icon', href( '/apple-touch-icon.png', $baseURI ) );

  return head(
    $charset,
    $dns, $prefetch, @preloads,

    $script,    @css,
    $canonical, $viewport,

    $docname, $docdesc, @ogp, @twitter,
    $jsonld,  @feeds,

    $webmanifest, $favicon, $svgicon, $apple,
  );
};

$head;
