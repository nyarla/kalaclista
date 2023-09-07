package WebSite::Extensions::WebSite;

use strict;
use warnings;
use utf8;
use feature qw(state);

use URI::Fast;
use URI::Escape qw(uri_unescape);
use Text::CSV   qw(csv);

use Kalaclista::HyperScript qw(a h2 p blockquote cite div small);

use Kalaclista::Constants;
use Kalaclista::WebSite;

my $datadir = Kalaclista::Constants->rootdir->child('content/data/webdata');

sub load {
  state $websites ||= do {
    my $csv = csv( in => Kalaclista::Constants->rootdir->child('content/data/website.csv')->path );
    shift $csv->@*;

    my $data = {};
    for my $line ( $csv->@* ) {
      my $gone      = $line->[2] eq 'yes';
      my $status    = $line->[4];
      my $title     = $line->[5];
      my $link      = $line->[6];
      my $permalink = $line->[7];
      my $summary   = $line->[8];

      my $website = Kalaclista::WebSite->new(
        is_gone      => $gone,
        is_ignore    => $gone,
        has_redirect => ( $link ne $permalink ),
        status       => $status,
        updated_at   => 0,
        href         => $permalink,
        title        => $title,
        summary      => $summary,
      );

      $data->{$link}      = $website;
      $data->{$permalink} = $website;
    }

    $data;
  };

  my $href = shift;

  return $websites->{$href};
}

sub transform {
  my ( $class, $entry, $dom ) = @_;

  for my $item ( $dom->find('ul > li:only-child > a:only-child')->@* ) {
    my $href = $item->getAttribute('href');
    my $text = $item->innerText;

    next if ( $href !~ m{^https?} );

    my ( $title, $summary, $permalink, $gone );
    my $src = uri_unescape($href);
    utf8::decode($src);

    my $website = load($href);
    if ( defined $website && !$website->is_gone ) {
      $title     = $website->title ne q{}   ? $website->title   : $text;
      $summary   = $website->summary ne q{} ? $website->summary : $title;
      $permalink = $website->href ne q{}    ? $website->href    : $href;
      $gone      = 0;
    }
    else {
      $title     = $text;
      $permalink = $src;
      $summary   = $title;
      $gone      = 1;
    }

    if ( length($summary) > 39 ) {
      $summary = substr( $summary, 0, 39 ) . "……";
    }

    my $html;
    if ( !$gone ) {
      $html = a( { href => $permalink }, h2($title), p( cite($src) ), blockquote( p($summary) ) );
    }
    else {
      $html = div( h2($title), p( cite($src), small('（無効なリンクです）') ), blockquote( p($summary) ) );
    }

    my $article = $item->tree->createElement('aside');
    $article->setAttribute( class => 'content__card--website' );
    $article->innerHTML( $html->to_string );

    $item->parent->parent->replace($article);
  }

  return $entry;
}

1;
