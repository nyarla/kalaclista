#!/usr/bin/env perl

use strict;
use warnings;

use feature qw(state);

use Test2::V0 ':DEFAULT', '!prop';

use XML::LibXML;
use URI::Fast;

use WebSite::Context::Path qw(distdir srcdir);
use WebSite::Context::URI  qw(baseURI);
use WebSite::Loader::Entry qw(prop entry entries);

my sub xml { state $xml ||= XML::LibXML->load_xml( string => distdir->child('sitemap.xml')->load ); $xml }
my sub node {
  my $node = shift;
  return sub {
    my $xpath = shift;
    return $node->find($xpath)->[0]->textContent;
  };
}

subtest sitemap => sub {
  my $map = {};
  for my $node ( xml->findnodes('//*[name()="url"]') ) {
    my sub at { state $n ||= node($node); $n->(@_) }

    my $loc     = URI::Fast->new( at('*[name()="loc"]') );
    my $lastmod = at('*[name()="lastmod"]');

    like
        $lastmod,
        qr<^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[-+]\d{2}:\d{2}|Z)$>;

    is $loc->scheme, baseURI->scheme;
    is $loc->host,   baseURI->host;

    $map->{ $loc->path }++;
  }

  entries {
    map { ok delete $map->{ prop($_)->href->path } } @_
  };

  ok scalar( keys $map->%* ) == 0;
};

done_testing;
