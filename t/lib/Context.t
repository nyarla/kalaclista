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

      is $c->production,  true;
      is $c->staging,     false;
      is $c->development, false;
      is $c->test,        false;

      is $c->baseURI->to_string, 'https://the.kalaclista.com';
      like $c->cache->path,   qr{cache/production/$};
      like $c->data->path,    qr{src/data/$};
      like $c->deps->path,    qr{deps/$};
      like $c->dist->path,    qr{public/production/$};
      like $c->entries->path, qr{src/entries/src$};
      like $c->src->path,     qr{src/$};
    };

    subtest staging => sub {
      my $c = instance( staging => 'runtime' );

      is $c->production,  false;
      is $c->staging,     true;
      is $c->development, false;
      is $c->test,        false;

      is $c->baseURI->to_string, 'http://nixos:1313';
      like $c->dist->path,    qr{public/staging/$};
      like $c->data->path,    qr{src/data/$};
      like $c->deps->path,    qr{deps/$};
      like $c->entries->path, qr{src/entries/src$};
      like $c->cache->path,   qr{cache/staging/$};
    };

    subtest development => sub {
      my $c = instance( development => 'runtime' );

      is $c->production,  false;
      is $c->staging,     false;
      is $c->development, true;
      is $c->test,        false;

      is $c->baseURI->to_string, 'http://nixos:1313';
      like $c->dist->path,    qr{public/development/$};
      like $c->data->path,    qr{src/data/$};
      like $c->deps->path,    qr{deps/$};
      like $c->entries->path, qr{src/entries/src$};
      like $c->cache->path,   qr{cache/development/$};
    };

    subtest test => sub {
      my $c = instance( test => 'runtime' );

      is $c->production,  false;
      is $c->staging,     false;
      is $c->development, false;
      is $c->test,        true;

      is $c->baseURI->to_string, 'https://example.com';
      like $c->dist->path,    qr{public/test/$};
      like $c->data->path,    qr{t/fixtures/data/$};
      like $c->deps->path,    qr{deps/$};
      like $c->entries->path, qr{t/fixtures/entries/src$};
      like $c->cache->path,   qr{cache/test/$};
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

subtest website => sub {
  no warnings qw(experimental);

  subtest common => sub {
    my $c = instance( production => 'runtime' );

    is $c->website->label,   'カラクリスタ';
    is $c->website->title,   'カラクリスタ';
    is $c->website->summary, '『輝かしい青春』なんて失かった人の Web サイトです';

    is $c->sections->{'posts'}->label,   'ブログ';
    is $c->sections->{'posts'}->title,   'カラクリスタ・ブログ';
    is $c->sections->{'posts'}->summary, '『輝かしい青春』なんて失かった人のブログです';

    is $c->sections->{'echos'}->label,   '日記';
    is $c->sections->{'echos'}->title,   'カラクリスタ・エコーズ';
    is $c->sections->{'echos'}->summary, '『輝かしい青春』なんて失かった人の日記です';

    is $c->sections->{'notes'}->label,   'メモ帳';
    is $c->sections->{'notes'}->title,   'カラクリスタ・ノート';
    is $c->sections->{'notes'}->summary, '『輝かしい青春』なんて失かった人のメモ帳です';
  };

  subtest production => sub {
    my $c = instance( production => 'runtime' );
    is $c->website->href->to_string,             'https://the.kalaclista.com';
    is $c->sections->{'posts'}->href->to_string, 'https://the.kalaclista.com/posts/';
    is $c->sections->{'echos'}->href->to_string, 'https://the.kalaclista.com/echos/';
    is $c->sections->{'notes'}->href->to_string, 'https://the.kalaclista.com/notes/';
  };

  subtest development => sub {
    my $c = instance( development => 'runtime' );
    is $c->website->href->to_string,             'http://nixos:1313';
    is $c->sections->{'posts'}->href->to_string, 'http://nixos:1313/posts/';
    is $c->sections->{'echos'}->href->to_string, 'http://nixos:1313/echos/';
    is $c->sections->{'notes'}->href->to_string, 'http://nixos:1313/notes/';
  };

  subtest staging => sub {
    my $c = instance( staging => 'runtime' );
    is $c->website->href->to_string,             'http://nixos:1313';
    is $c->sections->{'posts'}->href->to_string, 'http://nixos:1313/posts/';
    is $c->sections->{'echos'}->href->to_string, 'http://nixos:1313/echos/';
    is $c->sections->{'notes'}->href->to_string, 'http://nixos:1313/notes/';
  };

  subtest test => sub {
    my $c = instance( test => 'runtime' );
    is $c->website->href->to_string,             'https://example.com';
    is $c->sections->{'posts'}->href->to_string, 'https://example.com/posts/';
    is $c->sections->{'echos'}->href->to_string, 'https://example.com/echos/';
    is $c->sections->{'notes'}->href->to_string, 'https://example.com/notes/';
  };
};

done_testing;
