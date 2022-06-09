my $budoux    = "https://cdn.skypack.dev/budoux";
my $normalize = "https://cdn.skypack.dev/normalize.css";
my $tables    = {
  posts => [ 'Blog',    'BlogPosting' ],
  echos => [ 'Blog',    'BlogPosting' ],
  notes => [ 'WebSite', 'Article' ],
  pages => [ 'WebSite', 'WebPage' ],
};

my $types = sub {
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
};

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
  my ( $vars, $baseURI, $data ) = @_;

  # internal functions
  # ==================
  my $href =
    sub { my $link = $baseURI->clone; $link->path( $_[0] ); $link->as_string };

  # global variables
  # ================
  my $title       = $data->{'title'};
  my $website     = $data->{'website'};
  my $description = $data->{'description'};
  my $avatar      = $href->("/assets/avatar.png");
  my $section     = $data->{'section'};
  my $kind        = $data->{'kind'};
  my $home        = $data->{'home'};
  my $permalink   = $data->{'permalink'};
  my $tree        = $data->{'tree'};
  my $parent      = $tree->[ $tree->@* - 2 ]->{'href'};

  # elements
  # ========

  # basic
  # -----
  my $doctitle =
    title( ( $title eq $website ) ? $title : "${title} - ${website}" );
  my $charset  = meta( { charset => "utf-8" } );
  my $viewport = meta(
    {
      name    => 'viewport',
      content => 'width=device-width,minimum-scale=1,initial-scale=1'
    }
  );
  my $canonical = link_( { rel => "canonical", href => $permalink } );

  # preload
  # -------
  my $prefetch =
    link_( { rel => "dns-prefetch", href => "https://cdn.skypack.dev/" } );
  my @preloads = (
    link_( { rel => "preload", href => $budoux,    as => "script" } ),
    link_( { rel => "preload", href => $normalize, as => "style" } ),
  );

  # ogp
  # ---
  my @ogp = (
    property( 'og:title',       $title ),
    property( 'og:site_name',   $website ),
    property( 'og:image',       $avatar ),
    property( 'og:url',         $permalink ),
    property( 'og:type',        'website' ),
    property( 'og:description', $description ),
  );

  # twitter card
  # ------------
  my @twitter = (
    data_( 'twitter:card',        'summary' ),
    data_( 'twitter:site',        '@kalaclista' ),
    data_( 'twitter:title',       $title ),
    data_( 'twitter:description', $description ),
    data_( 'twitter:image',       $avatar ),
  );

  # feeds
  # -----
  my $rss = feed(
    $website . "の RSS フィード",
    $href->("/${section}/index.xml"),
    "application/rss+xml"
  );
  my $atom = feed(
    $website . "の Atom フィード",
    $href->("/${section}/atom.xml"),
    "application/atom+xml"
  );
  my $jsonfeed = feed(
    $website . "の JSON フィード",
    $href->("/${section}/jsonfeed.json"),
    "application/feed+json"
  );

  # JSON Linked Data
  # ----------------
  my $jsonld = script(
    { type => 'application/ld+json' },
    jsonld(
      {
        title     => $title,
        href      => $permalink,
        type      => $types->( $kind, $section ),
        author    => $author,
        publisher => $publisher,
        image     => $avatar,
        parent    => $parent,
      },
      $tree->@*,
    )
  );

  # style and script
  # ----------------
  my $script =
    script( { src => $href->('/assets/script.js'), type => 'module' }, "" );
  my $css = link_( { rel => 'stylesheet', href => $normalize } );
  my $style =
    link_( { rel => 'stylesheet', href => $href->('assets/stylesheet.css') } );

  # assets
  # ------
  my $webmanifest =
    link_( { rel => "manifest", href => $href->("/manifest.webmanifest") } );
  my $favicon = link_( { rel => "icon", href => $href->("/favicon.ico") } );
  my $svgicon = link_(
    { rel => "icon", href => $href->("/icon.svg"), type => "image/svg+xml" } );
  my $appleicon = link_(
    { rel => "apple-touch-icon", href => $href->('/apple-touch-icon.png') } );

  # output
  # ======
  return head(
    $charset,

    $doctitle,
    meta( { name => "description", content => $description } ),
    $canonical,
    @ogp,
    @twitter,
    $jsonld,

    $rss,
    $atom,
    $jsonfeed,

    $webmanifest,
    $favicon,
    $svgicon,
    $appleicon,

    meta( { 'http-equiv' => 'x-dns-prefetch-control', content => 'on' } ),
    $prefetch,
    @preloads,

    $viewport,
    $script,
    $css,
    $style,
  );
};

$head;
