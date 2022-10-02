#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use HTML5::DOM;

use Kalaclista::Directory;
use Kalaclista::Template;
use Kalaclista::Entry::Meta;
use Kalaclista::Entry::Content;

my $parser = HTML5::DOM->new( { script => 1 } );
my $dirs   = Kalaclista::Directory->instance;

my $meta     = Kalaclista::Entry::Meta->new();
my $simple   = Kalaclista::Entry::Content->new( dom => $parser->parse('<p>{無|ム}</p>')->at('body') );
my $multiple = Kalaclista::Entry::Content->new( dom => $parser->parse('<p>{夏目漱石|なつ|め|そう|せき}</p>') );

my $transformer =
    load( $dirs->templates_dir->child('extensions/ruby.pl')->stringify )->($meta);

sub main {
  $simple->transform($transformer);

  is( $simple->dom->at('p')->html, '<p><ruby>無<rt>ム</rt></ruby></p>' );

  $multiple->transform($transformer);

  is(
    $multiple->dom->at('p')->html,
'<p><ruby>夏<rp>（</rp><rt>なつ</rt><rp>）</rp>目<rp>（</rp><rt>め</rt><rp>）</rp>漱<rp>（</rp><rt>そう</rt><rp>）</rp>石<rp>（</rp><rt>せき</rt><rp>）</rp></ruby></p>'
  );

  done_testing;
}

main;
