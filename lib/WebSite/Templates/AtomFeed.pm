package WebSite::Templates::AtomFeed;

use strict;
use warnings;
use utf8;

use Kalaclista::HyperScript qw(h);

use WebSite::Context;
use WebSite::Context::URI qw(href);

sub render {
  my $vars    = shift;
  my $c       = WebSite::Context->instance;
  my $section = $vars->section;
  my $prefix  = $section eq 'pages' ? ''          : "/${section}";
  my $website = $section eq 'pages' ? $c->website : $c->sections->{$section};

  my $href    = href "${prefix}/";
  my $feed    = href "${prefix}/atom.xml";
  my @entries = $vars->entries->@*;

  return '<?xml version="1.0" encoding="UTF-8"?>' . "\n" . h(
    feed => { xmlns => 'http://www.w3.org/2005/Atom' } => [

      h( 'title',    $website->title ),
      h( 'subtitle', $website->summary ),
      h( 'link',     { href => $href->to_string } ),
      h( 'link',     { rel  => 'self', href => $feed->to_string } ),
      h( 'id',       $feed ),
      h( 'icon',     href('/assets/avatar.png') ),
      h(
        'author',
        [
          h( 'name',  'OKAMURA Naoki aka nyarla' ),
          h( 'email', 'nyarla@kalaclista.com' ),
          h( 'uri',   'https://the.kalaclista.com/nyarla/' )
        ]
      ),
      h( 'updated', $entries[0]->updated ),

      (
        map {
          h(
            'entry',
            [
              h( 'title', $_->title ),
              h( 'id',    $_->href->to_string ),
              h( 'link',  { href => $_->href->to_string } ),
              h(
                'author',
                [
                  h( 'name',  'OKAMURA Naoki aka nyarla' ),
                  h( 'email', 'nyarla@kalaclista.com' ),
                  h( 'uri',   'https://the.kalaclista.com/nyarla/' )
                ]
              ),
              h( 'updated', $_->updated ),
              h( 'content', { type => 'html' }, $_->dom->innerHTML )
            ]
          )
        } @entries
      ),
    ]
  );
}

1;
