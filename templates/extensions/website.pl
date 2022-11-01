use strict;
use warnings;
use utf8;

use URI::Fast;
use URI::Escape qw(uri_unescape);
use YAML::XS ();

use Kalaclista::Directory;
use Kalaclista::Utils qw(make_path);
use Kalaclista::WebSite;

my $dir = Kalaclista::Directory->instance->datadir;

my $website = sub {
  my ( $entry, $dom ) = @_;

  for my $item ( $dom->find('ul > li:only-child > a:only-child')->@* ) {
    my $href = $item->getAttribute('href');
    my $text = $item->innerText;

    next if ( $href !~ m{^https?} );

    my $path = make_path( URI::Fast->new($href) );
    my $file = $dir->child("webdata/${path}.yaml");

    my $link = uri_unescape($href);
    my $title;
    my $summary;

    if ( $file->is_file ) {
      my $data = YAML::XS::Load( $file->slurp );

      $title = $data->{'title'}
          if ( exists $data->{'title'} && $data->{'title'} ne q{} );

      $summary = $data->{'summary'}
          if ( exists $data->{'summary'} && $data->{'summary'} ne q{} );
    }

    $title //= $text // $summary // $link;
    $summary //= $text // $title // $summary // $link;

    my $article = $item->tree->createElement('aside');
    $article->setAttribute( class => 'content__card--website' );
    $article->innerHTML(
      a(
        { href => $href },
        h1($title),
        p( cite($link) ),
        blockquote( p($summary) )
      )->$*
    );

    $item->parent->parent->replace($article);
  }
};

$website;
