#!/usr/bin/env perl

use v5.38;
use warnings;

BEGIN { $ENV{'KALACLISTA_ENV'} = 'test'; }

use Test2::V0;

use HTML5::DOM;
use URI::Fast;

use Kalaclista::Data::Entry;
use Kalaclista::Data::WebSite;

use Kalaclista::HyperScript qw(aside ul raw);

use WebSite::Loader::Products     qw(product);
use WebSite::Extensions::Products qw(cardify linkify apply);

my sub dom : prototype($) { state $p ||= HTML5::DOM->new; $p->parse(shift)->body }
my sub entry {
  state $entry ||= Kalaclista::Data::Entry->new(
    title   => '',
    summary => '',
    section => '',
    date    => '',
    lastmod => '',
    href    => URI::Fast->new('https://example.com/test'),
  );

  return $entry;
}

subtest linkify => sub {
  subtest amazon => sub {
    my $item = Kalaclista::Data::WebSite->new(
      title => '',
      href  => URI::Fast->new('https://amzn.to/XXXXXX'),
      gone  => !!0,
    );

    my $link = dom linkify($item)->to_string;

    is $link->at('li')->textContent, 'Amazon.co.jp で探す';
    like $link->at('li')->className, qr'amazon';
    is $link->at('li > a')->getAttribute('href'), $item->href->as_string;
  };

  subtest rakuten => sub {
    my $item = Kalaclista::Data::WebSite->new(
      title => '',
      href  => URI::Fast->new('https://a.r10.to/XXXXXX'),
      gone  => !!0,
    );

    my $link = dom linkify($item)->to_string;

    is $link->at('li')->textContent, '楽天で探す';
    like $link->at('li')->className, qr'rakuten';
    is $link->at('li > a')->getAttribute('href'), $item->href->as_string;
  };
};

subtest cardify => sub {
  subtest active => sub {
    my $product = product 'テスト・製品！';
    my $html    = cardify $product;
    my $dom     = dom aside( raw($html) )->to_string;

    is $dom->at('aside h2')->textContent,                            $product->title;
    is $dom->at('aside h2 a')->getAttribute('href'),                 $product->description->[0]->href->as_string;
    is $dom->at('aside ul li:nth-child(1) a')->getAttribute('href'), $product->description->[0]->href->as_string;
    is $dom->at('aside ul li:nth-child(1) a')->textContent,          "Amazon.co.jp で探す";
    is $dom->at('aside ul li:nth-child(2) a')->getAttribute('href'), $product->description->[1]->href->as_string;
    is $dom->at('aside ul li:nth-child(2) a')->textContent,          "楽天で探す";
  };

  subtest gone => sub {
    my $product = product '消滅';
    my $html    = cardify $product;
    my $dom     = dom aside( raw($html) )->to_string;

    is $dom->at('aside h2')->textContent,    $product->title;
    is $dom->at('aside ul li')->textContent, 'この商品の取り扱いは終了しました';
  };
};

subtest apply => sub {
  my $dom = dom '<p><a href="https://example.com/test">テスト・製品！</a></p>';
  apply $dom;

  is $dom->at('aside h2')->textContent,                            'テスト・製品！';
  is $dom->at('aside h2 a')->getAttribute('href'),                 'https://amzn.to/XXXXXX';
  is $dom->at('aside ul li:nth-child(1) a')->getAttribute('href'), 'https://amzn.to/XXXXXX';
  is $dom->at('aside ul li:nth-child(1) a')->textContent,          "Amazon.co.jp で探す";
  is $dom->at('aside ul li:nth-child(2) a')->getAttribute('href'), 'https://a.r10.to/XXXXXX';
  is $dom->at('aside ul li:nth-child(2) a')->textContent,          "楽天で探す";
};

subtest transform => sub {
  my $entry  = entry;
  my $expect = WebSite::Extensions::Products->transform($entry);

  is $entry, $expect;

  $entry = $entry->clone( dom => dom('<p><a href="https://example.com/product">テスト・製品！</a></p>') );
  $entry = WebSite::Extensions::Products->transform($entry);

  isnt $entry, $expect;

  ok $entry->dom->at('aside.content__card--affiliate');

};

done_testing;
