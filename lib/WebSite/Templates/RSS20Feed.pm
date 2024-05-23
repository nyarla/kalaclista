package WebSite::Templates::RSS20Feed;

use strict;
use warnings;
use utf8;

use Kalaclista::HyperScript qw(h);
use Time::Moment;

use WebSite::Context::WebSite qw(section);
use WebSite::Context::URI     qw(href);

my $format = '%a %m %b %Y %T %z';

sub render {
  my $page    = shift;
  my $section = $page->section;
  my $prefix  = $section eq 'pages' ? '' : "/${section}";
  my $website = section($section);

  my $href = href "${prefix}/";

  my $feed = href "${prefix}/index.xml";

  my @entries = $page->entries->@*;

  return '<?xml version="1.0" encoding="UTF-8"?>' . "\n" . h(
    'rss',
    { version => "2.0", "xmlns:atom" => 'http://www.w3.org/2005/Atom' },
    h(
      channel => h( title => $website->title ),
      h( link => $feed ),
      h( 'atom:link', { href => $href->to_string, type => 'application/rss+xml' } ),
      h( 'atom:link', { href => $feed->to_string, rel  => 'self' } ),
      h( description    => $website->summary ),
      h( managingEditor => 'OKAMURA Naoki aka nyarla (nyarla@kalaclista.com)' ),
      h( webMaster      => 'OKAMURA Naoki aka nyarla (nyarla@kalaclista.com)' ),
      h( copyright      => '(c) 2006-' . ( (localtime)[5] + 1900 ) . ' OKAMURA Naoki' ),
      h( lastBuildDate  => Time::Moment->from_string( $entries[0]->updated )->strftime($format) ),
      (
        map {
          h(
            item => [
              h( title       => $_->title ),
              h( link        => $_->href->to_string ),
              h( pubDate     => Time::Moment->from_string( $_->updated )->strftime($format) ),
              h( guid        => $_->href->to_string ),
              h( description => $_->dom->innerHTML ),
            ]
          )
        } @entries
      ),
    )
  );
}

1;
