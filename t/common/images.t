#!/usr/bin/env perl

use v5.38;
use utf8;

use feature qw(state);

use Test2::V0;

use Kalaclista::Path;
use Kalaclista::Loader::Files qw(files);

use WebSite::Context::Path qw(distdir srcdir);

subtest compiled => sub {
  my $srcdir  = srcdir->child('images')->path;
  my $distdir = distdir->child('images')->path;

  for my $file ( files $srcdir ) {
    utf8::decode($file);

    subtest $file => sub {
      unlike $file, qr<\.git>, 'The file path does not exists `.git` directory';

      my ( $path, $ext ) = $file =~ m<^${srcdir}/([^.]+)\.([^.]+)$>;

      my $fn_x1 = $ext eq 'gif' ? "${path}_1x.gif" : "${path}_1x.webp";
      my $fn_x2 = $ext eq 'gif' ? "${path}_2x.gif" : "${path}_2x.webp";

      ok -e "${distdir}/${fn_x1}", "the 1x scaled file is deployed to distribution directory.";
      ok -e "${distdir}/${fn_x2}", "The 2x scaled file is deployed to distribution directory.";
    };
  }
};

done_testing;
