use strict;
use warnings;
use utf8;

use YAML::XS;

use Kalaclista::Directory;
use Kalaclista::Shop::Amazon;
use Kalaclista::Shop::Rakuten;

sub key {
  my ($name) = @_;

  $name =~ s{[^\p{InHiragana}\p{InKatakana}\p{InCJKUnifiedIdeographs}a-zA-Z0-9\-_]}{_}g;
  $name =~ s{_+}{_}g;

  return "${name}.yaml";
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

my $dirs = Kalaclista::Directory->instance;

my $extension = sub {
  my ( $entry, $dom ) = @_;

  for my $item ( $dom->find('p > a:only-child')->@* ) {
    if ( !$item->parent->firstChild->isSameNode($item)
      || !$item->parent->lastChild->isSameNode($item) ) {
      next;
    }

    my $key  = $item->textContent;
    my $yaml = $dirs->datadir->child('items')->child( key($key) );

    if ( !$yaml->is_file ) {
      next;
    }

    my $info = YAML::XS::Load( $yaml->slurp );

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
};

$extension;
