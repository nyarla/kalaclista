#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;

use Kalaclista::Path;

use WebSite::Helper::MakeDirectory qw(depth mkpath);

subtest depth => sub {
  my $path = '/foo/bar/baz/qux';

  is depth($path), 4, 'The path depth is 4';
};

subtest mkpath => sub {
  my $path = Kalaclista::Path->tempdir->child('foo/bar/baz/qux.md');

  mkpath( $path->path );

  ok -d $path->parent->path, 'The parent dir of file exists';
};

done_testing;
