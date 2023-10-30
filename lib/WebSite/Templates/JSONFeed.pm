package WebSite::Templates::JSONFeed;

use strict;
use warnings;
use utf8;

use JSON::XS;

use WebSite::Context;
use WebSite::Helper::Hyperlink qw(href);

my $jsonify = JSON::XS->new->utf8->canonical(1);

sub render {
  my $page    = shift;
  my $c       = WebSite::Context->instance;
  my $baseURI = $c->baseURI;
  my $section = $page->section;
  my $prefix  = $section eq 'pages' ? ''          : "/${section}";
  my $website = $section eq 'pages' ? $c->website : $c->sections->{$section};

  my $href    = href( "${prefix}/",              $baseURI );
  my $feed    = href( "${prefix}/jsonfeed.json", $baseURI );
  my @entries = $page->entries->@*;

  my $data = {
    version     => 'https://jsonfeed.org/version/1.1',
    title       => $website->title,
    description => $website->summary,
    icon        => 'https://the.kalaclista.com/assets/avatar.png',
    favicon     => 'https://the.kalaclista.com/favicon.ico',
    authors     => [
      {
        name   => 'OKAMURA Naoki aka nyarla',
        url    => 'https://the.kalaclista.com/nyarla/',
        avatar => 'https://the.kalaclista.com/assets/avatar.png',
      }
    ],
    language      => 'ja_JP',
    home_page_url => $href,
    feed_url      => $feed,
    items         => [
      map {
        +{
          id             => $_->href . '',
          url            => $_->href . '',
          title          => $_->title,
          content_html   => $_->dom->innerHTML,
          date_published => $_->date,
          date_modified  => $_->lastmod,
          authors        => [
            {
              name   => 'OKAMURA Naoki aka nyarla',
              url    => 'https://the.kalaclista.com/nyarla/',
              avatar => 'https://the.kalaclista.com/assets/avatar.png',
            }
          ],
          language => 'ja_JP',
        }
      } sort { $b->date cmp $a->date } $page->entries->@*
    ],
  };

  my $json = $jsonify->encode($data);
  utf8::decode($json);

  return $json;
}

1;
