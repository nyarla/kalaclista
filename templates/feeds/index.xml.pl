use Time::Moment;

my $template = sub {
  my ( $vars, $baseURI ) = @_;

  my @entries =
    sort { $b->[0]->lastmod cmp $a->[0]->lastmod } $vars->entries->@*;
  my $format = '%a %m %b %Y %T %z';

  return '<?xml version="1.0" encoding="UTF-8"?>' . "\n" . h(
    'rss',
    { version => "2.0", "xmlns:atom" => 'http://www.w3.org/2005/Atom' },
    h(
      channel => h( title => $vars->website ),
      h( link => $vars->href ),
      h( 'atom:link', { href => $vars->href, type => 'application/rss+xml' } ),
      h( 'atom:link', { href => $vars->href . "index.xml", rel => 'self' } ),
      h( description    => $vars->description ),
      h( managingEditor => 'OKAMURA Naoki aka nyarla (nyarla@kalaclista.com)' ),
      h( webMaster      => 'OKAMURA Naoki aka nyarla (nyarla@kalaclista.com)' ),
      h( copyright      => '(c) 2006-2022 OKAMURA Naoki' ),
      h(
        lastBuildDate =>
          Time::Moment->from_string( $entries[0]->[0]->lastmod )
          ->strftime($format)
      ),
      (
        map {
          h(
            item => [
              h( title => $_->[0]->title ),
              h( link  => $_->[0]->href ),
              h(
                pubDate => Time::Moment->from_string( $_->[0]->lastmod )
                  ->strftime($format)
              ),
              h( guid        => $_->[0]->href ),
              h( description => $_->[1]->dom->innerHTML ),
            ]
          )
        } @entries
      ),
    )
  );
};

$template;
