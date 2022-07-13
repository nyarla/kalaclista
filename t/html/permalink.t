#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use HTML5::DOM;
use JSON::Tiny qw(decode_json);
use HTML::Escape qw(escape_html);

use Kalaclista::HyperScript qw(text);
use Kalaclista::Directory;
use Kalaclista::Sequential::Files;

my $dist   = Kalaclista::Directory->new->rootdir->child('dist');
my $parser = HTML5::DOM->new( { script => 1 } );

sub testing {
  my $file = shift;

  my $dom = $parser->parse( $file->slurp_utf8 );

  # Headers
  # =======

  # title
  my $title = $dom->at('meta[property="og:title"]')->getAttribute('content');
  my $website =
    $dom->at('meta[property="og:site_name"]')->getAttribute('content');

  is( $dom->at('title')->textContent, "${title} - ${website}" );
  is( $dom->at('meta[name="twitter:title"]')->getAttribute('content'), $title );

  # description
  is(
    $dom->at('meta[property="og:description"]')->getAttribute('content'),
    $dom->at('meta[name="twitter:description"]')->getAttribute('content'),
  );
  is(
    $dom->at('meta[property="og:description"]')->getAttribute('content'),
    $dom->at('meta[name="description"]')->getAttribute('content'),
  );
  is(
    $dom->at('meta[name="twitter:description"]')->getAttribute('content'),
    $dom->at('meta[name="description"]')->getAttribute('content'),
  );

  # canonical
  like( $dom->at('link[rel="canonical"]')->getAttribute('href'),
qr(https://the\.kalaclista\.com/(?:(?:posts|echos)/\d{4}/\d{2}/\d{2}/\d{6}/|notes/[^/]+/))
  );

  # Contents
  # ========

  # date header
  like( $dom->at('.entry header p time')->textContent, qr(\d{4}-\d{2}-\d{2}：) );
  like( $dom->at('.entry header p span')->textContent, qr(読了まで：約\d+分) );

  # entry title
  like(
    $dom->at('.entry header h1 a')->getAttribute('href'),
qr<https://the\.kalaclista\.com/(?:(?:(?:posts|echos)/\d{4}/\d{2}/\d{2}/\d{6})|(?:notes/[^/]+/))>,
  );
}

sub main {
  my $runner = Kalaclista::Sequential::Files->new(
    handle => \&testing,
    result => sub { done_testing },
  );

  $runner->run( $dist->stringify, '*/*/*/*/*/index.html' );
}

main;
