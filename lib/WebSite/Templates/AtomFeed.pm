package WebSite::Templates::AtomFeed;

use strict;
use warnings;
use utf8;

use Kalaclista::Constants;

use Text::HyperScript qw(h);
use WebSite::Helper::Hyperlink qw(href);

sub render {
  my $vars    = shift;
  my $baseURI = Kalaclista::Constants->baseURI;
  my $section = $vars->section;
  my $prefix  = $section eq 'pages' ? '' : "/${section}";

  my $href    = href( "${prefix}/",         $baseURI );
  my $feed    = href( "${prefix}/atom.xml", $baseURI );
  my @entries = $vars->entries->@*;

  return '<?xml version="1.0" encoding="UTF-8"?>' . "\n" . h(
    feed => { xmlns => 'http://www.w3.org/2005/Atom' } => [

      h( 'title',    $vars->title ),
      h( 'subtitle', $vars->description ),
      h( 'link',     { href => $href } ),
      h( 'link',     { rel  => 'self', href => $feed } ),
      h( 'id',       $feed ),
      h( 'icon',     $baseURI->as_string . '/assets/avatar.png' ),
      h(
        'author',
        [
          h( 'name',  'OKAMURA Naoki aka nyarla' ),
          h( 'email', 'nyarla@kalaclista.com' ),
          h( 'uri',   'https://the.kalaclista.com/nyarla/' )
        ]
      ),
      h( 'updated', $entries[0]->lastmod ),

      (
        map {
          h(
            'entry',
            [
              h( 'title', $_->title ),
              h( 'id',    $_->href->to_string ),
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
        } @entries
      ),
    ]
  );
}

1;
