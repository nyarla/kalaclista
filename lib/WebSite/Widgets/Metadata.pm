package WebSite::Widgets::Metadata;

use v5.38;
use utf8;

use feature qw(state);

use Exporter::Lite;
use JSON::XS qw(encode_json);

use Kalaclista::HyperScript qw|head meta link_ title script style raw|;

use WebSite::Context::WebSite qw(website section);
use WebSite::Context::URI     qw(href);
use WebSite::Context::Path    qw(cachedir);

use WebSite::Helper::Digest qw(digest);

our @EXPORT    = qw(metadata);
our @EXPORT_OK = ( @EXPORT, qw(type rel common feed feeds cardinfo jsonld headers notfound) );

sub type : prototype($$) {
  my ( $kind, $section ) = @_;

  if ( $kind eq q|permalink| ) {
    return q|BlogPosting| if $section eq q|posts| || $section eq q|echos|;
    return q|Article|     if $section eq q|notes|;
    return q|WebPage|;
  }
  elsif ( $kind eq q|index| || $kind eq q|home| ) {
    return q|Blog| if $section eq q|posts| || $section eq q|echos|;
    return q|WebSite|;
  }

  return q|WebPage|;
}

my sub author {
  state $author ||= {
    '@type' => 'Person',
    name    => 'OKAMURA Naoki aka nyarla',
    email   => 'nyarla@kalaclista.com',
    url     => 'https://the.kalaclista.com/nyarla/'
  };

  return $author;
}

my sub publisher {
  state $publisher ||= {
    '@type' => 'Organization',
    logo    => {
      '@type'    => 'ImageObject',
      contentUrl => 'https://the.kalaclista.com/assets/avatar.png',
    },
  };

  return $publisher;
}

sub rel : prototype($$;$) {
  my $item = shift;
  my $href = shift;
  my $type = shift // q{};

  return link_( { rel => $item, href => $href, ( $type ne q{} ? ( type => $type ) : () ) } );
}

sub feed : prototype($) {
  my $section = section(shift);
  my sub path {
    my $fn   = shift;
    my $href = $section->href->clone;
    $href->path( [ ( $href->path ), $fn ] );

    return $href->to_string;
  }

  return (
    link_(
      {
        rel   => 'alternate',
        title => "@{[ $section->title ]}の RSS フィード",
        href  => path('index.xml'),
        type  => 'application/rss+xml',
      }
    ),
    link_(
      {
        rel   => 'alternate',
        title => "@{[ $section->title ]}の Atom フィード",
        href  => path('atom.xml'),
        type  => 'application/atom+xml',
      }
    ),
    link_(
      {
        rel   => 'alternate',
        title => "@{[ $section->title ]}の JSON フィード",
        href  => path('jsonfeed.json'),
        type  => 'application/feed+json',
      }
    )
  );
}

sub cardinfo : prototype($$$) {
  my ( $kind, $page, $website ) = @_;
  my $avatar = href('/assets/avatar.png')->to_string;

  my $title =
      ( $kind eq 'permalink' )
      ? join( q{ - }, $page->title, $website->title )
      : $website->title;

  my $summary =
      $kind eq 'permalink'
      ? ( $page->summary ne q{} ? $page->summary : ( $page->entries->[0]->dom->text =~ m{^(.{,70})} )[0] . '……' )
      : $website->summary;

  my $jsonld = encode_json( jsonld( $page->kind, $page, $website ) );
  utf8::decode($jsonld);

  return (
    title($title),
    meta( { name => 'description', content => $summary } ),

    meta( { property => 'og:title',       content => $page->title } ),
    meta( { property => 'og:site_name',   content => $website->title } ),
    meta( { property => 'og:image',       content => $avatar } ),
    meta( { property => 'og:url',         content => $page->href->to_string } ),
    meta( { property => 'og:description', content => $summary } ),
    meta( { property => 'og:locale',      content => 'ja_JP' } ),

    (
      $kind eq q|permalink|
      ? (
        meta( { property => 'og:type',              content => 'article' } ),
        meta( { property => 'og:published_time',    content => $page->entries->[0]->date } ),
        meta( { property => 'og:modified_time',     content => $page->entries->[0]->updated } ),
        meta( { property => 'og:section',           content => $page->section } ),
        meta( { property => 'og:author:first_name', content => 'Naoki' } ),
        meta( { property => 'og:author:last_name',  content => 'OKAMURA' } ),
          )
      : (
        meta( { property => 'og:type',    content => 'website' } ),
        meta( { property => 'og:section', content => $page->section } ),
      )
    ),

    meta( { name => 'twitter:card',        content => 'summary' } ),
    meta( { name => 'twitter:site',        content => '@kalaclista' } ),
    meta( { name => 'twitter:title',       content => $title } ),
    meta( { name => 'twitter:description', content => $summary } ),
    meta( { name => 'twitter:image',       content => $avatar } ),

    script( { type => 'application/ld+json' }, raw($jsonld) ),
  );

}

sub common {
  state $html ||= [
    meta( { charset => 'utf-8' } ),
    meta( { name    => 'viewport', content => 'width=device-width,initial-scale=1' } ),
    rel( manifest   => href('/manifest.webmanifest')->to_string ),
    rel( icon       => href('/favicon.ico')->to_string ),
    rel( icon       => href('/icon.svg')->to_string, 'image/svg+xml' ),
    rel( author     => 'http://www.hatena.ne.jp/nyarla-net/' ),
    rel( author     => 'https://the.kalaclista.com/nyarla' ),
    rel( stylesheet => href("/main-@{[ digest(cachedir->child('css/main.css')->path) ]}.css")->to_string )
  ];

  return $html->@*;
}

sub feeds {
  state $feeds ||= {
    map { $_ => [ feed $_ ] } qw(posts echos notes pages),
  };

  return $feeds->{ (shift) };
}

sub jsonld {
  my ( $kind, $page, $website ) = @_;

  my $title = ( $kind eq 'permalink' ) ? $page->title : $website->title;

  my $self = {
    '@context' => 'https://schema.org',
    '@id'      => $page->href->to_string,
    '@type'    => type( $page->kind, $page->section ),
    headline   => $title,
    author     => author,
    publisher  => publisher,
    image      => href('/assets/avatar.png')->to_string,
  };

  if ( $kind ne 'home' ) {
    $self->{'mainEntityOfPage'} = $website->href->to_string;
  }

  my $items = [];
  for my $idx ( 0 .. $page->breadcrumb->length - 1 ) {
    push $items->@*, +{
      '@type'  => 'ListItem',
      name     => $page->breadcrumb->index($idx)->title,
      item     => $page->breadcrumb->index($idx)->href->to_string,
      position => $idx + 1,
    };
  }

  return [
    $self,
    {
      '@context'      => 'https://schema.org',
      '@type'         => 'BreadcrumbList',
      itemListElement => $items
    }
  ];
}

sub headers {
  my $page    = shift;
  my $website = section( $page->section );
  my $title   = ( $page->kind eq q|permalink| ) ? $page->title : $website->title;
  my $href    = $page->href;

  my @css;
  if ( $page->kind eq 'permalink' && exists $page->entries->[0]->meta->{'css'} && $page->entries->[0]->meta->{'css'} ) {
    push @css, $page->entries->[0]->meta->{'css'}->@*;
  }

  return (
    cardinfo( $page->kind, $page, $website ),
    feeds( $page->section ),
    ( @css > 0 ? style( raw(@css) ) : () ),
  );
}

sub notfound {
  my $page = shift;

  return (
    title( join q{ - }, $page->title, website->title ),
    meta( { name => 'description', content => 'ページが見つかりません' } ),
  );
}

sub metadata {
  my $page = shift;

  return head(
    common,
    ( $page->kind eq '404' ? notfound($page) : headers($page) ),
  );
}

1;
