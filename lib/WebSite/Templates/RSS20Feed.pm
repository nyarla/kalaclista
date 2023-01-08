package WebSite::Templates::RSS20Feed;

use strict;
use warnings;
use utf8;

use Kalaclista::HyperScript qw(h);
use Time::Moment;

use Kalaclista::Constants;

use WebSite::Helper::Hyperlink qw(href);

my $format = '%a %m %b %Y %T %z';

sub render {
  my $vars    = shift;
  my $baseURI = Kalaclista::Constants->baseURI;
  my $section = $vars->section;
  my $prefix  = $section eq 'pages' ? '' : "/${section}";

  my $href    = href( "${prefix}/",          $baseURI );
  my $feed    = href( "${prefix}/index.xml", $baseURI );
  my @entries = $vars->entries->@*;

  return '<?xml version="1.0" encoding="UTF-8"?>' . "\n" . h(
    'rss',
    { version => "2.0", "xmlns:atom" => 'http://www.w3.org/2005/Atom' },
    h(
      channel => h( title => $vars->title ),
      h( link => $feed ),
      h( 'atom:link', { href => $href, type => 'application/rss+xml' } ),
      h( 'atom:link', { href => $feed, rel  => 'self' } ),
      h( description    => $vars->description ),
      h( managingEditor => 'OKAMURA Naoki aka nyarla (nyarla@kalaclista.com)' ),
      h( webMaster      => 'OKAMURA Naoki aka nyarla (nyarla@kalaclista.com)' ),
      h( copyright      => '(c) 2006-' . ( (localtime)[5] + 1900 ) . ' OKAMURA Naoki' ),
      h( lastBuildDate  => Time::Moment->from_string( $entries[0]->lastmod )->strftime($format) ),
      (
        map {
          h(
            item => [
              h( title       => $_->title ),
              h( link        => $_->href ),
              h( pubDate     => Time::Moment->from_string( $_->lastmod )->strftime($format) ),
              h( guid        => $_->href ),
              h( description => $_->dom->innerHTML ),
            ]
          )
        } @entries
      ),
    )
  );
}

1;
