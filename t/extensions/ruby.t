#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use HTML5::DOM;
use URI;

use Kalaclista::Directory;
use Kalaclista::Template;
use Kalaclista::Entry;

my $parser = HTML5::DOM->new( { script => 1 } );
my $dirs   = Kalaclista::Directory->instance;

my $entry =
    Kalaclista::Entry->new( $dirs->content_dir->child("entries/nyarla.md")->stringify, URI->new("https://the.kalaclista.com/nyarla/") );
my $simple   = $parser->parse('<p>{無|ム}</p>')->at('body');
my $multiple = $parser->parse('<p>{夏目漱石|なつ|め|そう|せき}</p>')->at('body');

my $extension = load( $dirs->templates_dir->child('extensions/ruby.pl')->stringify );

sub main {
  $entry->register($extension);

  $entry->{'dom'} = $simple;
  $entry->transform;

  is( $entry->dom->at('p')->html, '<p><ruby>無<rt>ム</rt></ruby></p>' );

  $entry->{'dom'} = $multiple;
  $entry->transform;

  is(
    $entry->dom->at('p')->html,
'<p><ruby>夏<rp>（</rp><rt>なつ</rt><rp>）</rp>目<rp>（</rp><rt>め</rt><rp>）</rp>漱<rp>（</rp><rt>そう</rt><rp>）</rp>石<rp>（</rp><rt>せき</rt><rp>）</rp></ruby></p>'
  );

  done_testing;
}

main;
