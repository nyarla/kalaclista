#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;

use WebSite::Helper::TailwindCSS;

subtest preset => sub {
  subtest has => sub {
    my $count = warns {
      my $data = WebSite::Helper::TailwindCSS::preset('link');

      ok $data ne q{};
    };

    is $count, 0;
  };

  subtest hasnt => sub {
    my $msg = warning {
      my $data = WebSite::Helper::TailwindCSS::preset('__NOT_EXIST__');

      ok $data eq q{};
    };

    like $msg, qr/^this preset name of __NOT_EXIST__ is not defined/;
  };
};

subtest apply => sub {
  ok apply(qw(link)) ne q{};
};

subtest classes => sub {
  is classes(qw(foo bar baz)), 'bar baz foo';
};

subtest custom => sub {
  is custom(q|text-text bg-background|), 'bg-background text-text';
};

done_testing;
