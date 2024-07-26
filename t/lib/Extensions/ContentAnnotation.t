#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;

use HTML5::DOM;
use URI::Fast;
use Markdown::Perl;

use Kalaclista::Data::Entry;

use WebSite::Extensions::ContentAnnotation qw(annotate);

my sub md : prototype($) {
  state $md = Markdown::Perl->new(
    mode                   => 'github',
    use_extended_autolinks => !!0,
  );

  return $md->convert(shift);
}

my sub dom : prototype($) { state $p ||= HTML5::DOM->new; $p->parse(shift)->body }
my sub entry {
  state $entry ||= Kalaclista::Data::Entry->new(
    title   => '',
    summary => '',
    section => '',
    date    => '',
    lastmod => '',
    href    => URI::Fast->new('https://example.com/test'),
    meta    => {
      path => 'posts/2023/01/01/000000.md',
    }
  );

  return $entry;
}

subtest apply => sub {
  my $markdown = <<'...';
> [!NOTE]
> これは*補足事項*です
>
> **段落A**
>
> *段落B*
...

  my $html = md $markdown;
  my $dom  = dom $html;
  annotate $dom;

  my $section = $dom->at('.annotated.note')->innerHTML;
  is $section, '<p>これは<em>補足事項</em>です</p><p><strong>段落A</strong></p><p><em>段落B</em></p>';
};

subtest transform => sub {
  my $entry  = entry;
  my $expect = WebSite::Extensions::ContentAnnotation->transform($entry);

  is $entry, $expect;

  my $markdown = <<'...';
> [!NOTE] 
> hello, world!
...

  $entry = $entry->clone( dom => dom( md($markdown) ) );
  $entry = WebSite::Extensions::ContentAnnotation->transform($entry);

  isnt $entry, $expect;

  is $entry->dom->at('.annotated.note')->textContent, 'hello, world!';
};

done_testing;
