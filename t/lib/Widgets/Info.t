#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;
use URI::Fast;
use HTML5::DOM;

use WebSite::Context::URI qw(href);

use WebSite::Widgets::Info qw(siteinfo);

my sub dom : prototype($) { state $p ||= HTML5::DOM->new; $p->parse(shift)->body }

subtest footer => sub {
  my $footer = siteinfo;
  utf8::decode($footer);

  my $dom = dom($footer)->at('footer#copyright');

  is $dom->at('p')->textContent,      "© 2006-@{[ (localtime)[5] + 1900 ]} OKAMURA Naoki aka nyarla";
  is $dom->at('p > a')->attr('href'), href('/nyarla/')->to_string;
};

done_testing;
