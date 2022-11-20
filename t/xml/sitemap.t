#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use XML::LibXML;
use URI::Fast;

use Kalaclista::Path;

my $dist = Kalaclista::Path->detect(qr{^t$})->child('public/dist');

sub at {
  my $xml = shift;
  return sub {
    my $xpath = shift;
    return $xml->find($xpath)->[0]->textContent;
  };
}

sub main {
  my $xml = XML::LibXML->load_xml( string => $dist->child('sitemap.xml')->get );

  my %found;
  for my $node ( $xml->findnodes('//*[name()="url"]') ) {
    my $at = at($node);

    my $loc     = URI::Fast->new( $at->('*[name()="loc"]') );
    my $lastmod = $at->('*[name()="lastmod"]');

    like(
      $lastmod,
      qr<^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[-+]\d{2}:\d{2}|Z)$>,
    );

    is( $loc->scheme, 'https' );
    is( $loc->host,   'the.kalaclista.com' );

    my @paths = split qr{/}, $loc->path;

    if ( $paths[1] eq 'nyarla' || $paths[1] eq 'licenses' || $paths[1] eq 'policies' ) {
      $found{'pages'}++;

      ok( @paths == 2 );
      next;
    }

    if ( $paths[1] eq 'posts' || $paths[1] eq 'echos' ) {
      $found{ $paths[1] }++;

      if ( @paths == 3 ) {
        like( $paths[2], qr<\d{4}> );
        next;
      }

      like( $paths[2], qr<\d{4}> );
      like( $paths[3], qr<\d{2}> );
      like( $paths[4], qr<\d{2}> );
      like( $paths[5], qr<\d{6}> );

      ok( @paths == 6 );
      next;
    }

    if ( $paths[1] eq 'notes' ) {
      $found{'notes'}++;
      ok( @paths == 3 );
      next;
    }

    fail( "unknown url: " . ( join q{/}, @paths ) . "/" );
  }

  ok( $found{'pages'} > 0 );
  ok( $found{'posts'} > 0 );
  ok( $found{'echos'} > 0 );
  ok( $found{'notes'} > 0 );

  done_testing;
}

main;
