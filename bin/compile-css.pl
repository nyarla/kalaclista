#!/usr/bin/env perl

use v5.38;
use utf8;

use Module::Load qw(autoload);
use Test2::V0;

use Kalaclista::Generators::Page;

use WebSite::Context::Path  qw(rootdir distdir cachedir);
use WebSite::Helper::Digest qw(digest);

sub doing {
  my $template = 'WebSite::Templates::Stylesheet';
  my $digest   = digest('lib/WebSite/Templates/Stylesheet.pm');

  my $out  = cachedir->child("main-${digest}.css");
  my $deps = rootdir->child('deps/css/normalize.css');

  Kalaclista::Generators::Page->generate(
    dist     => $out,
    template => $template,
  );

  my $css       = $out->path;
  my $normalize = $deps->path;

  my $dist = distdir->child("main-${digest}.css");
  $dist->parent->mkpath;

  `cat '${css}' '${normalize}' | esbuild --minify --loader=css >'@{[ $dist->path ]}'`;
  return $?;
}

sub testing {
  my $digest  = digest('lib/WebSite/Templates/Stylesheet.pm');
  my $success = try_ok sub { doing };

  ok $success,                                      'should succeed';
  ok -e distdir->child("main-${digest}.css")->path, 'output file exists';

  done_testing;

  return 0;
}

sub main {
  exit( !exists $ENV{'HARNESS_ACTIVE'} ? doing(@ARGV) : testing );
}

main(@ARGV);
