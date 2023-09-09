package WebSite::Extensions::WebSite;

use strict;
use warnings;
use utf8;

use Kalaclista::Constants;
use Kalaclista::Data::WebSite;
use Kalaclista::HyperScript qw(a div h2 p cite blockquote small);

my $csv = Kalaclista::Constants->rootdir->child('content/data/website.csv')->path;
Kalaclista::Data::WebSite->init($csv);

sub transform {
  my ( $class, $entry, $dom ) = @_;

  for my $item ( $dom->find('ul > li:only-child > a:only-child')->@* ) {
    my $href = $item->getAttribute('href');
    my $text = $item->innerText;

    next if $href !~ m{^https?};

    my $html;
    my $web = Kalaclista::Data::WebSite->load( text => $text, href => $href );

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
