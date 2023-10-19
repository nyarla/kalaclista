package WebSite::Extensions::Picture;

use strict;
use warnings;
use utf8;

use feature qw(state);

use YAML::XS;
use URI::Escape;
use Kalaclista::HyperScript qw(a img);

use WebSite::Context;

sub transform {
  state $datadir ||= WebSite::Context->instance->dirs->cache('images');
  state $prefix  ||= WebSite::Context->instance->baseURI->to_string;

  my ( $class, $entry, $dom, $scales ) = @_;

  for my $item ( $dom->find('p > img:only-child')->@* ) {
    my $src = $item->getAttribute('src');

    utf8::decode($src);
    $src = uri_unescape($src);

    if ( $src =~ m{^\d+$} ) {
      my $path = join q{/}, $entry->href->path, $src;
      $path =~ s{^/}{};

      my $yaml = $datadir->child("${path}.yaml");
      if ( -f $yaml->path ) {
        my $data = YAML::XS::LoadFile( $yaml->path );

        my $img;
        my $src;

        if ( exists $data->{'gif'} ) {
          $src = "${prefix}/images/${path}.gif";
          $img = img(
            {
              alt    => $item->getAttribute('alt'),
              title  => $item->getAttribute('alt'),
              src    => $src,
              width  => $data->{'gif'}->{'width'},
              height => $data->{'gif'}->{'height'},
            }
          );
        }
        else {
          my @srcset;
          my @sizes;

          for my $scale ( $scales->@* ) {
            push @sizes, "(max-width: ${scale}px) ${scale}px";
          }

          if ( $path =~ m{^notes/([^/]+)/(.+)$} ) {
            my ( $fn, $idx ) = ( $1, $2 );
            utf8::decode($fn);
            $path = "notes/@{[ uri_escape_utf8($fn) ]}/${idx}";
          }

          for my $size (qw(1x 2x)) {
            push @srcset, "${prefix}/images/${path}_${size}.webp " . $data->{$size}->{'width'} . "w";
          }

          $src = "${prefix}/images/${path}_1x.webp";
          $img = img(
            {
              alt    => $item->getAttribute('alt'),
              title  => $item->getAttribute('alt'),
              srcset => join( q{, }, @srcset ),
              sizes  => join( q{, }, @sizes ),
              src    => "${prefix}/images/${path}_1x.webp",
              width  => $data->{'1x'}->{'width'},
              height => $data->{'1x'}->{'height'},
            }
          );
        }

        my $link = $dom->tree->createElement('a');
        $link->setAttribute( href  => $src );
        $link->setAttribute( class => 'content__card--thumbnail' );
        $link->innerHTML("${img}");

        $item->replace($link);
      }

      return $entry;
    }
  }

  return $entry;
}

1;
