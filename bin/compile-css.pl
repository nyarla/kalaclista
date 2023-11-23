#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

BEGIN {
  if ( exists $ENV{'HARNESS_ACTIVE'} ) {
    use Test2::V0;
  }
}

use Kalaclista::Generators::Page;
use Kalaclista::Path;

use WebSite::Context;
use WebSite::Helper::Digest qw(digest);

my $c      = WebSite::Context->init(qr{^bin$});
my $digest = digest('lib/WebSite/Templates/Stylesheet.pm');
my $fn     = "main-${digest}.css";

sub doing {
  my $main      = $c->cache("cache/main-${digest}.css");
  my $normalize = $c->deps("css/normalize.css");
  my $template  = 'WebSite::Templates::Stylesheet';

  Kalaclista::Generators::Page->generate(
    dist     => $main,
    template => $template,
  );

  my $css   = $main->path;
  my $reset = $normalize->path;
  my $dist  = $c->dist($fn);

  $dist->parent->mkpath;
  `cat "${reset}" "${css}" | esbuild --minify --loader=css >"@{[ $dist->path ]}"`;
  return $?;
}

sub testing {
  ok try_ok( sub { doing } ), '`doing` subroutine should be callable';
  ok -e $c->dist($fn)->path,  'output file exists';

  done_testing;

  return 0;
}

sub main {
  exit( !exists $ENV{'HARNESS_ACTIVE'} ? doing(@ARGV) : testing );
}

main(@ARGV);
