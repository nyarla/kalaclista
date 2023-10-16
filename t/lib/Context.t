#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;
use WebSite::Context;

subtest production => sub {
  my $c = WebSite::Context->new( detect => qr{^t$} );

  local $ENV{'KALACLISTA_ENV'} = 'development';
  ok !$c->production, 'if `KALACLISTA_ENV` is not `production`, this method returns false';

  local $ENV{'KALACLISTA_ENV'} = 'production';
  ok $c->production, 'if `KALACLISTA_ENV` is `production`, this method returns true';
};

subtest baseURI => sub {
  my $c = WebSite::Context->new( detect => qr{^t$} );

  local $ENV{'KALACLISTA_ENV'} = 'development';
  is(
    $c->baseURI->to_string,
    'http://nixos:1313',
    'if `KALACLISTA_ENV` is not `production`, this method returns development url'
  );

  local $ENV{'KALACLISTA_ENV'} = 'production';
  is(
    $c->baseURI->to_string,
    'https://the.kalaclista.com',
    'if `KALACLISTA_ENV` is not `production`, this method returns development url'
  );
};

subtest dirs => sub {
  my $c = WebSite::Context->new( detect => qr{^t$} );

  isa_ok $c->dirs, 'Kalaclista::Data::Directory';

  is $c->dirs, $c->dirs;
};

done_testing;
