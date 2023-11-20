#!/usr/bin/env perl

use v5.38;
use builtin qw(true false);

use Test2::V0;
use WebSite::Context;

sub instance {
  my ( $stage, $on ) = @_;
  local $ENV{'KALACLISTA_ENV'} = $stage;

  if ( $on eq 'runtime' ) {
    delete $ENV{'CI'}            if exists $ENV{'CI'};
    delete $ENV{'IN_PERL_SHELL'} if exists $ENV{'IN_PERL_SHELL'};
  }
  elsif ( $on eq 'ci' ) {
    $ENV{'CI'} = "true";
    delete $ENV{'IN_PERL_SHELL'} if exists $ENV{'IN_PERL_SHELL'};
  }
  else {
    delete $ENV{'CI'} if exists $ENV{'CI'};
    $ENV{'IN_PERL_SHELL'} = 1;
  }

  return WebSite::Context->init(qr{^t$});
}

subtest context => sub {
  no warnings qw(experimental);

  subtest stage => sub {
    subtest production => sub {
      my $c = instance( production => 'runtime' );

      is $c->env->production,    true;
      is $c->baseURI->to_string, 'https://the.kalaclista.com';
      like $c->distdir->path,        qr{public/dist$};
      like $c->entries->path,        qr{src/entries/src$};
      like $c->dirs->cachedir->path, qr{cache/production$};
    };

    subtest staging => sub {
      my $c = instance( staging => 'runtime' );

      is $c->env->staging,       true;
      is $c->baseURI->to_string, 'http://nixos:1313';
      like $c->distdir->path,        qr{public/test$};
      like $c->entries->path,        qr{src/entries/src$};
      like $c->dirs->cachedir->path, qr{cache/staging$};
    };

    subtest development => sub {
      my $c = instance( development => 'runtime' );

      is $c->env->development,   true;
      is $c->baseURI->to_string, 'http://nixos:1313';
      like $c->distdir->path,        qr{public/dev$};
      like $c->entries->path,        qr{src/entries/src$};
      like $c->dirs->cachedir->path, qr{cache/development$};
    };

    subtest test => sub {
      my $c = instance( test => 'runtime' );

      is $c->env->test,          true;
      is $c->baseURI->to_string, 'https://example.com';
      like $c->distdir->path,        qr{public/test$};
      like $c->entries->path,        qr{t/fixtures/entries/src$};
      like $c->dirs->cachedir->path, qr{cache/test$};
    };
  };

  subtest on => sub {
    subtest ci => sub {
      my $c = instance( test => 'ci' );

      is $c->env->ci, true;
    };

    subtest local => sub {
      my $c = instance( test => 'local' );

      is $c->env->local, true;
    };

    subtest runtime => sub {
      my $c = instance( test => 'runtime' );

      is $c->env->runtime, true;
    };
  };
};

subtest baseURI => sub {
  no warnings qw(experimental);

  subtest production => sub {
    my $c = instance( production => 'runtime' );

    isa_ok $c->baseURI, 'URI::Fast';
    is $c->baseURI->to_string, 'https://the.kalaclista.com';
  };

  subtest development => sub {
    my $c = instance( development => 'runtime' );

    isa_ok $c->baseURI, 'URI::Fast';
    is $c->baseURI->to_string, 'http://nixos:1313';
  };

  subtest staging => sub {
    my $c = instance( staging => 'runtime' );

    isa_ok $c->baseURI, 'URI::Fast';
    is $c->baseURI->to_string, 'http://nixos:1313';
  };

  subtest test => sub {
    my $c = instance( test => 'runtime' );

    isa_ok $c->baseURI, 'URI::Fast';
    is $c->baseURI->to_string, 'https://example.com';
  };
};

subtest dirs => sub {
  no warnings qw(experimental);

  subtest production => sub {
    my $c = instance( production => 'runtime' );

    isa_ok $c->dirs, 'Kalaclista::Data::Directory';
  };

  subtest development => sub {
    my $c = instance( development => 'runtime' );

    isa_ok $c->dirs, 'Kalaclista::Data::Directory';
  };

  subtest staging => sub {
    my $c = instance( staging => 'runtime' );

    isa_ok $c->dirs, 'Kalaclista::Data::Directory';
  };

  subtest test => sub {
    my $c = instance( test => 'runtime' );

    isa_ok $c->dirs, 'Kalaclista::Data::Directory';
  };
};

done_testing;
