package WebSite::Templates::RSS20Feed;

use strict;
use warnings;
use utf8;

use Text::HyperScript qw(h);
use Time::Moment;

my $format = '%a %m %b %Y %T %z';

sub render {
  my ( $vars, $baseURI ) = @_;

  return '<?xml version="1.0" encoding="UTF-8"?>' . "\n" . h(
    'rss',
    { version => "2.0", "xmlns:atom" => 'http://www.w3.org/2005/Atom' },
    h(
      channel => h( title => $vars->website ),
      h( link => $vars->href ),
      h( 'atom:link', { href => $vars->href,               type => 'application/rss+xml' } ),
      h( 'atom:link', { href => $vars->href . "index.xml", rel  => 'self' } ),
      h( description    => $vars->description ),
      h( managingEditor => 'OKAMURA Naoki aka nyarla (nyarla@kalaclista.com)' ),
      h( webMaster      => 'OKAMURA Naoki aka nyarla (nyarla@kalaclista.com)' ),
      h( copyright      => '(c) 2006-' . ( (localtime)[5] + 1900 ) . ' OKAMURA Naoki' ),
      h( lastBuildDate  => Time::Moment->from_string( $vars->entries->[0]->lastmod )->strftime($format) ),
      (
        map {
          $_->transform;
          h(
            item => [
              h( title       => $_->title ),
              h( link        => $_->href ),
              h( pubDate     => Time::Moment->from_string( $_->lastmod )->strftime($format) ),
              h( guid        => $_->href ),
              h( description => $_->dom->innerHTML ),
            ]
          )
        } $vars->entries->@*
      ),
    )
  );
}

1;
