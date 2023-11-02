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

my $dirs   = WebSite::Context->init(qr{^bin$})->dirs;
my $digest = digest('lib/WebSite/Templates/Stylesheet.pm');
my $dist   = $dirs->dist("main-${digest}.css")->path;

sub doing {
  my $main      = $dirs->cache("css/main-${digest}.css");
  my $normalize = $dirs->rootdir->child("deps/css/normalize.css");
  my $template  = 'WebSite::Templates::Stylesheet';

  Kalaclista::Generators::Page->generate(
    dist     => $main,
    template => $template,
  );

  my $css   = $main->path;
  my $reset = $normalize->path;

  `cat "${reset}" "${css}" | esbuild --minify --loader=css >"${dist}"`;
  return $?;
}

sub testing {
  ok try_ok( sub { doing } ), '`doing` subroutine should be callable';
  ok -e $dist,                'output file exists';

  done_testing;
}

sub main {
  exit( !exists $ENV{'HARNESS_ACTIVE'} ? doing(@ARGV) : testing );
}

main(@ARGV);
