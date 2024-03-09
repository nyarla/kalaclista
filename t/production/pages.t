#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;
use HTML5::DOM;
use YAML::XS qw(Load);

use Kalaclista::Loader::Files qw(files);
use Kalaclista::Path;

use WebSite::Context;
use WebSite::Context::URI  qw(href);
use WebSite::Context::Path qw(distdir);

use HTML5::DOM;

my sub dom : prototype($) { state $p ||= HTML5::DOM->new;                 $p->parse(shift) }
my sub c                  { state $c ||= WebSite::Context->init(qr{^t$}); $c }

subtest pages => sub {
  for my $section (qw|posts echos notes pages|) {
    my @files;
    if ( $section eq q|posts| || $section eq q|echos| ) {
      @files = grep { m|${section}/\d{4}/\d{2}/\d{2}/\d{6}/index.html| } files distdir->child($section)->path;
    }
    elsif ( $section eq q|notes| ) {
      @files = grep { m|${section}/[^/]+/index\.html| } files distdir->child($section)->path;
    }
    else {
      @files = grep { m<(?:nyarla|licenses|policies)/index\.html> } files distdir->path;
    }

    subtest $section => sub {
      for my $file (@files) {
        next if !defined $file;
        utf8::decode($file);

        my $html = Kalaclista::Path->new( path => $file )->load;
        utf8::decode($html);

        my $dom     = dom $html;
        my $website = $section ne q|pages| ? c->sections->{$section} : c->website;
        my $head    = $dom->at('head');
        my $article = $dom->body->at('.entry__permalink');
        my $href    = $website->href->to_string;

        my $title  = $article->at('header > h1 > a')->text;
        my $header = $article->at('header > p:nth-child(2)');

        like $header->at('time')->attr('datetime'), qr|^\d{4}-\d{2}-\d{2}$|;
        like $header->at('time')->text,             qr|^更新：\d{4}-\d{2}-\d{2}$|;
        like $header->at('span')->text,             qr|^読了まで：約\d+分$|;

        is $head->at('title')->text, join( q{ - }, $title, $website->title );

        my $summary = $head->at('meta[name="description"]')->attr('content');
        ok $summary ne q{};

        is $head->at('meta[property="og:description"]')->attr('content'),  $summary;
        is $head->at('meta[name="twitter:description"]')->attr('content'), $summary;

        is $head->at('meta[property="og:site_name"]')->attr('content'), $website->title;
        is $head->at('meta[property="og:image"]')->attr('content'),     href("/assets/avatar.png")->to_string;
        is $head->at('meta[property="og:locale"]')->attr('content'),    'ja_JP';

        is $head->at('meta[name="twitter:card"]')->attr('content'),  'summary';
        is $head->at('meta[name="twitter:site"]')->attr('content'),  '@kalaclista';
        is $head->at('meta[name="twitter:title"]')->attr('content'), join( q{ - }, $title, $website->title );
        is $head->at('meta[name="twitter:image"]')->attr('content'), href("/assets/avatar.png")->to_string;

        my $prefix = $section ne q{pages} ? "/${section}" : "";

        is $head->at('link[rel="alternate"][type="application/rss+xml"]')->attr('href'),    href("${prefix}/index.xml")->to_string;
        is $head->at('link[rel="alternate"][type="application/rss+xml"]')->attr('title'),   "@{[ $website->title ]}の RSS フィード";
        is $head->at('link[rel="alternate"][type="application/atom+xml"]')->attr('href'),   href("${prefix}/atom.xml")->to_string;
        is $head->at('link[rel="alternate"][type="application/atom+xml"]')->attr('title'),  "@{[ $website->title ]}の Atom フィード";
        is $head->at('link[rel="alternate"][type="application/feed+json"]')->attr('href'),  href("${prefix}/jsonfeed.json")->to_string;
        is $head->at('link[rel="alternate"][type="application/feed+json"]')->attr('title'), "@{[ $website->title ]}の JSON フィード";

        my $jsonld = $head->at('script[type="application/ld+json"]')->innerHTML;
        utf8::encode($jsonld);

        my $json       = Load($jsonld);
        my $self       = $json->[0];
        my $breadcrumb = $json->[1];

        if ( $section ne q{pages} ) {
          my $pathname = ( $file =~ m</$section/(.+)/index\.html> )[0];
          is $self, +{
            '@context' => 'https://schema.org',
            '@id'      => href("/${section}/${pathname}/")->to_string,
            '@type'    => ( $section eq q{notes} ? 'Article' : 'BlogPosting' ),
            author     => {
              '@type' => 'Person',
              name    => 'OKAMURA Naoki aka nyarla',
              email   => 'nyarla@kalaclista.com',
              url     => 'https://the.kalaclista.com/nyarla/',
            },
            publisher => {
              '@type' => 'Organization',
              logo    => {
                '@type'    => 'ImageObject',
                contentUrl => 'https://the.kalaclista.com/assets/avatar.png',
              },
            },

            headline         => $title,
            image            => href("/assets/avatar.png")->to_string,
            mainEntityOfPage => href("/${section}/")->to_string,
          };

          is $breadcrumb, +{
            '@context'      => 'https://schema.org',
            '@type'         => 'BreadcrumbList',
            itemListElement => [
              {
                '@type'  => 'ListItem',
                name     => c->website->title,
                item     => c->website->href->to_string,
                position => 1,
              },
              {
                '@type'  => 'ListItem',
                name     => $website->title,
                item     => $website->href->to_string,
                position => 2,
              },
              {
                '@type'  => 'ListItem',
                name     => $title,
                item     => $article->at('header > h1 > a')->attr('href'),
                position => 3,
              }
            ],
          };
        }
        else {
          my $pathname = ( $file =~ m</([^/]+)/index\.html> )[0];
          is $self, +{
            '@context' => 'https://schema.org',
            '@id'      => href("/${pathname}/")->to_string,
            '@type'    => 'WebPage',
            author     => {
              '@type' => 'Person',
              name    => 'OKAMURA Naoki aka nyarla',
              email   => 'nyarla@kalaclista.com',
              url     => 'https://the.kalaclista.com/nyarla/',
            },
            publisher => {
              '@type' => 'Organization',
              logo    => {
                '@type'    => 'ImageObject',
                contentUrl => 'https://the.kalaclista.com/assets/avatar.png',
              },
            },

            headline         => $title,
            image            => href("/assets/avatar.png")->to_string,
            mainEntityOfPage => href('')->to_string,
          };

          is $breadcrumb, +{
            '@context'      => 'https://schema.org',
            '@type'         => 'BreadcrumbList',
            itemListElement => [
              {
                '@type'  => 'ListItem',
                name     => c->website->title,
                item     => c->website->href->to_string,
                position => 1,
              },
              {
                '@type'  => 'ListItem',
                name     => $title,
                item     => $article->at('header > h1 > a')->attr('href'),
                position => 2,
              }
            ],
          };
        }
      }
    };
  }
};

done_testing;
