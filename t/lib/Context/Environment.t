#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;

use WebSite::Context::Environment qw(detect env);

subtest warning => sub {
  subtest warn1 => sub {
    my $msg = warning {
      delete $ENV{'KALACLISTA_ENV'};
      my $env = detect;

      ok !$env->production;
      ok $env->development;
      ok !$env->staging;
      ok !$env->test;
    };

    like $msg, qr{^KALACLISTA_ENV is not defined; fallback to `development`};
  };

  subtest warn2 => sub {
    my $msg = warning {
      $ENV{'KALACLISTA_ENV'} = 'unsupported';
      my $env = detect;

      ok !$env->production;
      ok $env->development;
      ok !$env->staging;
      ok !$env->test;
    };

    like $msg, qr{^unsupported KALACLISTA_ENV: unsupported; fallback to `development`};
  };
};

subtest stage => sub {
  subtest production => sub {
    $ENV{'KALACLISTA_ENV'} = 'production';
    my $env = detect;

    ok $env->production;
    ok !$env->development;
    ok !$env->staging;
    ok !$env->test;
  };

  subtest development => sub {
    $ENV{'KALACLISTA_ENV'} = 'development';
    my $env = detect;

    ok !$env->production;
    ok $env->development;
    ok !$env->staging;
    ok !$env->test;
  };

  subtest staging => sub {
    $ENV{'KALACLISTA_ENV'} = 'staging';
    my $env = detect;

    ok !$env->production;
    ok !$env->development;
    ok $env->staging;
    ok !$env->test;
  };

  subtest test => sub {
    $ENV{'KALACLISTA_ENV'} = 'test';
    my $env = detect;

    ok !$env->production;
    ok !$env->development;
    ok !$env->staging;
    ok $env->test;
  };
};

subtest on => sub {
  $ENV{'KALACLITA_ENV'} = 'production';

  subtest runtime => sub {
    delete $ENV{'CI'};
    delete $ENV{'IN_PERL_SHELL'};

    my $env = detect;

    ok !$env->ci;
    ok !$env->local;
    ok $env->runtime;
  };

  subtest local => sub {
    delete $ENV{'CI'};
    $ENV{'IN_PERL_SHELL'} = "1";

    my $env = detect;

    ok !$env->ci;
    ok $env->local;
    ok !$env->runtime;
  };

  subtest ci => sub {
    $ENV{'CI'}            = 'true';
    $ENV{'IN_PERL_SHELL'} = "1";

    my $env = detect;

    ok $env->ci;
    ok !$env->local;
    ok !$env->runtime;
  };
};

subtest env => sub {
  $ENV{'KALACLISTA_ENV'} = 'production';
  $ENV{'CI'}             = 'true';

  my $expect = detect;
  my $env    = env;

  for my $method (qw(production development staging test ci local runtime)) {
    is $env->$method, $expect->$method;
  }

  $ENV{'KALACLISTA_ENV'} = 'development';

  my $new = env(detect);

  ok !$new->production;
  ok $new->development;
};

done_testing;
