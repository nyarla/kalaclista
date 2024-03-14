#!/usr/bin/env perl

use v5.38;
use utf8;

BEGIN {
  $ENV{'KALACLISTA_ENV'} = 'test';
}

use Test2::V0;

use WebSite::Loader::WebSite qw(external);
use WebSite::Context::Path   qw(srcdir);

WebSite::Loader::WebSite->init( srcdir->child('data/website.csv')->to_string );

subtest external => sub {
  subtest exists => sub {
    my $website = external "てすと", 'https://example.com/website';

    is $website->title,           'これはテストです';
    is $website->link->to_string, 'https://example.com/website';
    is $website->href->to_string, 'https://example.com/website';
    is $website->gone,            !!0;
  };

  subtest gone => sub {
    my $website = external "てすと", 'https://example.com/foo/bar';

    is $website->title,           'これはテストです';
    is $website->link->to_string, 'https://example.com/gone';
    is $website->href->to_string, 'https://example.com/foo/bar';
    is $website->gone,            !!1;

    is $website, ( external "テスト", 'https://example.com/gone' );
  };

  subtest fallback => sub {
    my $website = external "テスト", 'https://example.com';

    is $website->title,           'テスト';
    is $website->link->to_string, 'https://example.com';
    is $website->href->to_string, 'https://example.com';
    is $website->gone,            !!0;
  };
};

done_testing;
