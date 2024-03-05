#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;

use WebSite::Context::Path;

my $stage = ( __FILE__ =~ m{([^\.]+)\.t$} )[0];

subtest $stage => sub {
  local $ENV{'KALACLISTA_ENV'} = $stage;

  diag rootdir->to_string;

  subtest distdir  => sub { is distdir->path,  rootdir->child("dist/${stage}")->to_string };
  subtest cachedir => sub { is cachedir->path, rootdir->child("cache/${stage}")->to_string };

  subtest srcdir => sub {
    if ( $stage eq 'test' ) {
      is srcdir->path, rootdir->child('t/fixtures')->to_string;
    }
    else {
      is srcdir->path, rootdir->child('src')->to_string;
    }
  };
};

done_testing;
