use Kalaclista::Directory;
use YAML::Tiny;
use URI::Escape;

my $datadir = Kalaclista::Directory->instance->datadir;

my $extensions = sub {
  my $meta   = shift;
  my $prefix = $ENV{'URL'};
  return sub {
    my $dom = shift;

    for my $item ( $dom->find('p > img:only-child')->@* ) {
      my $src = $item->getAttribute('src');
      utf8::decode($src);
      $src = uri_unescape($src);

      if ( $src =~ m{^https://the\.kalaclista\.com/images/(.+)$} ) {
        my $path = $1;
        $path =~ s{\.[^\.]+$}{};
        $path = uri_unescape($path);
        utf8::decode($path);

        my $yaml = $datadir->child("images/${path}.yaml");

        if ( $yaml->is_file ) {
          my $data = YAML::Tiny::Load( $yaml->slurp_utf8 );

          my $img = $item->tree->createElement('img');
          $img->setAttribute( alt   => $item->getAttribute('alt') );
          $img->setAttribute( title => $item->getAttribute('alt') );

          my @srcset;
          my ( $thumb, $width, $height );
          for my $size (qw( 2x 1x )) {
            if ( exists $data->{$size} ) {
              my $href = "${prefix}/images/${path}_thumb_${size}.png";
              $thumb = $href;
              push @srcset, "${href} ${size}";

              if ( !defined $width || $width > $data->{$size}->{'width'} ) {
                ( $width, $height ) = @{ $data->{$size} }{qw(width height)};
              }
            }
          }

          if ( @srcset == 0 ) {
            $img->setAttribute( src    => $src );
            $img->setAttribute( width  => $data->{'origin'}->{'width'} );
            $img->setAttribute( height => $data->{'origin'}->{'height'} );
          }
          else {
            my $srcset = join q(, ), @srcset;
            $img->setAttribute( src    => $thumb );
            $img->setAttribute( srcset => $srcset );
            $img->setAttribute( width  => $width );
            $img->setAttribute( height => $height );
          }

          my $link = $dom->tree->createElement('a');
          $link->setAttribute( href => $item->getAttribute('src') );
          $link->setAttribute( className(qw( content card thumbnail )) );
          $link->appendChild($img);

          $item->replace($link);
        }
      }
    }
  };
};

$extensions;
