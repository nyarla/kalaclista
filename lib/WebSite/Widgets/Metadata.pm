package WebSite::Widgets::Metadata;

use v5.38;
use utf8;

use feature qw(state);

use Exporter::Lite;
use JSON::XS qw(encode_json);

use Kalaclista::HyperScript qw|head meta link_ title script style raw|;

use WebSite::Context;
use WebSite::Context::URI qw(href);

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
  elsif ( $kind eq q|index| ) {
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
  my $section = shift;
  my $c       = WebSite::Context->instance;
  my $website = $section eq q|pages| ? $c->website : $c->sections->{$section};
  my $prefix  = $section eq q|pages| ? ""          : "/${section}";

  return (
    link_(
      {
        rel   => 'alternate',
        title => "@{[ $website->title ]}の RSS フィード",
        href  => href("${prefix}/index.xml")->to_string,
        type  => 'application/rss+xml',
      }
    ),
    link_(
      {
        rel   => 'alternate',
        title => "@{[ $website->title ]}の Atom フィード",
        href  => href("${prefix}/atom.xml")->to_string,
        type  => 'application/atom+xml',
      }
    ),
    link_(
      {
        rel   => 'alternate',
        title => "@{[ $website->title ]}の JSON フィード",
        href  => href("${prefix}/jsonfeed.json")->to_string,
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

  return (
    title($title),
    meta( { name => 'description', content => ( $kind eq 'permalink' ? $page->summary : $website->summary ) } ),

    meta( { property => 'og:title',       content => $page->title } ),
    meta( { property => 'og:site_name',   content => $website->title } ),
    meta( { property => 'og:image',       content => $avatar } ),
    meta( { property => 'og:url',         content => $page->href->to_string } ),
    meta( { property => 'og:description', content => ( $kind eq 'permalink' ? $page->summary : $website->summary ) } ),
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
    meta( { name => 'twitter:description', content => ( $kind eq 'permalink' ? $page->summary : $website->summary ) } ),
    meta( { name => 'twitter:image',       content => $avatar } ),

    script( { type => 'application/ld+json' }, raw( encode_json( jsonld( $page->kind, $page, $website ) ) ) ),
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
    rel( stylesheet => href("/main-@{[ digest('lib/WebSite/Templates/Stylesheet.pm') ]}.css")->to_string )
  ];

  return $html->@*;
}

sub feeds {
  state $c     ||= WebSite::Context->instance;
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

  if ( $kind eq 'permalink' ) {
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
  my $page = shift;
  my $c    = WebSite::Context->instance;
  my $website =
      ( $page->section eq 'posts' || $page->section eq 'echos' || $page->section eq 'notes' )
      ? $c->sections->{ $page->section }
      : $c->website;
  my $title = ( $page->kind eq q|permalink| ) ? $page->title : $website->title;
  my $href  = $page->href;

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
  my $c    = WebSite::Context->instance;

  return (
    title( join q{ - }, $page->title, $c->website->title ),
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
