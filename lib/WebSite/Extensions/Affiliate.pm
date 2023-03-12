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
  my $el    = shift;
  my @shops = @_;

  my $primary = $shops[0];

  my $aside = $el->tree->createElement('aside');
  $aside->setAttribute( 'class', 'content__card--affiliate' );

  my $html = q{};
  $html .= h2( a( { href => $primary->link }, $primary->label ) );
  $html .= p(
    raw( $primary->image ),
  );
  $html .= ul( map { linkify($_) } @shops );

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

      if ( !exists $shop->{'provider'} ) {
        warn "provider is not found: ${title}\n";
        next;
      }

      if ( $shop->{'provider'} eq 'amazon' ) {
        push @shops, Kalaclista::Shop::Amazon->new(
          $shop->%*,
          label => $title,
        );
        next;
      }

      if ( $shop->{'provider'} eq 'rakuten' ) {
        if ( exists $shop->{'shop'} && $shop->{'shop'} ne q{} ) {
          my $item = Kalaclista::Shop::Rakuten->new(
            label  => $title,
            search => ( defined $shop->{'search'} ? $shop->{'search'} : $title ),
          );

          push @shops, Kalaclista::Shop::Rakuten->new(
            label => $item->label,
            link  => $item->link,
            image => a(
              { href => $item->link },
              img(
                {
                  src    => $shop->{'image'},
                  width  => ( split qr{x}, $shop->{'size'} )[0],
                  height => ( split qr{x}, $shop->{'size'} )[1]
                }
              )
            ),
          );
        }
        else {
          push @shops,
              Kalaclista::Shop::Rakuten->new( search => $shop->{'search'} );
        }

        next;
      }
    }
    replace( $item, @shops );
  }

  return $entry;
}

1;
