#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use HTML5::DOM;

use Kalaclista::Entry;
use WebSite::Templates::Permalink;

my $parser = HTML5::DOM->new;

subtest utils => sub {
  subtest readtime => sub {
    my $text = 'x' x 1000;

    my $time = WebSite::Templates::Permalink::readtime($text);

    is $time, 2;

    $text = 'x';
    $time = WebSite::Templates::Permalink::readtime($text);

    is $time, 1;
  };

  subtest date => sub {
    my $datetime = '2024-01-01T00:00:00Z';
    my $date     = WebSite::Templates::Permalink::date($datetime);

    is $date, '2024年1月1日';
  };
};

subtest templates => sub {
  subtest header => sub {
    subtest common => sub {
      my $entry = Kalaclista::Entry->new(
        path   => '',
        href   => 'https://example.com/foo/bar/baz/',
        loaded => 1,
        meta   => {
          title => 'Hi,',
          date  => '2024-01-01T00:00:00Z',
        },
        src => 'hello, world!',
        dom => $parser->parse('<p>hello, world!</p>')->body,
      );

      my $html = WebSite::Templates::Permalink::headers($entry);
      utf8::decode($html);

      my $dom = $parser->parse($html);

      is $dom->at('header > h1 > a')->textContent,          'Hi,';
      is $dom->at('header > h1 > a')->getAttribute('href'), 'https://example.com/foo/bar/baz/';

      is $dom->at('header > div > p:first-child time')->textContent,              '2024年1月1日';
      is $dom->at('header > div > p:first-child time')->getAttribute('datetime'), '2024-01-01T00:00:00Z';
      is $dom->at('header > div > p:first-child time')->getAttribute('title'),    'この記事は2024年1月1日に公開されました';

      is $dom->at('header > div > p:nth-child(2)')->textContent, 'この記事は1分で読めそう',;
    };

    subtest updated => sub {
      my $entry = Kalaclista::Entry->new(
        path   => '',
        href   => 'https://example.com/foo/bar/baz/',
        loaded => 1,
        meta   => {
          title   => 'Hi,',
          date    => '2024-01-01T00:00:00Z',
          lastmod => '2024-01-02T00:00:00Z',
        },
        src => 'hello, world!',
        dom => $parser->parse('<p>hello, world!</p>')->body,
      );

      my $html = WebSite::Templates::Permalink::headers($entry);
      utf8::decode($html);
      my $dom = $parser->parse($html);

      is $dom->at('header > div > p:first-child')->textContent,                                         '2024年1月1日→2024年1月2日';
      is $dom->at('header > div > p:first-child > span:nth-child(4) > time')->getAttribute('datetime'), '2024-01-02T00:00:00Z';
      is $dom->at('header > div > p:first-child > span:nth-child(4) > time')->getAttribute('title'),    'また2024年1月2日に更新されています';
    };

    subtest affiliate => sub {
      my $entry = Kalaclista::Entry->new(
        path   => '',
        href   => 'https://example.com/foo/bar/baz/',
        loaded => 1,
        meta   => {
          title   => 'Hi,',
          date    => '2024-01-01T00:00:00Z',
          lastmod => '2024-01-02T00:00:00Z',
        },
        src => 'hello, world!',
        dom => $parser->parse('<div class="is-affiliate">hello, world!</div>')->body,
      );

      my $html = WebSite::Templates::Permalink::headers($entry);
      utf8::decode($html);

      my $dom = $parser->parse($html);

      is $dom->at('header > p')->textContent, 'この記事はアフィリエイト広告を含んでいます。';
    };
  };
};

done_testing;
