#!/usr/bin/env perl

use strict;
use warnings;

use feature qw(state);

use Test2::V0;

use Kalaclista::Path;
use Kalaclista::Loader::Files qw(files);

use WebSite::Context::Path qw(distdir srcdir);

my sub src  { state $dir ||= srcdir->child('images');  $dir }
my sub dist { state $dir ||= distdir->child('images'); $dir }

subtest compiled => sub {
  my $prefix = src->path;

  map {
    my $path = $_;
    $path =~ s|^$prefix/||;

    my ( $dirname, $basename, $extension ) = ( $path =~ m{^(.+)/([^/]+)\.([^.]+)$} );

    my $dir = dist->child($dirname);
    my $ext = $extension eq 'gif' ? 'gif' : 'webp';

    ok -e $dir->child("${basename}_1x.${ext}")->to_string;
    ok -e $dir->child("${basename}_2x.${ext}")->to_string;
  } files src->path;
};

done_testing;
