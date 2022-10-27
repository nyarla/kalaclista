package WebSite::Templates::JSONFeed;

use strict;
use warnings;
use utf8;

use JSON::XS;

my $jsonify = JSON::XS->new->utf8->canonical(1);

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
      } $vars->entries->@*
    ],
  };

  my $json = $jsonify->encode($data);
  utf8::decode($json);

  return $json;
}

1;
