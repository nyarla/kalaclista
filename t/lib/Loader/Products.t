#!/usr/bin/env perl

use v5.38;
use utf8;

BEGIN {
  $ENV{'KALACLISTA_ENV'} = 'test';
}

use Test2::V0;

use WebSite::Loader::Products qw(product);
use WebSite::Context::Path    qw(srcdir);

WebSite::Loader::Products->init( srcdir->child('data/products.csv')->to_string );

subtest exists => sub {
  subtest active => sub {
    my $product = product 'テスト・製品！';

    is $product->type,                              'product';
    is $product->title,                             'テスト・製品！';
    is $product->thumbnail,                         undef;                       # TODO: support to thumbnail
    is $product->description->[0]->title,           'テスト・製品！';
    is $product->description->[0]->href->to_string, 'https://amzn.to/XXXXXX';
    is $product->description->[0]->gone,            !!0;
    is $product->description->[1]->title,           'テスト・製品！';
    is $product->description->[1]->href->to_string, 'https://a.r10.to/XXXXXX';
    is $product->description->[1]->gone,            !!0;
  };

  subtest gone => sub {
    my $product = product '消​滅';

    is $product->type,                   'product';
    is $product->title,                  '消滅';
    is $product->thumbnail,              undef;
    is $product->description->[0]->gone, !!1;
    is $product->description->[1]->gone, !!1;
  };
};

subtest none => sub {
  is product('そんなものは無い'), undef;
};

done_testing;
