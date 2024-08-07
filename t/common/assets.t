#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;

use Kalaclista::Loader::Files qw(files);

use WebSite::Context::Path qw(srcdir distdir);

subtest assets => sub {
  my $srcdir  = srcdir->child('assets')->path;
  my $distdir = distdir->path;

  for my $path ( files $srcdir ) {
    my $file = $path;
    $file =~ s<${srcdir}><${distdir}>;
    $path =~ s<${srcdir}><>;

    diag $file;
    ok -e $file, "The file of '${path}' is exists on ${distdir}";
    unlike $path, qr<\.git>, "The path to '${file}' does not include '.git' directory";
  }
};

done_testing;
