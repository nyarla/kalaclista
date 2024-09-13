#!/usr/bin/env perl

use v5.38;
use utf8;

BEGIN {
  $ENV{'KALACLISTA_ENV'} = 'test';
}

use Test2::V0;
use HTML5::DOM;
use URI::Fast;

use Kalaclista::Data::Entry;

use WebSite::Context::Path             qw(srcdir);
use WebSite::Extensions::CodeHighlight qw(apply);

my sub dom { state $p ||= HTML5::DOM->new; $p->parse(shift)->body }
my sub entry {
  state $entry ||= Kalaclista::Data::Entry->new(
    title   => '',
    summary => '',
    section => '',
    date    => '',
    lastmod => '',
    href    => URI::Fast->new('https://example.com/test'),
    meta    => {
      path => 'posts/2023/01/01/000000.md',
    },
  );

  return $entry;
}

subtest apply => sub {
  my $meta = {};
  my $path = 'posts/2023/01/01/000000.md';
  my $file = srcdir->child('entries/precompiled')->child($path);
  my $html = $file->load;
  utf8::decode($html);

  my $dom = dom $html;

  apply $path, $meta, $dom;

  ok $meta->{'css'};
  is scalar( $meta->{'css'}->@* ), 1;

  ok $dom->at('pre > code span');
};

subtest transform => sub {
  my $entry  = entry;
  my $expect = WebSite::Extensions::CodeHighlight->transform($entry);

  is $entry, $expect;

  my $html = srcdir->child('entries/precompiled')->child('posts/2023/01/01/000000.md')->load;
  utf8::decode($html);
  my $dom = dom $html;

  $entry = $entry->clone( dom => $dom );
  $entry = WebSite::Extensions::CodeHighlight->transform($entry);

  ok $entry->dom->at('pre > code span.Statement'),;
};

done_testing;
