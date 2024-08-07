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
    utf8::decode($path);

    subtest $path => sub {
      my $file = $path;
      $file =~ s<${srcdir}><${distdir}>;

      ok -e $file, 'The file is deployed to distribution dir';
      unlike $file, qr<\.git>, "The path does not include '.git' directory.";
    };
  }
};

done_testing;
