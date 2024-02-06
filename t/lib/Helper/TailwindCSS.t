#!/usr/bin/env perl

use strict;
use warnings;

use Test2::V0;

use WebSite::Helper::TailwindCSS;

subtest classes => sub {
  subtest list => sub {
    is classes(qw(foo bar baz)), { class => 'foo bar baz' };
  };

  subtest string => sub {
    is classes(q(foo bar baz)), { class => 'foo bar baz' };
  };

  subtest list_and_str => sub {
    is classes( qw(foo bar), q(baz) ), { class => 'foo bar baz' };
  };
};

done_testing;
