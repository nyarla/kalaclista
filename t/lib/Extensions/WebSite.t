#!/usr/bin/env perl

use v5.38;
use warnings;

BEGIN { $ENV{'KALACLISTA_ENV'} = 'test'; }

use Test2::V0;

use HTML5::DOM;
use URI::Fast;

use Kalaclista::Data::Entry;
use Kalaclista::Data::WebSite;

use WebSite::Loader::WebSite     qw(external);
use WebSite::Extensions::WebSite qw(cardify apply);

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

subtest cardify => sub {
  subtest active => sub {
    my $website = Kalaclista::Data::WebSite->new(
      title => 'これはテストです',
      href  => URI::Fast->new('https://example.com/active'),
      gone  => !!0,
    );

    my $html = cardify $website;
    my $dom  = dom $html->to_string;

    is $dom->at('a')->getAttribute('href'),         'https://example.com/active';
    is $dom->at('a > h2')->textContent,             'これはテストです';
    is $dom->at('a > p > cite')->textContent,       'https://example.com/active';
    is $dom->at('a > blockquote > p')->textContent, 'これはテストです';
  };

  subtest gone => sub {
    my $website = Kalaclista::Data::WebSite->new(
      title => 'これはテストです',
      link  => URI::Fast->new('https://example.com/old'),
      href  => URI::Fast->new('https://example.com/gone'),
      gone  => !!1,
    );

    my $html = cardify $website;
    my $dom  = dom $html->to_string;

    is $dom->at('div > h2')->textContent,             'これはテストです';
    is $dom->at('div > p > cite')->textContent,       'https://example.com/gone';
    is $dom->at('div > p > small')->textContent,      '無効なリンクです';
    is $dom->at('div > blockquote > p')->textContent, 'これはテストです';
  };
};

subtest apply => sub {
  my $html = <<'...';
<ul>
  <li><a href="https://example.com/website">これはリンクです</a></li>
</ul>

<ul>
  <li><a href="https://example.com/gone">これはリンクです</a></li>
</ul>
...

  my $dom = dom $html;

  apply $dom;

  is $dom->at('.content__card--website a > h2')->textContent,       'これはテストです';
  is $dom->at('.content__card--website a > p > cite')->textContent, 'https://example.com/website';

  is $dom->at('.content__card--website.gone div > h2')->textContent,       'これはテストです';
  is $dom->at('.content__card--website.gone div > p > cite')->textContent, 'https://example.com/foo/bar';
};

subtest transform => sub { ok(1) };

done_testing;
