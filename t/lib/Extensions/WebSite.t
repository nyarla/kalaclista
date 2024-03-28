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

    ok $dom->at('a > h2 > img');
    is $dom->at('a > h2 > img')->attr('width'),  16;
    is $dom->at('a > h2 > img')->attr('height'), 16;
    is $dom->at('a > h2 > img')->attr('alt'),    '';
    like $dom->at('a > h2 > img')->attr('src'), qr|^https://www\.google\.com/s2/favicons\?domain=[^&]+&sz=32$|;

    is $dom->at('a')->getAttribute('href'),   'https://example.com/active';
    is $dom->at('a > h2')->textContent,       'これはテストです';
    is $dom->at('a > p > cite')->textContent, 'https://example.com/active';
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

    is $dom->at('div > h2')->textContent,        'これはテストです';
    is $dom->at('div > p > cite')->textContent,  'https://example.com/gone';
    is $dom->at('div > p > small')->textContent, '無効なリンクです';
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

  is $dom->at('.content__card--website.gone div > h2')->textContent,       'これはリンクです';
  is $dom->at('.content__card--website.gone div > p > cite')->textContent, 'https://example.com/gone';
};

subtest transform => sub {
  my $entry  = entry;
  my $expect = WebSite::Extensions::WebSite->transform($entry);

  is $entry, $expect;

  $entry = $entry->clone( dom => dom(<<'...') );
<ul>
  <li><a href="https://example.com">これはテストです</a></li>
</ul>
...
  $entry = WebSite::Extensions::WebSite->transform($entry);

  isnt $entry, $expect;

  is $entry->dom->at('.content__card--website a > h2')->textContent, 'これはテストです';
  is $entry->dom->at('.content__card--website a')->attr('href'),     'https://example.com';

};

done_testing;
