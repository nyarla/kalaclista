package WebSite::Extensions::Picture;

use strict;
use warnings;
use utf8;

use YAML::XS;
use URI::Escape;
use Kalaclista::HyperScript qw(a img);

use Kalaclista::Constants;

my $datadir = Kalaclista::Constants->rootdir->child('content/data/pictures');
my $prefix  = Kalaclista::Constants->baseURI->to_string;

sub transform {
  my ( $class, $entry, $dom, $scales ) = @_;

  for my $item ( $dom->find('p > img:only-child')->@* ) {
    my $src = $item->getAttribute('src');

    utf8::decode($src);
    $src = uri_unescape($src);

    if ( $src =~ m{^https://the\.kalaclista\.com/images/(.+)\.([^\.]+)$} ) {
      my ( $path, $ext ) = ( $1, $2 );

      next if ( $ext eq 'gif' );

      my $yaml = $datadir->child("${path}.yaml");

      if ( -f $yaml->path ) {
        my $data = YAML::XS::LoadFile( $yaml->path );

        my @srcset;
        my @sizes;

        for my $scale ( $scales->@* ) {
          push @sizes, "(max-width: ${scale}px) ${scale}px";
        }
        push @sizes, $data->{'src'}->{'width'} . 'px';

        utf8::decode($path);
        if ( $path =~ m{^notes/([^/]+)/(.+)$} ) {
          my ( $fn, $idx ) = ( $1, $2 );
          utf8::decode($fn);
          $path = "notes/@{[ uri_escape_utf8($fn) ]}/${idx}";
        }

        for my $size (qw(1x 2x)) {
          push @srcset, "${prefix}/images/${path}_${size}.webp " . $data->{$size}->{'width'} . "w";
        }
        push @srcset, "${prefix}/images/${path}.${ext}" . " " . $data->{'src'}->{'width'} . "w";

        my $img = img(
          {
            alt    => $item->getAttribute('alt'),
            title  => $item->getAttribute('alt'),
            srcset => join( q{, }, @srcset ),
            sizes  => join( q{, }, @sizes ),
            src    => "${prefix}/images/${path}_2x.webp",
            width  => $data->{'1x'}->{'width'},
            height => $data->{'1x'}->{'height'},
          }
        );

        my $link = $dom->tree->createElement('a');
        $link->setAttribute( href  => $item->getAttribute('src') );
        $link->setAttribute( class => 'content__card--thumbnail' );
        $link->innerHTML("${img}");

        $item->replace($link);
      }
    }
  }

  return $entry;
}

1;
