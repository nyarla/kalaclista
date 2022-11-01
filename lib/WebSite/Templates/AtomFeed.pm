package WebSite::Templates::AtomFeed;

use strict;
use warnings;
use utf8;

use Text::HyperScript qw(h);

sub render {
  my ( $vars, $baseURI ) = @_;

  return '<?xml version="1.0" encoding="UTF-8"?>' . "\n" . h(
    feed => { xmlns => 'http://www.w3.org/2005/Atom' } => [

      h( 'title',    $vars->website ),
      h( 'subtitle', $vars->description ),
      h( 'link',     { href => $vars->href } ),
      h( 'link',     { rel  => 'self', href => $vars->href . "atom.xml" } ),
      h( 'id',       $vars->href . 'atom.xml' ),
      h( 'icon',     $baseURI->as_string . '/assets/avatar.png' ),
      h(
        'author',
        [
          h( 'name',  'OKAMURA Naoki aka nyarla' ),
          h( 'email', 'nyarla@kalaclista.com' ),
          h( 'uri',   'https://the.kalaclista.com/nyarla/' )
        ]
      ),
      h( 'updated', $vars->entries->[0]->lastmod ),

      (
        map {
          $_->transform;
          h(
            'entry',
            [
              h( 'title', $_->title ),
              h( 'id',    $_->href ),
              h( 'link',  { href => $_->href } ),
              h(
                'author',
                [
                  h( 'name',  'OKAMURA Naoki aka nyarla' ),
                  h( 'email', 'nyarla@kalaclista.com' ),
                  h( 'uri',   'https://the.kalaclista.com/nyarla/' )
                ]
              ),
              h( 'updated', $_->lastmod ),
              h( 'content', { type => 'html' }, $_->dom->innerHTML )
            ]
          )
        } $vars->entries->@*
      ),
    ]
  );
}

1;
