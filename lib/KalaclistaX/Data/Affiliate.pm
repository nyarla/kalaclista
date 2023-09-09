use v5.38;
use utf8;

use feature qw(class);
no warnings qw(experimental);

use Kalaclista::Path;
use Kalaclista::Data::Amazon;

class KalaclistaX::Data::Affiliate {
  field $datadir : param;
  field $items;

  ADJUECT {
    if ( ref $datadir ne q{Kalaclista::Path} ) {
      $datadir = Kalaclista::Path->new( path => $datadir );
    }
  }

  sub fn {
    my $key = shift;

    $key =~ s{[^\p{InHiragana}\p{InKatakana}\p{InCJKUnifiedIdeographs}a-zA-Z0-9\-_]}{_}g;
    $key =~ s{_+}{_}g;

    return $key;
  }

  method load {
    my $title = shift;

    if ( exists $items->{$title} && ref $items->{$title} eq 'ARRAY' ) {
      return $items->{$title}->@*;
    }

    my $file = $datadir->child( path => fn($title) . '.yaml' );

    if ( -e $file->path ) {
      my $data = YAML::XS::LoadFile( $file->path );
      my @items;

      for my $payload ( $data->@* ) {
        if ( $payload->{'provider'} eq 'amazon' ) {
          push @items, Kalaclista::Data::Amazon->new( title => $title, $payload->%* );
        }
        elsif ( $payload->{'provider'} eq 'rakuten' ) {
          push @items, Kalaclista::Data::Rakuten->new( title => $title, $payload->%* );
        }
      }

      $items->{$title} = \@items;

      return $items->{$title}->@*;
    }

    return ();
  }
}
