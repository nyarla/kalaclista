#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;
use HTML5::DOM;
use YAML::XS qw(Load);

use Kalaclista::Loader::Files qw(files);

use WebSite::Context;
use WebSite::Context::Path qw(distdir);
use WebSite::Context::URI  qw(href);

my sub dom : prototype($) { state $p ||= HTML5::DOM->new;                 $p->parse(shift) }
my sub c                  { state $c ||= WebSite::Context->init(qr{^t$}); $c }

subtest indexes => sub {
  for my $section (qw|posts echos notes|) {
    my @files;
    if ( $section eq q|posts| ) {
      @files = map { "posts/${_}/index.html" } ( 2006 .. ( (localtime)[5] + 1900 - 1 ) );
      push @files, "posts/index.html";
    }
    elsif ( $section eq q|echos| ) {
      @files = map { "echos/${_}/index.html" } ( 2018 .. ( (localtime)[5] - 1 ) );
      push @files, "echos/index.html";
    }
    else {
      push @files, "notes/index.html";
    }

    subtest $section => sub {
      for my $file (@files) {
        my $html = distdir->child($file)->load;
        utf8::decode($html);

        my $dom     = dom $html;
        my $website = c->sections->{$section};
        my $head    = $dom->at('head');
        my $article = $dom->body->at('article.entry__archives');
        my $href    = $website->href->to_string;

        is $head->at('title')->text,                                      $website->title;
        is $head->at('meta[name="description"]')->attr('content'),        $website->summary;
        is $head->at('meta[property="og:site_name"]')->attr('content'),   $website->title;
        is $head->at('meta[property="og:image"]')->attr('content'),       href("/assets/avatar.png")->to_string;
        is $head->at('meta[property="og:description"]')->attr('content'), $website->summary;
        is $head->at('meta[property="og:locale"]')->attr('content'),      'ja_JP';

        is $head->at('meta[name="twitter:card"]')->attr('content'),        'summary';
        is $head->at('meta[name="twitter:site"]')->attr('content'),        '@kalaclista';
        is $head->at('meta[name="twitter:title"]')->attr('content'),       $website->title;
        is $head->at('meta[name="twitter:description"]')->attr('content'), $website->summary;
        is $head->at('meta[name="twitter:image"]')->attr('content'),       href('/assets/avatar.png')->to_string;

        is $head->at('link[rel="alternate"][type="application/rss+xml"]')->attr('href'),  href("/${section}/index.xml")->to_string;
        is $head->at('link[rel="alternate"][type="application/rss+xml"]')->attr('title'), "@{[ $website->title ]}の RSS フィード";

        is $head->at('link[rel="alternate"][type="application/atom+xml"]')->attr('href'),  href("/${section}/atom.xml")->to_string;
        is $head->at('link[rel="alternate"][type="application/atom+xml"]')->attr('title'), "@{[ $website->title ]}の Atom フィード";

        is $head->at('link[rel="alternate"][type="application/feed+json"]')->attr('href'),  href("/${section}/jsonfeed.json")->to_string;
        is $head->at('link[rel="alternate"][type="application/feed+json"]')->attr('title'), "@{[ $website->title ]}の JSON フィード";

        is $article->at('header > h1 > a')->attr('href'),         $website->href->to_string;
        is $article->at('header > h1 > a')->text,                 $website->title;
        is $article->at('.entry__content > p:first-child')->text, $website->summary;

        if ( $section ne q|notes| ) {
          like $article->at('.entry__content > strong:nth-child(3)')->text, qr|\d{4}年：|;
        }

        for my $item ( $article->find('.archives li')->@* ) {
          like $item->at('time')->attr('datetime'), qr|^\d{4}-\d{2}-\d{2}$|;
          like $item->at('time')->text,             qr|^\d{4}-\d{2}-\d{2}：$|;
          like $item->at('a.title')->attr('href'),  qr<^${href}(?:\d{4}/\d{2}/\d{2}/\d{6}|[^/]+/)>;
        }

        my $jsonld = $head->at('script[type="application/ld+json"]')->innerHTML;
        utf8::encode($jsonld);

        my $json       = Load($jsonld);
        my $self       = $json->[0];
        my $breadcrumb = $json->[1];

        if ( $file =~ m|^$section/(\d{4})/index\.html| ) {
          my $year = $1;

          is $article->at('p.logs > strong')->text, $year;
          for my $link ( $article->find('p.logs a')->@* ) {
            like $link->attr('href'), qr|^${href}\d{4}/$|;
            like $link->text,         qr|^\d{4}$|;
            isnt $link->text, $year;
          }

          like $head->at('meta[property="og:title"]')->attr('content'), qr|${year}年の記事一覧|;
          is $head->at('meta[property="og:url"]')->attr('content'), href("/${section}/${year}/")->to_string;
          is $self, +{
            '@context' => 'https://schema.org',
            '@id'      => href("/${section}/${year}/")->to_string,
            '@type'    => 'Blog',

            headline => $website->title,
            author   => {
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
                name     => "${year}年の記事一覧",
                item     => href("/${section}/${year}/")->to_string,
                position => 3,
              },
            ],
          };
        }
        else {
          is $head->at('meta[property="og:title"]')->attr('content'), $website->title;
          is $head->at('meta[property="og:url"]')->attr('content'),   href("/${section}/")->to_string;
          is $self, +{
            '@context' => 'https://schema.org',
            '@id'      => href("/${section}/")->to_string,
            '@type'    => ( $section eq q|notes| ? q|WebSite| : q|Blog| ),
            headline   => $website->title,
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
            image => href("/assets/avatar.png")->to_string,
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
              }
            ],
          };
        }
      }
    };
  }
};

done_testing;
