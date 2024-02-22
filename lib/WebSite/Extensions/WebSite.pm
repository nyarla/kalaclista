package WebSite::Extensions::WebSite;

use strict;
use warnings;
use utf8;

use feature qw(state);

use URI::Fast;

use Kalaclista::Data::WebSite;
use Kalaclista::HyperScript qw(a div h2 p cite blockquote em img);

use WebSite::Context;
use WebSite::Helper::TailwindCSS;

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
        classes(q|border-4 rounded-xl hover:border-cyan border-bright block mb-4 px-6 py-4 bg-[#FFF] text-darkest|),
        { href => $web->permalink },
        p( classes(q|text-lg font-bold !mb-4 !leading-6 truncate|), $web->title ),
        p(
          classes(q|leading-4 !mb-0 truncate text-sm|),
          img(
            classes(q|inline-block mr-1.5 align-middle|),
            {
              src   => "https://www.google.com/s2/favicons?sz=64&domain_url=@{[ URI::Fast->new($web->permalink)->host ]}&size=32",
              width => 16, height => 16, alt => '',
            }
          ),
          cite( classes(q|not-italic !text-darker|), $web->cite )
        ),
      );
    }
    else {
      $html = div(
        classes(q|border-4 rounded-xl border-bright bg-bright block mb-4 px-6 py-4|),
        p( classes(q|text-lg font-bold !mb-4 !leading-6 truncate|), $web->title ),
        p(
          classes(q|leading-4 !mb-0 truncate text-sm|),
          em( classes(q|!not-italic|), '無効なリンク：' ),
          cite( classes(q|not-italic !text-darker|), $web->cite )
        ),
      );
    }

    my $article = $item->tree->createElement('aside');
    $article->setAttribute( class => 'h-item' . ( $web->gone ? ' gone' : q{} ) );
    $article->innerHTML( $html->to_string );
    $item->parent->parent->replace($article);
  }
}

1;
