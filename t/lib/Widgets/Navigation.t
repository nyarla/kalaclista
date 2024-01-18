#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;
use HTML5::DOM;
use URI::Fast;

use Kalaclista::Data::Page;
use Kalaclista::Files;

use WebSite::Context;
use WebSite::Widgets::Navigation;

my $parser = HTML5::DOM->new();
my $c      = WebSite::Context->init(qr{^t$});

sub page {
  my ( $section, $kind, $path ) = @_;

  my $href = $c->baseURI->clone;
  $href->path($path);

  my $page = Kalaclista::Data::Page->new(
    section => $section,
    kind    => $kind,
    href    => $href,
  );

  my $html = navigation($page);
  utf8::decode($html);
  my $dom = $parser->parse($html);

  return $dom;
}

sub entries {
  my $path   = shift;
  my $prefix = $c->entries->path;
  my @files  = Kalaclista::Files->find($prefix);

  $_ =~ s{^$prefix}{} for @files;
  $_ =~ s{\.md$}{/}   for @files;

  return grep { $_ =~ m{$path} } @files;
}

sub href {
  my $path = shift;
  my $href = $c->baseURI->clone;
  $href->path($path);

  return $href->to_string;
}

sub title_ok ($) {
  my $dom = shift;

  is $dom->at('nav > p:first-child > a')->getAttribute('href'), href('/');
  is $dom->at('nav > p:first-child > a')->textContent,          'カラクリスタ';
}

subtest navigation => sub {
  subtest pages => sub {
    subtest home => sub {
      subtest '/' => sub {
        my $dom = page( qw(pages home), undef );

        title_ok $dom;

        is $dom->at('nav > p:nth-child(3) > a:nth-child(1)')->textContent,          'ブログ';
        is $dom->at('nav > p:nth-child(3) > a:nth-child(1)')->getAttribute('href'), href('/posts/');

        is $dom->at('nav > p:nth-child(3) > a:nth-child(3)')->textContent,          '日記';
        is $dom->at('nav > p:nth-child(3) > a:nth-child(3)')->getAttribute('href'), href('/echos/');

        is $dom->at('nav > p:nth-child(3) > a:nth-child(5)')->textContent,          'メモ帳';
        is $dom->at('nav > p:nth-child(3) > a:nth-child(5)')->getAttribute('href'), href('/notes/');
      };
    };

    subtest permalink => sub {
      subtest '/nyarla/' => sub {
        my $dom = page(qw(pages permalink nyarla));

        title_ok $dom;

        is $dom->at('nav > p:nth-child(3) > a:first-child')->textContent,          'プロフィール';
        is $dom->at('nav > p:nth-child(3) > a:first-child')->getAttribute('href'), href('/nyarla/');
      };

      subtest '/policies/' => sub {
        my $dom = page(qw(pages permalink policies));

        title_ok $dom;

        is $dom->at('nav > p:nth-child(3) > a:first-child')->textContent,          '運営ポリシー';
        is $dom->at('nav > p:nth-child(3) > a:first-child')->getAttribute('href'), href('/policies/');
      };

      subtest '/licenses/' => sub {
        my $dom = page(qw(pages permalink licenses));

        title_ok $dom;

        is $dom->at('nav > p:nth-child(3) > a:first-child')->textContent,          'ライセンスなど';
        is $dom->at('nav > p:nth-child(3) > a:first-child')->getAttribute('href'), href('/licenses/');
      };
    };
  };

  subtest posts => sub {
    subtest index => sub {
      for my $path ( '', 2006 .. ( (localtime)[5] + 1900 ) ) {
        if ( $path ne q{} ) {
          $path .= "/";
        }

        subtest "/posts/${path}" => sub {
          my $dom = page( qw(posts index), qq(posts/${path}) );

          title_ok $dom;

          is $dom->at('nav > p:nth-child(3) > a:first-child')->textContent,          'ブログ';
          is $dom->at('nav > p:nth-child(3) > a:first-child')->getAttribute('href'), href('/posts/');
        };
      }
    };

    subtest permalink => sub {
      for my $path ( entries('/posts/') ) {
        subtest $path => sub {
          my $dom = page( qw(posts permalink), $path );

          title_ok $dom;

          is $dom->at('nav > p:nth-child(3) > a:first-child')->textContent,          'ブログ';
          is $dom->at('nav > p:nth-child(3) > a:first-child')->getAttribute('href'), href('/posts/');
        };
      }
    };
  };

  subtest echos => sub {
    subtest index => sub {
      for my $path ( '', 2018 .. ( (localtime)[5] + 1900 ) ) {
        if ( $path ne q{} ) {
          $path .= "/";
        }

        subtest "/echos/${path}" => sub {
          my $dom = page( qw(echos index), qq(echos/${path}) );

          title_ok $dom;

          is $dom->at('nav > p:nth-child(3) > a:first-child')->textContent,          '日記';
          is $dom->at('nav > p:nth-child(3) > a:first-child')->getAttribute('href'), href('/echos/');
        };
      }
    };

    subtest permalink => sub {
      for my $path ( entries('/echos/') ) {
        subtest $path => sub {
          my $dom = page( qw(echos permalink), $path );

          title_ok $dom;

          is $dom->at('nav > p:nth-child(3) > a:first-child')->textContent,          '日記';
          is $dom->at('nav > p:nth-child(3) > a:first-child')->getAttribute('href'), href('/echos/');
        };
      }
    };
  };

  subtest notes => sub {
    subtest index => sub {
      my $dom = page( qw(notes index), '' );

      title_ok $dom;

      is $dom->at('nav > p:nth-child(3) > a:first-child')->textContent,          'メモ帳';
      is $dom->at('nav > p:nth-child(3) > a:first-child')->getAttribute('href'), href('/notes/');
    };

    subtest permalink => sub {
      for my $path ( entries('/notes/') ) {
        subtest $path => sub {
          my $dom = page( qw(notes permalink), $path );

          title_ok $dom;

          is $dom->at('nav > p:nth-child(3) > a:first-child')->textContent,          'メモ帳';
          is $dom->at('nav > p:nth-child(3) > a:first-child')->getAttribute('href'), href('/notes/');
        };
      }
    };
  };
};

done_testing;
