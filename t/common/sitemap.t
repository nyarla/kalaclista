#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0 qw(!prop);

use XML::LibXML;

use Kalaclista::Loader::Files qw(files);

use WebSite::Context::Path qw(srcdir distdir);
use WebSite::Loader::Entry qw(prop);

my sub xml { state $xml ||= XML::LibXML->load_xml( string => distdir->child('sitemap.xml')->load ); $xml }
my sub node {
  my $node = shift;
  return sub {
    my $xpath = shift;
    return $node->find($xpath)->[0]->textContent;
  }
}

subtest 'sitemap.xml' => sub {
  my $srcdir   = srcdir->child('entries/src')->path;
  my $articles = {};
  $articles->{ $_->href->to_string } = $_->updated for map { s<${srcdir}><>; prop $_ } files $srcdir;

  for my $node ( xml->findnodes('//*[name()="url"]') ) {
    my sub at { state $n ||= node($node); $n->(@_) }

    my $loc     = at('*[name()="loc"]');
    my $lastmod = at('*[name()="lastmod"]');

    subtest $loc => sub {
      my $data = delete $articles->{$loc};

      ok $data, "The `sitemap.xml` includes information";
      is $lastmod, $data, 'The data of `sitemap.xml` is point to right lastmodified date';
    };
  }

  ok keys $articles->%* == 0, 'The `sitemap.xml` has all articles via markdown sources';
};

done_testing;
