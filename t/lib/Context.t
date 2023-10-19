#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use WebSite::Context;

sub instance {
  my $env = shift;
  local $ENV{'KALACLISTA_ENV'} = $env;

  WebSite::Context->init( detect => qr{^t$} );
  return WebSite::Context->instance;
}

subtest production => sub {
  my $c;

  $c = instance('development');
  ok( !$c->production, 'if `KALACLISTA_ENV` is under the `development`, this method should return false' );

  $c = instance('production');
  ok( $c->production, 'if `KALACLISTA_ENV` is under the `production`, this method should return true' );
};

subtest baseURI => sub {
  my $c;

  $c = instance('development');
  isa_ok( $c->baseURI, 'URI::Fast' );
  is( $c->baseURI->to_string, 'http://nixos:1313' );

  $c = instance('production');
  isa_ok( $c->baseURI, 'URI::Fast' );
  is( $c->baseURI->to_string, 'https://the.kalaclista.com' );
};

subtest dirs => sub {
  my $c;

  $c = instance('development');
  isa_ok( $c->dirs, 'Kalaclista::Data::Directory' );

  $c = instance('production');
  isa_ok( $c->dirs, 'Kalaclista::Data::Directory' );
};

done_testing;
