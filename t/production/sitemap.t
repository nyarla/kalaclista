#!/usr/bin/env perl

use strict;
use warnings;

use feature qw(state);

use Test2::V0;

use XML::LibXML;
use URI::Fast;
use URI::Escape::XS qw(uri_unescape);

use Kalaclista::Files;
use Kalaclista::Entry;

use WebSite::Context;

sub c {
  state $c ||= WebSite::Context->init(qr{^t$});
  return $c;
}

sub xml {
  state $xml ||= XML::LibXML->load_xml( string => c->dist('sitemap.xml')->get );

  return $xml;
}

sub node {
  my $node = shift;
  return sub {
    my $xpath = shift;
    return $node->find($xpath)->[0]->textContent;
  };
}

sub path_from_fs {
  my $fs     = shift;
  my $prefix = c->entries->path;
  my $path   = $fs;

  $path =~ s{$prefix}{};
  $path =~ s{\.md}{/};

  if ( $path =~ m{/notes/} ) {
    my $entry = Kalaclista::Entry->new( path => $fs );
    $entry->load if !$entry->loaded;

    my $slug = $entry->meta('slug');
    if ( $slug ne q{} ) {
      utf8::decode($slug);
      $path = "/notes/${slug}/";
    }

    $path =~ s{ }{-}g;
  }

  return $path;
}

sub path_from_href {
  my $href = shift;
  my $path = uri_unescape($href);
  utf8::decode($path);

  return $path;
}

sub has {
  state $entries ||= do {
    +{ map { path_from_fs($_) => 1 } Kalaclista::Files->find( c->entries->path ) };
  };

  my $path = shift;
  return exists $entries->{$path};
}

subtest common => sub {
  for my $node ( xml->findnodes('//*[name()="url"]') ) {
    my sub at { state $n ||= node($node); $n->(@_) }

    my $loc     = URI::Fast->new( at('*[name()="loc"]') );
    my $lastmod = at('*[name()="lastmod"]');

    like $lastmod, qr<^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[-+]\d{2}:\d{2}|Z)$>;

    is $loc->scheme, c->baseURI->scheme;
    is $loc->host,   c->baseURI->host;

    my $path = $loc->path;
    $path = path_from_href($path);

    ok has($path), $path;
  }
};

if ( c->production ) {
  subtest production => sub {
    my $posts = grep { $_ =~ m{/posts/} } Kalaclista::Files->find( c->entries->path );
    my $echos = grep { $_ =~ m{/echos/} } Kalaclista::Files->find( c->entries->path );
    my $notes = grep { $_ =~ m{/notes/} } Kalaclista::Files->find( c->entries->path );
    my $pages = [qw( nyarla policies licenses )]->@*;

    my @entries;
    for my $node ( xml->findnodes('//*[name()="url"]') ) {
      my sub at { state $n ||= node($node); $n->(@_) }
      push @entries, at('*[name()="loc"]');
    }

    is $posts, scalar( grep { $_ =~ m{/posts/} } @entries );
    is $echos, scalar( grep { $_ =~ m{/echos/} } @entries );
    is $notes, scalar( grep { $_ =~ m{/notes/} } @entries );

    is $pages, scalar( grep { $_ !~ m{/(?:posts|echos|notes)/} } @entries );
  };
}

if ( c->staging ) {
  subtest staging => sub { };
}

if ( c->development ) {
  subtest development => sub { };
}

if ( c->test ) {
  subtest test => sub { };
}

done_testing;
