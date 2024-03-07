#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;
use HTML5::DOM;
use URI::Fast;

BEGIN {
  $ENV{'KALACLISTA_ENV'} = 'test';
}

use Kalaclista::Data::Entry;

use WebSite::Context::URI        qw(baseURI);
use WebSite::Context::Path       qw(srcdir);
use WebSite::Extensions::Picture qw( file src mkGif mkWebP apply );

my sub dom { state $p ||= HTML5::DOM->new; $p->parse(shift)->body }
my sub entry {
  state $entry ||= Kalaclista::Data::Entry->new(
    title   => '',
    summary => '',
    section => '',
    date    => '',
    lastmod => '',
    href    => URI::Fast->new('https://example.com/foo/bar/'),
    meta    => {
      path => 'foo/bar.md',
    },
  );

  return $entry;
}

subtest file => sub {
  my $path = file 'foo/bar.md', 1;
  is $path, 'foo/bar/1.yaml';
};

subtest src => sub {
  my $href = baseURI->clone;
  $href->path("/foo/bar/");

  my $gif = src $href, 1, '1x', 'gif';
  is $gif->to_string, 'https://example.com/images/foo/bar/1_1x.gif';

  my $webp = src $href, 2, '2x', 'webp';
  is $webp->to_string, 'https://example.com/images/foo/bar/2_2x.webp';
};

subtest mkGif => sub {
  my $href = baseURI->clone;
  $href->path("/foo/bar/");

  my $img = mkGif 'Test', $href, 1, { width => 256, height => 256 };
  my $dom = dom( $img->to_string )->at('img');

  is $dom->attr('src'),    'https://example.com/images/foo/bar/1_1x.gif';
  is $dom->attr('alt'),    'Test';
  is $dom->attr('title'),  'Test';
  is $dom->attr('width'),  '256';
  is $dom->attr('height'), '256';
};

subtest mkWebP => sub {
  my $href = baseURI->clone;
  $href->path("/foo/bar/");

  my $img = mkWebP 'Test', $href, 1, {
    '1x' => { width => 256, height => 256 },
    '2x' => { width => 512, height => 512 },
  };

  my $dom = dom( $img->to_string )->at('img');

  is $dom->attr('alt'),   'Test';
  is $dom->attr('title'), 'Test';

  is $dom->attr('src'),    'https://example.com/images/foo/bar/1_1x.webp';
  is $dom->attr('width'),  '256';
  is $dom->attr('height'), '256';

  is $dom->attr('srcset'), join(
    q{, }, (
      "https://example.com/images/foo/bar/1_1x.webp 1x",
      "https://example.com/images/foo/bar/1_2x.webp 2x",
    )
  );

  is $dom->attr('sizes'), join(
    q{, }, (
      "(max-width: 256px) 256px",
      "(max-width: 512px) 512px"
    )
  );
};

subtest apply => sub {
  my $path = 'foo/bar.md';
  my $href = baseURI->clone;
  $href->path('/foo/bar/');

  my $html = <<'...';
<p><img src="1" alt="hello, world"/></p>
<p><img src="2" alt="こんにちは" /></p>
...

  my $dom = dom $html;
  apply $path, $href, $dom;

  my $img1 = $dom->at('p:nth-child(1) a.content__card--thumbnail');
  is $img1->attr('href'), 'https://example.com/images/foo/bar/1_1x.webp';

  is $img1->at('img')->attr('alt'), 'hello, world';
  is $img1->at('img')->attr('alt'), $img1->at('img')->attr('alt');
  is $img1->at('img')->attr('src'), 'https://example.com/images/foo/bar/1_1x.webp';

  my $img2 = $dom->at('p:nth-child(2) a.content__card--thumbnail');
  is $img2->attr('href'), 'https://example.com/images/foo/bar/2_1x.gif';

  is $img2->at('img')->attr('alt'), 'こんにちは';
  is $img2->at('img')->attr('alt'), $img2->at('img')->attr('alt');
  is $img2->at('img')->attr('src'), 'https://example.com/images/foo/bar/2_1x.gif';
};

subtest transform => sub {
  my $entry  = entry;
  my $expect = WebSite::Extensions::Picture->transform($entry);

  is $entry, $expect;

  my $html = <<'...';
<p><img src="1" alt="hello, world"/></p>
<p><img src="2" alt="こんにちは" /></p>
...

  my $dom = dom $html;

  $entry = $entry->clone( dom => $dom );
  $entry = WebSite::Extensions::Picture->transform($entry);

  isnt $entry, $expect;

  is $entry->dom->at('p:nth-child(1) .content__card--thumbnail img')->attr('alt'), 'hello, world';
  is $entry->dom->at('p:nth-child(2) .content__card--thumbnail img')->attr('alt'), 'こんにちは';
};

done_testing;
