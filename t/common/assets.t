#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;

use Kalaclista::Loader::Files qw(files);

use WebSite::Context::Path qw(srcdir distdir);

subtest assets => sub {
  my $src = srcdir->child('assets')->to_string;
  map { my $path = $_; $path =~ s{^$src/}{}; ok -e distdir->child($path)->path } files $src;
};

done_testing;
