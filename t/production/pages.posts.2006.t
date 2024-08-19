#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;

use HTML5::DOM;
use YAML::XS qw(Load);

use Kalaclista::Loader::Files qw(files);

use WebSite::Context::WebSite qw(section website);
use WebSite::Context::Path    qw(srcdir distdir);
use WebSite::Context::URI     qw(href);
use WebSite::Loader::Entry    qw(entry);

use WebSite::Templates::Permalink;

my sub readtime           { WebSite::Templates::Permalink::readtime(shift) }
my sub dom : prototype($) { state $p ||= HTML5::DOM->new; $p->parse(shift) }

my ( $section, $year ) = __FILE__ =~ m{\.([^./]+).([^.]+)\.t$};

( $section eq q{posts} || $section eq q{echos} ) && subtest "${section}/${year}" => sub {
  my $srcdir   = srcdir->child("entries/src/${section}/${year}")->path;
  my @articles = sort { $b->date cmp $a->date }
      map { s<${srcdir}/><>; entry "${section}/${year}/${_}" } files $srcdir;

  for my $article (@articles) {
    my $fn = $article->href->path;
    $fn .= "/index.html";

    my $file = distdir->child($fn);
    my $html = $file->load;
    utf8::decode($html);

    my $dom     = dom $html;
    my $head    = $dom->at('head');
    my $body    = $dom->at('body');
    my $website = section $section;

    my $title   = $article->title;
    my $summary = $article->summary ne q{} ? $article->summary : ( $article->dom->text =~ m{^(.{,70})} )[0] . '……';

    subtest $article->date => sub {

      subtest head => sub {
        subtest meta => sub {
          is $dom->at('html')->attr('lang'), 'ja', 'The page lang is `ja`';

          is $head->at('title')->text, $title . ' - ' . $website->title,
              'The page title includes article and website titles';
          is $head->at('meta[name="description"]')->attr('content'), $summary,
              'The page description is a article summary';
        };

        subtest ogp => sub {
          is $head->at('meta[property="og:site_name"]')->attr('content'), $website->title,
              'The ogp site_name has a section title';

          is $head->at('meta[property="og:image"]')->attr('content'), href('/assets/avatar.png')->to_string,
              'The ogp image is a avatar url';

          is $head->at('meta[property="og:url"]')->attr('content'), $article->href->to_string,
              'The ogp url is same as article permalink';

          is $head->at('meta[property="og:description"]')->attr('content'), $summary,
              'The ogp description is same as article summary';

          is $head->at('meta[property="og:locale"]')->attr('content'), 'ja_JP',
              'The ogp locale is a `ja_JP`';

          is $head->at('meta[property="og:type"]')->attr('content'), 'article',
              'The opg type is `article`';

          is $head->at('meta[property="og:published_time"]')->attr('content'), $article->date,
              'The opg published_time is same article date';

          is $head->at('meta[property="og:modified_time"]')->attr('content'), $article->updated,
              'The ogp modified_time is same as article updated';

          is $head->at('meta[property="og:section"]')->attr('content'), $section,
              'The ogp section is same as website section';

          is $head->at('meta[property="og:author:first_name"]')->attr('content'), 'Naoki',
              'The ogp first_name is my given name';

          is $head->at('meta[property="og:author:last_name"]')->attr('content'), 'OKAMURA',
              'The ogp first_name is my family name';
          ok(1);
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
            '@id'      => $article->href->to_string,
            '@type'    => 'BlogPosting',
            headline   => $article->title,
            author     => {
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

            mainEntityOfPage => href("/${section}/")->to_string,
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
              {
                '@type'  => 'ListItem',
                name     => $article->title,
                item     => $article->href->to_string,
                position => 3,
              }
            ],
              },
              'The JSON-LD breadcrumb is valid';
        };
      };

      subtest body => sub {
        subtest header => sub {
          my $header = $body->at('.h-entry > header');

          is $header->at('h1')->textContent, $article->title,
              'The header title is article title';

          is $header->at('h1 > a')->attr('href'), $article->href->to_string,
              'The header link is a article permalink';
        };

        subtest meta => sub {
          my $date = ( split qr<T>, $article->date )[0];
          my $meta = $body->at('.h-entry > header > p');

          is $meta->at('time')->attr('datetime'), $date,        'The date of entry is article published time';
          is $meta->at('time')->textContent,      "更新：${date}", 'The date label of entry is article published time';

          is $meta->at('span')->textContent, "読了まで：約" . readtime( $article->dom->innerHTML ) . "分",
              'The readtime has right value';
        };
      };
    };
  }
};

done_testing;
