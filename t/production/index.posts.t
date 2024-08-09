#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0 qw(!prop);

use HTML5::DOM;
use YAML::XS qw(Load);

use Kalaclista::Loader::Files qw(files);

use WebSite::Context::WebSite qw(section website);
use WebSite::Context::Path    qw(srcdir distdir);
use WebSite::Context::URI     qw(href);
use WebSite::Loader::Entry    qw(prop);

my sub dom : prototype($) { state $p ||= HTML5::DOM->new; $p->parse(shift) }

my ($section) = __FILE__ =~ m{([^.]+)\.t$};

( $section eq 'posts' || $section eq 'echos' ) && subtest $section => sub {
  my $srcdir   = srcdir->child('entries/src')->path;
  my @articles = sort { $b->date cmp $a->date }
      map { s<${srcdir}/><>; prop $_ }
      grep { m</${section}/> } files $srcdir;

  my ($start)  = $articles[-1]->date =~ m<^(\d{4})>;
  my ($latest) = $articles[1]->date  =~ m<^(\d{4})>;

  for my $year ( $start .. $latest ) {
    my $fn   = $year == $latest ? "${section}/index.html" : "${section}/${year}/index.html";
    my $path = distdir->child($fn);

    my $html = $path->load;
    utf8::decode($html);

    my $dom     = dom $html;
    my $head    = $dom->at('head');
    my $body    = $dom->at('body');
    my $website = section $section;

    subtest "${year} (${fn})" => sub {
      subtest head => sub {
        subtest meta => sub {
          is $dom->at('html')->attr('lang'),                         'ja',              'The page lang is `ja`';
          is $head->at('title')->text,                               $website->title,   'The page title is the website title';
          is $head->at('meta[name="description"]')->attr('content'), $website->summary, 'The page description is the website summary';
        };

        subtest ogp => sub {
          is $head->at('meta[property="og:site_name"]')->attr('content'), $website->title,
              'The ogp site_name is the  website title';

          is $head->at('meta[property="og:image"]')->attr('content'), href('/assets/avatar.png')->to_string,
              'The ogp image is the URI of avatar icon';

          is $head->at('meta[property="og:description"]')->attr('content'), $website->summary,
              'The ogp description is the website summary';

          is $head->at('meta[property="og:locale"]')->attr('content'), 'ja_JP', 'The ogp locale is `ja_JP`';
        };

        subtest feeds => sub {
          my $title = $website->title;

          is $head->at('link[rel="alternate"][type="application/rss+xml"]')->attr('href'),
              href("/${section}/index.xml")->to_string,
              "The RSS feed URI point to ${section}/index.xml";

          is $head->at('link[rel="alternate"][type="application/rss+xml"]')->attr('title'),
              "${title}の RSS フィード",
              'The RSS feed title has right value';

          is $head->at('link[rel="alternate"][type="application/atom+xml"]')->attr('href'),
              href("/${section}/atom.xml")->to_string,
              "The Atom feed URI point to ${section}/atom.xml";

          is $head->at('link[rel="alternate"][type="application/atom+xml"]')->attr('title'),
              "${title}の Atom フィード",
              'The Atom feed title has right value';

          is $head->at('link[rel="alternate"][type="application/feed+json"]')->attr('href'),
              href("/${section}/jsonfeed.json")->to_string,
              "The JSON feed URI point to ${section}/jsonfeed.json";

          is $head->at('link[rel="alternate"][type="application/feed+json"]')->attr('title'),
              "${title}の JSON フィード",
              'The JSON feed title has right value';
        };

        subtest jsonld => sub {
          my $jsonld = $head->at('script[type="application/ld+json"]')->innerHTML;
          utf8::encode($jsonld);

          my $json = Load($jsonld);
          my ( $self, $breadcrumb ) = $json->@*;

          is $self, +{
            '@context' => 'https://schema.org',
            '@id'      => href( $year != $latest ? "/${section}/${year}/" : "/${section}/" )->to_string,
            '@type'    => 'Blog',

            headline => $website->title,
            author   => {
              '@type' => 'Person',
              name    => 'OKAMURA Naoki aka nyarla',
              email   => 'nyarla@kalaclista.com',
              url     => 'https://the.kalaclista.com/nyarla/'
            },
            publisher => {
              '@type' => 'Organization',
              logo    => {
                '@type'    => 'ImageObject',
                contentUrl => 'https://the.kalaclista.com/assets/avatar.png',
              },
            },
            image => href('/assets/avatar.png')->to_string,

            ( ( $year != $latest ) ? ( mainEntityOfPage => href("/${section}/")->to_string ) : () )
              },
              "The JSON-LD data is valid";

          is $breadcrumb, +{
            '@context'      => 'https://schema.org',
            '@type'         => 'BreadcrumbList',
            itemListElement => [
              {
                '@type'  => 'ListItem',
                name     => website->title,
                item     => website->href->to_string,
                position => 1,
              },
              {
                '@type'  => 'ListItem',
                name     => $website->title,
                item     => $website->href->to_string,
                position => 2,
              },

              (
                ( $year != $latest )
                ? (
                  {
                    '@type'  => 'ListItem',
                    name     => "${year}年の記事一覧",
                    item     => href("/${section}/${year}/")->to_string,
                    position => 3,
                  }
                    )
                : ()
              )
            ],
              },
              'The JSON-LD breadcrumb data is valid';
        };
      };

      subtest body => sub {
        subtest header => sub {
          is $body->at('h1 .p-name')->textContent,
              $website->title,
              'The title has right value';

          is $body->at('.entry__content .p-summary')->textContent,
              $website->summary,
              'The summary has right value';
        };

        subtest label => sub {
          is $body->at('.entry__content .p-summary + hr + strong')->textContent,
              "${year}年：",
              'The label of years has right value';
        };

        subtest list => sub {
          my @entries = sort { $b->date cmp $a->date } grep { $_->date =~ m<^${year}> } @articles;
          my $list    = $body->at('.entry__content .archives');

          is scalar(@entries), scalar( $list->find('.h-entry')->@* ), 'The archive links has right number of content';
          for ( my $idx = 0 ; $idx < @entries ; $idx++ ) {
            my $article = $entries[$idx];
            my $path    = $article->href->path;
            my $el      = $list->at(".h-entry:nth-child(@{[ $idx+1 ]})");

            subtest $path => sub {
              ok $el, "A link of article is exists";

              my ($date) = split qr<T>, $article->date;
              is $el->at('.dt-published')->attr('datetime'), $date, "A published date is article date";
              is $el->at('.dt-published')->textContent,      $date, "A label of date is article date";

              is $el->at('.u-url')->attr('href'), $article->href->to_string, 'The href is point to entry permalink';
              is $el->at('.p-name')->textContent, $article->title,           'The link title is article title';
            };
          }
        };

        subtest years => sub {
          my $years = $body->at('.entry__content .logs');
          is $years->textContent,
              "過去ログ：" . join( q{/}, sort { $b <=> $a } ( $start .. $latest ) ),
              'The links of archive pages has right content';
          for my $yr ( $start .. $latest ) {
            if ( $yr == $year ) {
              is $years->at('strong')->textContent, $year, "The element of current year is `strong` (${yr})";
            }
            else {
              is $years->at("a[href\$='/${yr}/']")->attr('href'),
                  href("${section}/${yr}/")->to_string,
                  "A link of archive has right label (${yr})";

              is $years->at("a[href\$='/${yr}/']")->textContent, $yr, "A link of archive has right label (${yr})";
            }
          }
        };
      };
    };
  }
};

( $section eq 'notes' ) && subtest $section => sub {
  my $srcdir   = srcdir->child('entries/src')->path;
  my @articles = sort { $b->updated cmp $a->updated }
      map { s<${srcdir}/><>; prop $_ }
      grep { m</${section}/> } files $srcdir;

  my $html = distdir->child("${section}/index.html")->load;
  utf8::decode($html);

  my $dom     = dom $html;
  my $head    = $dom->at('head');
  my $body    = $dom->at('body');
  my $website = section $section;

  subtest head => sub {
    subtest meta => sub {
      is $dom->at('html')->attr('lang'), 'ja', "The page lang is `ja`";

      is $head->at('title')->textContent,
          $website->title,
          'The page title is website title';

      is $head->at('meta[name="description"]')->attr('content'),
          $website->summary,
          'The page summary is website summary';

      subtest ogp => sub {
        is $head->at('meta[property="og:site_name"]')->attr('content'),
            $website->title,
            'The OGP site_name is website title';

        is $head->at('meta[property="og:image"]')->attr('content'),
            href('/assets/avatar.png')->to_string,
            'The OGP image is the avatar url';

        is $head->at('meta[property="og:description"]')->attr('content'),
            $website->summary,
            'The OGP description is the website summary';

        is $head->at('meta[property="og:locale"]')->attr('content'),
            'ja_JP',
            'The OGP locale is `ja_JP`';
      };

      subtest feeds => sub {
        my $title = $website->title;

        is $head->at('link[rel="alternate"][type="application/rss+xml"]')->attr('href'),
            href("/${section}/index.xml")->to_string,
            "The RSS feed URI point to ${section}/index.xml";

        is $head->at('link[rel="alternate"][type="application/rss+xml"]')->attr('title'),
            "${title}の RSS フィード",
            'The RSS feed title has right value';

        is $head->at('link[rel="alternate"][type="application/atom+xml"]')->attr('href'),
            href("/${section}/atom.xml")->to_string,
            "The Atom feed URI point to ${section}/atom.xml";

        is $head->at('link[rel="alternate"][type="application/atom+xml"]')->attr('title'),
            "${title}の Atom フィード",
            'The Atom feed title has right value';

        is $head->at('link[rel="alternate"][type="application/feed+json"]')->attr('href'),
            href("/${section}/jsonfeed.json")->to_string,
            "The JSON feed URI point to ${section}/jsonfeed.json";

        is $head->at('link[rel="alternate"][type="application/feed+json"]')->attr('title'),
            "${title}の JSON フィード",
            'The JSON feed title has right value';
      };

      subtest jsonld => sub {
        my $jsonld = $head->at('script[type="application/ld+json"]')->innerHTML;
        utf8::encode($jsonld);

        my $json = Load($jsonld);
        my ( $self, $breadcrumb ) = $json->@*;

        is $self, +{
          '@context' => 'https://schema.org',
          '@id'      => href("/${section}/")->to_string,
          '@type'    => 'WebSite',

          headline => $website->title,
          author   => {
            '@type' => 'Person',
            name    => 'OKAMURA Naoki aka nyarla',
            email   => 'nyarla@kalaclista.com',
            url     => 'https://the.kalaclista.com/nyarla/'
          },
          publisher => {
            '@type' => 'Organization',
            logo    => {
              '@type'    => 'ImageObject',
              contentUrl => 'https://the.kalaclista.com/assets/avatar.png',
            },
          },
          image => href('/assets/avatar.png')->to_string,

            },
            'The JSON-LD data is valid';

        is $breadcrumb, +{
          '@context'      => 'https://schema.org',
          '@type'         => 'BreadcrumbList',
          itemListElement => [
            {
              '@type'  => 'ListItem',
              name     => website->title,
              item     => website->href->to_string,
              position => 1,
            },
            {
              '@type'  => 'ListItem',
              name     => $website->title,
              item     => $website->href->to_string,
              position => 2,
            },
          ],
            },
            'The JSON-LD breadcrumb is valid';
      };
    };
  };

  subtest body => sub {
    subtest header => sub {
      is $body->at('h1 .p-name')->textContent,
          $website->title,
          'The title has right value';

      is $body->at('.entry__content .p-summary')->textContent,
          $website->summary,
          'The summary has right value';
    };

    subtest list => sub {
      my $list = $body->at('.entry__content .archives');

      is scalar(@articles),
          scalar( $list->find('.h-entry')->@* ),
          'The archive links has right number of content';

      for ( my $idx = 0 ; $idx < @articles ; $idx++ ) {
        my $article = $articles[$idx];
        my $path    = $article->href->path;
        my $el      = $list->at(".h-entry:nth-child(@{[ $idx+1 ]})");

        subtest $path => sub {
          ok $el, "A link of article is exists";

          my ($date) = split qr<T>, $article->date;
          is $el->at('.dt-published')->attr('datetime'), $date, "A published date is article date";
          is $el->at('.dt-published')->textContent,      $date, "A label of date is article date";

          is $el->at('.u-url')->attr('href'), $article->href->to_string, 'The href is point to entry permalink';
          is $el->at('.p-name')->textContent, $article->title,           'The link title is article title';
        };
      }
    };
  };
};

done_testing;
