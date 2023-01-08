package WebSite::Extensions::Affiliate;

use strict;
use warnings;
use utf8;

use Kalaclista::Constants;
use Kalaclista::Shop::Amazon;
use Kalaclista::Shop::Rakuten;

use Kalaclista::HyperScript;

my $datadir = Kalaclista::Constants->rootdir->child('content/data/items');

sub key {
  my $key = shift;

  $key =~ s{[^\p{InHiragana}\p{InKatakana}\p{InCJKUnifiedIdeographs}a-zA-Z0-9\-_]}{_}g;
  $key =~ s{_+}{_}g;

  return "${key}.yaml";
}

sub linkify {
  my $shop = shift;

  if ( ref $shop eq 'Kalaclista::Shop::Amazon' ) {
    return li(
      { class => 'amazon' },
      a( { href => $shop->link }, 'Amazon.co.jp で探す' ),
      img( { src => $shop->beacon, width => 1, height => 1 } )
    );
  }

  if ( ref $shop eq 'Kalaclista::Shop::Rakuten' ) {
    return li(
      { class => 'rakuten' },
      a( { href => $shop->link, class => 'rakuten' }, '楽天で探す' )
    );
  }

  return q{};
}

sub replace {
  my $el   = shift;
  my $data = shift;

  my $aside = $el->tree->createElement('aside');
  $aside->setAttribute( 'class', 'content__card--affiliate' );

  my $html = q{};
  $html .= h1( a( { href => $data->{'href'} }, $data->{'title'} ) );
  $html .= p(
    a(
      { href => $data->{'href'} },
      img(
        {
          src    => $data->{'thumbnail'},
          width  => $data->{'width'},
          height => $data->{'height'},
        }
      )
    )
  );
  $html .= ul( map { linkify($_) } $data->{'links'}->@* );

  $aside->innerHTML($html);

  $el->parent->replace($aside);
}

sub transform {
  my ( $class, $entry, $dom ) = @_;

  for my $item ( $dom->find('p > a:only-child')->@* ) {
    unless ( $item->parent->firstChild->isSameNode($item)
      && $item->parent->lastChild->isSameNode($item) ) {
      next;
    }

    my $key  = key( $item->textContent );
    my $yaml = $datadir->child($key);

    if ( !-f $yaml->path ) {
      next;
    }

    my $info = YAML::XS::LoadFile( $yaml->path );

    my $title = $info->{'name'};
    my @shops;

    for my $shop ( $info->{'data'}->@* ) {
      if ( $shop->{'provider'} eq 'amazon' ) {
        push @shops,
            Kalaclista::Shop::Amazon->new(
              label  => $title,
              asin   => $shop->{'asin'},
              width  => ( split qr{x}, $shop->{'size'} )[0],
              height => ( split qr{x}, $shop->{'size'} )[1],
              tag    => $shop->{'tag'},
            );
        next;
      }

      if ( $shop->{'provider'} eq 'rakuten' ) {
        if ( exists $shop->{'shop'} && $shop->{'shop'} ne q{} ) {
          push @shops,
              Kalaclista::Shop::Rakuten->new(
                label  => $title,
                search => $shop->{'search'},
                width  => ( split qr{x}, $shop->{'size'} )[0],
                height => ( split qr{x}, $shop->{'size'} )[1],
                image  => $shop->{'image'},
                shop   => $shop->{'shop'},
              );
        }
        else {
          push @shops,
              Kalaclista::Shop::Rakuten->new( search => $shop->{'search'} );
        }

        next;
      }
    }

    my $first = $shops[0];
    my %data  = (
      title     => $first->label,
      href      => $first->link,
      beacon    => ( $first->can('beacon') ? $first->beacon : '' ),
      thumbnail => $first->image,
      width     => $first->width,
      height    => $first->height,
      links     => \@shops,
    );

    replace( $item, \%data );
  }

  return $entry;
}

1;
