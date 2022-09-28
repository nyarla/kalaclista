package WebSite::Templates::JSONFeed;

use strict;
use warnings;
use utf8;

use JSON::Tiny qw(encode_json);

sub render {
  my ( $vars, $baseURI ) = @_;

  my $data = {
    version     => 'https://jsonfeed.org/version/1.1',
    title       => $vars->website,
    description => $vars->description,
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
    home_page_url => $vars->href,
    feed_url      => $vars->href . 'jsonfeed.json',
    items         => [
      map {
        +{
          id             => $_->[0]->href,
          url            => $_->[0]->href,
          title          => $_->[0]->title,
          content_html   => $_->[1]->dom->innerHTML,
          date_published => $_->[0]->date,
          date_modified  => $_->[0]->lastmod,
          authors        => [
            {
              name   => 'OKAMURA Naoki aka nyarla',
              url    => 'https://the.kalaclista.com/nyarla/',
              avatar => 'https://the.kalaclista.com/assets/avatar.png',
            }
          ],
          language => 'ja_JP',
        }
      } $vars->entries->@*
    ],
  };

  my $json = encode_json($data);
  utf8::decode($json);

  return $json;
}

1;
