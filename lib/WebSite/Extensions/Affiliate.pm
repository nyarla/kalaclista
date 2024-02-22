package WebSite::Extensions::Affiliate;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Kalaclista::Shop::Amazon;
use Kalaclista::Shop::Rakuten;

use Kalaclista::HyperScript qw(aside h2 ul li a img);

use WebSite::Context;
use WebSite::Helper::TailwindCSS;

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
      classes(q|list-none|),
      a(
        classes(q|text-darker text-sm|),
        { href => $shop->link },
        img(
          classes(q|inline mr-1 align-middle|),
          {
            src   => "https://www.google.com/s2/favicons?sz=64&domain_url=amazon.co.jp&size=32",
            width => 16, height => 16, alt => ''
          }
        ),
        'Amazon.co.jp で探す'
      ),
    );
  }

  if ( ref $shop eq 'Kalaclista::Shop::Rakuten' ) {
    return li(
      classes(q|list-none|),
      a(
        classes(q|text-darker text-sm|),
        { href => $shop->link },
        img(
          classes(q|inline mr-1 align-middle|),
          {
            src   => "https://www.google.com/s2/favicons?sz=64&domain_url=rakuten.co.jp&size=32",
            width => 16, height => 16, alt => ''
          }
        ),
        '楽天で探す'
      )
    );
  }

  return q{};
}

sub replace {
  my $target = shift;
  my @shops  = @_;

  my $primary = $shops[0];
  my $title   = h2(
    classes(q|!mb-4 !mt-0 !leading-6 truncate|),
    a(
      classes(q|text-lg font-bold text-darkest|),
      { href => $primary->link }, $primary->label
    ),
  );

  my $out = aside(
    classes( qw(is-affiliate), q|border-4 rounded-xl border-green block mb-4 px-6 py-4 bg-[#FFF] text-darkest| ),
    $title,
    ul( classes(q|!ml-0|), ( map { linkify($_) } @shops ) )
  );

  $target->innerHTML("$out");
}

sub transform {
  state $datadir ||= WebSite::Context->instance->dirs->rootdir->child('content/data/items');    #FIXME
  my ( $class, $entry ) = @_;

  for my $item ( $entry->dom->find('p > a:only-child')->@* ) {
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
