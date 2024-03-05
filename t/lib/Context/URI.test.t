#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;

use WebSite::Context::URI;

my $stage = ( __FILE__ =~ m{([^\.]+)\.t$} )[0];

subtest $stage => sub {
  local $ENV{'KALACLISTA_ENV'} = $stage;

  subtest baseURI => sub {
    my $baseURI = baseURI;

    if ( $stage eq q{production} ) {
      is $baseURI->to_string, q{https://the.kalaclista.com};
    }

    if ( $stage eq q{development} ) {
      is $baseURI->to_string, q{http://nixos:1313};
    }

    if ( $stage eq q{staging} ) {
      is $baseURI->to_string, q{http://nixos:1313};
    }

    if ( $stage eq q{test} ) {
      is $baseURI->to_string, q{https://example.com};
    }
  };

  subtest href => sub {
    my $href = href '/foo/bar/baz';

    is $href->host, baseURI->host;
    is $href->path, '/foo/bar/baz';
  };
};

done_testing;
