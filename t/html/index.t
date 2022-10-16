#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use HTML5::DOM;
use JSON::XS qw(decode_json);

use Kalaclista::Directory;
use Kalaclista::Sequential::Files;
use Kalaclista::Files;
use Path::Tiny;

my $dist   = Kalaclista::Directory->new->rootdir->child("dist/public");
my $parser = HTML5::DOM->new( { scripts => 1 } );

sub testing_jsonld {
  my ( $data, $dom, $section, $index ) = @_;

  my $self = $data->[0];
  my $tree = $data->[1]->{'itemListElement'};

  # @id
  is( $self->{'@id'}, $dom->at('link[rel="canonical"]')->getAttribute('href') );

  # title (headline)
  is(
    $self->{'headline'},
    $dom->at('meta[property="og:title"]')->getAttribute('content')
  );

  # @type
  if ( $section eq q{posts} ) {
    is( $self->{'@type'}, 'Blog' );
  }
  elsif ( $section eq q{echos} ) {
    is( $self->{'@type'}, 'Blog' );
  }
  elsif ( $section eq q{notes} ) {
    is( $self->{'@type'}, 'WebSite' );
  }

  # mainEntryOfPage
  if ($index) {
    is(
      $self->{'mainEntryOfPage'},
      { '@id' => 'https://the.kalaclista.com/' }
    );
  }
  else {
    is(
      $self->{'mainEntryOfPage'},
      { '@id' => "https://the.kalaclista.com/${section}/" }
    );
  }

  # $tree->@*
  is(
    $tree->[1],
    {
      '@type'    => 'ListItem',
      'item'     => "https://the.kalaclista.com/${section}/",
      'name'     => $dom->at('meta[property="og:site_name"]')->getAttribute('content'),
      'position' => 2,
    }
  );

  if ( !$index && $section ne q{notes} ) {
    is(
      $tree->[2],
      {
        '@type'    => 'ListItem',
        'item'     => $dom->at('link[rel="canonical"]')->getAttribute('href'),
        'name'     => $dom->at('meta[property="og:title"]')->getAttribute('content'),
        'position' => 3,
      }
    );
  }
}

sub testing {
  my $file = shift;
  my $dom  = $parser->parse( $file->slurp_utf8 );

  my $section = ( $dom->at('meta[property="og:url"]')->getAttribute('content') =~ m{\.com/([^/]+)/} )[0];
  my $index   = $dom->at('link[rel="canonical"]')->getAttribute('href') =~ m{/(posts|echos|notes)/$};

  # Headers
  # =======

  # title
  if ($index) {
    is(
      $dom->at('title')->textContent,
      $dom->at('meta[property="og:site_name"]')->getAttribute('content')
    );

    is(
      $dom->at('title')->textContent,
      $dom->at('meta[property="og:title"]')->getAttribute('content')
    );
  }
  else {
    like(
      $dom->at('title')->textContent,
      qr<(?:\d{4}年|メモ帳)の記事一覧 - カラクリスタ・(ブログ|エコーズ|ノート)>
    );

  }

  # description
  if ($index) {
    like(
      $dom->at('meta[property="og:description"]')->getAttribute('content'),
      qr"『輝かしい青春』なんて失かった人の(ブログ|日記|メモ帳)です。",
    );
  }
  else {
    like(
      $dom->at('meta[name="description"]')->getAttribute('content'),
      qr<カラクリスタ・(ブログ|エコーズ)の\d{4}年の記事一覧です>,
    );
  }

  # permalink
  if ( $index || $section eq q{notes} ) {
    like(
      $dom->at('link[rel="canonical"]')->getAttribute('href'),
      qr<https://the.kalaclista.com/(?:notes|posts|echos)/>
    );
  }
  else {
    like(
      $dom->at('link[rel="canonical"]')->getAttribute('href'),
      qr<https://the.kalaclista.com/(?:(posts|echos)/\d{4})/>
    );
  }

  # og:title
  if ( $index || $section eq q{notes} ) {
    like(
      $dom->at('meta[property="og:title"]')->getAttribute('content'),
      qr<カラクリスタ・(ブログ|エコーズ|ノート)>
    );
  }
  else {
    like(
      $dom->at('meta[property="og:title"]')->getAttribute('content'),
      qr<\d{4}年の記事一覧>
    );
  }

  # og:site_name
  like(
    $dom->at('meta[property="og:site_name"]')->getAttribute('content'),
    qr<カラクリスタ・(ブログ|エコーズ|ノート)>
  );

  # og:url
  is(
    $dom->at('meta[property="og:url"]')->getAttribute('content'),
    $dom->at('link[rel="canonical"]')->getAttribute('href'),
  );

  # og:description
  if ( $index || $section eq q{notes} ) {
    like(
      $dom->at('meta[property="og:description"]')->getAttribute('content'),
      qr<『輝かしい青春』なんて失かった人の(ブログ|日記|メモ帳)です。>,
    );
  }
  else {
    like(
      $dom->at('meta[property="og:description"]')->getAttribute('content'),
      qr<カラクリスタ・(ブログ|エコーズ)の\d{4}年の記事一覧です>,
    );
  }

  # twitter:title
  if ( $index || $section eq q{notes} ) {
    like(
      $dom->at('meta[name="twitter:title"]')->getAttribute('content'),
      qr<カラクリスタ・(ブログ|エコー|ノート)>
    );
  }
  else {
    like(
      $dom->at('meta[name="twitter:title"]')->getAttribute('content'),
      qr<(?:\d{4}年|メモ帳)の記事一覧>
    );
  }

  # twitter:description
  is(
    $dom->at('meta[name="twitter:description"]')->getAttribute('content'),
    $dom->at('meta[property="og:description"]')->getAttribute('content'),
  );

  # og:image
  is(
    $dom->at('meta[property="og:image"]')->getAttribute('content'),
    "https://the.kalaclista.com/assets/avatar.png"
  );

  # og:type
  is(
    $dom->at('meta[property="og:type"]')->getAttribute('content'),
    "website"
  );

  # twitter:card
  is(
    $dom->at('meta[name="twitter:card"]')->getAttribute('content'),
    "summary"
  );

  # twitter:site
  is(
    $dom->at('meta[name="twitter:site"]')->getAttribute('content'),
    '@kalaclista'
  );

  # twitter:image
  is(
    $dom->at('meta[name="twitter:image"]')->getAttribute('content'),
    "https://the.kalaclista.com/assets/avatar.png"
  );

  # jsonld
  my $jsonld = $dom->at('script[type="application/ld+json"]')->textContent;
  utf8::encode($jsonld);
  testing_jsonld( decode_json($jsonld), $dom, $section, $index );

  # Contents
  # ========

  # header
  like(
    $dom->at('.entry__archives header h1 a')->getAttribute('href'),
    qr{^https://the\.kalaclista\.com/(posts|echos|notes)/}
  );

  like(
    $dom->at('.entry__archives header h1 a')->textContent,
    qr{カラクリスタ・(ブログ|エコーズ|ノート)}
  );

  # list of contents
  if ( $section ne q{notes} ) {
    like(
      $dom->at('.entry__archives .entry__content strong')->textContent,
      qr(\d{4}年：)
    );
  }

  for my $item ( $dom->find('.entry__archives .entry__content .archives li')->@* ) {
    like( $item->at('time')->getAttribute('datetime'), qr(\d{4}-\d{2}-\d{2}) );
    like( $item->at('time')->textContent,              qr(\d{4}-\d{2}-\d{2}：) );

    like(
      $item->at('a.title')->getAttribute('href'),
      qr<https://the\.kalaclista\.com/(?:notes/[^/]+|(posts|echos)/\d{4}/\d{2}/\d{2}/\d{6})/>
    );
  }

  # list of archives
  if ( $section ne q{notes} ) {
    for my $item ( $dom->find('.entry__archives .entry__content .archives + hr + p > *')->@* ) {
      like( $item->textContent, qr<\d{4}> );

      if ( $item->tag eq 'a' ) {
        like(
          $item->getAttribute('href'),
          qr<https://the\.kalaclista\.com/(posts|echos)/\d{4}/>
        );
      }
    }
  }
}

sub files {
  my $rootdir = shift;
  my @files   = Kalaclista::Files->find($rootdir);

  return (
    map  { path($_) }
    grep { $_ =~ m{(?:(?:posts|echos)/\d{4}|(?:posts|echos|notes))/index\.html$} } @files
  );
}

sub main {
  my $runner = Kalaclista::Sequential::Files->new( handle => \&testing );

  $runner->run( files( $dist->child('posts')->stringify ) );
  $runner->run( files( $dist->child('echos')->stringify ) );
  $runner->run( files( $dist->child('notes')->stringify ) );

  done_testing;
}

main;
