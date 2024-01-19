#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use HTML5::DOM;

use WebSite::Context;
use WebSite::Widgets::Information;

my $parser = HTML5::DOM->new;
my $c      = WebSite::Context->init(qr{^t$});

sub href {
  my $path = shift;
  my $href = $c->baseURI;
  $href->path($path);

  return $href->to_string;
}

subtest information => sub {
  my $info = information;
  utf8::decode($info);
  my $dom = $parser->parse($info);

  is $dom->at('nav > ul > li:nth-child(1) > a')->textContent,          '運営ポリシー';
  is $dom->at('nav > ul > li:nth-child(1) > a')->getAttribute('href'), href('/policies/');

  is $dom->at('nav > ul > li:nth-child(3) > a')->textContent,          'ライセンスなど';
  is $dom->at('nav > ul > li:nth-child(3) > a')->getAttribute('href'), href('/licenses/');
};

subtest copyright => sub {
  my $html = copyright;
  utf8::decode($html);
  my $dom = $parser->parse($html);

  is $dom->at('p > a')->getAttribute('href'), href('/nyarla/');
  is $dom->at('p')->textContent,              '© 2006-' . ( (localtime)[5] + 1900 ) . ' OKAMURA Naoki aka nyarla';
};

done_testing;
