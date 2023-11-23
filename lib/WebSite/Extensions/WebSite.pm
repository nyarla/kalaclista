package WebSite::Extensions::WebSite;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Kalaclista::Data::WebSite;
use Kalaclista::HyperScript qw(a div h2 p cite blockquote small);

use WebSite::Context;

sub website {
  state $initialized;
  if ( !$initialized ) {
    my $path = WebSite::Context->instance->cache('website/src.yaml')->path;
    Kalaclista::Data::WebSite->init($path);

    $initialized = !!1;
  }

  my @args = @_;
  return Kalaclista::Data::WebSite->load(@args);
}

sub transform {
  my ( $class, $entry ) = @_;

  for my $item ( $entry->dom->find('ul > li:only-child > a:only-child')->@* ) {
    my $href = $item->getAttribute('href');
    my $text = $item->innerText;

    next if $href !~ m{^https?};

    my $html;
    my $web = website( text => $text, href => $href );

    if ( !$web->gone ) {
      $html = a(
        { href => $web->permalink },
        h2( $web->title ),
        p( cite( $web->cite ) ),
        blockquote( p( $web->summary ) )
      );
    }
    else {
      $html = div(
        h2( $web->title ),
        p( cite( $web->cite ), small('（無効なリンクです）') ),
        blockquote( p( $web->summary ) )
      );
    }

    my $article = $item->tree->createElement('aside');
    $article->setAttribute( class => 'content__card--website' . ( $web->gone ? ' gone' : q{} ) );
    $article->innerHTML( $html->to_string );
    $item->parent->parent->replace($article);
  }
}

1;
