#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;

use WebSite::Helper::Digest qw(digest);

subtest digest => sub {
  my $digest = digest('t/lib/Helper/Digest.t');

  like $digest, qr(^[a-f0-9]{7}$);
};

done_testing;
