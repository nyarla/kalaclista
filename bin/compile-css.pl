#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Kalaclista::Generators::Page;
use Kalaclista::Path;

use WebSite::Helper::Digest qw(digest);

my $rootdir = Kalaclista::Path->detect(qr{^bin$});
my $digest  = digest('lib/WebSite/Templates/Stylesheet.pm');
my $dist    = $rootdir->child("public/dist/main-${digest}.css")->path;

sub doing {
  my $main      = $rootdir->child("cache/css/main-${digest}.css");
  my $normalize = $rootdir->child("deps/css/normalize.css");
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
  require Test2::V0;
  "Test2::V0"->import;

  ok( try_ok( sub { doing; } ), 'doing subroutine has no error.' );
  ok( ( -e $dist ),             "output file exists." );

  done_testing();
}

sub main {
  exit( !exists $ENV{'HARNESS_ACTIVE'} ? doing(@ARGV) : testing );
}

main(@ARGV);
