#!/usr/bin/env perl

use v5.38;
use utf8;

use feature qw(state);

BEGIN {
  $ENV{'KALACLISTA_ENV'} = 'test';
}

use Test2::V0;
use HTML5::DOM;

use WebSite::Context::Path;
use WebSite::Context::URI;
use WebSite::Loader::Entry qw(prop entry entries fixup);

my sub dom { state $p ||= HTML5::DOM->new; $p->parse(shift)->body }

subtest fixup => sub {
  my $tests = [
    {
      label   => 'posts',
      section => 'posts',
      path    => 'posts/2023/01/01/000000.md',
      href    => href('/posts/2023/01/01/000000/'),
      header  => {
        title => 'hello, 世界',
        draft => !!1,
        date  => '2023-01-01T00:00:00Z',
        css   => 'font-weight: bold',
        path  => 'posts/2023/01/01/000000.md',
      },
      expect => {
        title   => 'hello, 世界',
        summary => q{},
        section => 'posts',
        draft   => !!1,
        date    => '2023-01-01T00:00:00Z',
        lastmod => '2023-01-01T00:00:00Z',
        src     => q{},
        dom     => undef,
        meta    => {
          path => 'posts/2023/01/01/000000.md',
          css  => 'font-weight: bold',
        },
      },
    },
    {
      label   => 'echos',
      section => 'echos',
      path    => 'echos/2023/01/01/000000.md',
      href    => href('/echos/2023/01/01/000000/'),
      header  => {
        title => 'hello, 世界',
        draft => !!1,
        date  => '2023-01-01T00:00:00Z',
        css   => 'font-weight: bold',
        path  => 'echos/2023/01/01/000000.md',
      },
      expect => {
        title   => 'hello, 世界',
        summary => q{},
        section => 'echos',
        draft   => !!1,
        date    => '2023-01-01T00:00:00Z',
        lastmod => '2023-01-01T00:00:00Z',
        src     => q{},
        dom     => undef,
        meta    => {
          path => 'echos/2023/01/01/000000.md',
          css  => 'font-weight: bold',
        },
      },
    },
    {
      label   => 'notes',
      section => 'notes',
      path    => 'notes/テスト.md',
      href    => href('/notes/テスト/'),
      header  => {
        title => 'hello, 世界',
        draft => !!1,
        date  => '2023-01-01T00:00:00Z',
        css   => 'font-weight: bold',
        path  => 'notes/テスト.md',
      },
      expect => {
        title   => 'hello, 世界',
        summary => q{},
        section => 'notes',
        draft   => !!1,
        date    => '2023-01-01T00:00:00Z',
        lastmod => '2023-01-01T00:00:00Z',
        src     => q{},
        dom     => undef,
        meta    => {
          path => 'notes/テスト.md',
          css  => 'font-weight: bold',
        },
      },
    },
    {
      label   => 'notes-with-slug',
      section => 'notes',
      path    => 'notes/テスト.md',
      href    => href('notes/this-is-a-test/'),
      header  => {
        title => 'hello, 世界',
        draft => !!1,
        date  => '2023-01-01T00:00:00Z',
        css   => 'font-weight: bold',
        slug  => 'this is a test',
        path  => 'notes/テスト.md',
      },
      expect => {
        title   => 'hello, 世界',
        summary => q{},
        section => 'notes',
        draft   => !!1,
        date    => '2023-01-01T00:00:00Z',
        lastmod => '2023-01-01T00:00:00Z',
        src     => q{},
        dom     => undef,
        meta    => {
          path => 'notes/テスト.md',
          slug => 'this is a test',
          css  => 'font-weight: bold',
        },
      },
    }
  ];

  for my $test ( $tests->@* ) {
    subtest $test->{'label'} => sub {
      my $src    = srcdir->child( $test->{'path'} );
      my $header = $test->{'header'};

      my $entry = fixup $src => $header;
      for my $prop ( sort keys $test->{'expect'}->%* ) {
        is $entry->$prop(), $test->{'expect'}->{$prop};
      }
      is $entry->href->to_string, $test->{'href'}->to_string;
    };
  }
};

subtest prop => sub {
  my $entry = prop 'posts/2023/01/01/000000.md';

  is $entry->title,   'こんにちは！';
  is $entry->summary, 'これは一番最初の記事です';
  is $entry->section, 'posts';
  is $entry->date,    '2023-01-01T00:00:00+09:00';
  is $entry->lastmod, '2024-01-01T00:00:00+09:00';
  is $entry->draft,   !!0;
  is $entry->src,     q{};
  is $entry->dom,     undef;
};

subtest entry => sub {
  my $entry = entry 'posts/2023/01/01/000000.md';

  is $entry->title,   'こんにちは！';
  is $entry->summary, 'これは一番最初の記事です';
  is $entry->section, 'posts';
  is $entry->date,    '2023-01-01T00:00:00+09:00';
  is $entry->lastmod, '2024-01-01T00:00:00+09:00';
  is $entry->draft,   !!0;

  my $content = srcdir->child('entries/precompiled/posts/2023/01/01/000000.md')->load;
  utf8::decode($content);

  is $entry->src, $content;

  isa_ok $entry->dom, 'HTML5::DOM::Element';

  my $prop = prop 'posts/2023/01/01/000000.md';
  is $prop->dom, undef;
  is $prop->src, q{};

  my $entry2 = entry $prop;
  isa_ok $entry2->dom, 'HTML5::DOM::Element';
  isnt $entry2->src, q{};
};

subtest entries => sub {
  entries {
    like $_, qr{^(?:(?:posts|echos)/\d{4}/\d{2}/\d{2}/\d{6}|(?:notes/(?:[^/]+))|(?:[^/]+))\.md$} for @_
  };
};

done_testing;
