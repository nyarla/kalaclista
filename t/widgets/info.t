#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use URI::Fast;
use HTML5::DOM;

use WebSite::Context;
local $ENV{'KALACLISTA_ENV'} = 'production';
WebSite::Context->init(qr{^t$});

use WebSite::Widgets::Info;

my $parser = HTML5::DOM->new;

sub main {
  my $info = siteinfo;
  utf8::decode($info);

  my $dom = $parser->parse($info)->at('body');

  is( $dom->at('footer')->getAttribute('id'),           'copyright' );
  is( $dom->at('footer > p > a')->getAttribute('href'), 'https://the.kalaclista.com/nyarla/' );

  is( $dom->at('footer > p')->textContent, qq{(c) 2006-@{[ (localtime)[5] + 1900 ]} OKAMURA Naoki aka nyarla} );

  my $info2 = siteinfo;
  utf8::decode($info2);

  is( $info, $info2 );

  done_testing;
}

main;
