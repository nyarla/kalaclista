package WebSite::Loader::WebSite;

use v5.38;
use utf8;

use feature qw(state);

use Exporter::Lite;
use URI::Fast;

use Kalaclista::Data::WebSite;
use Kalaclista::Loader::CSV;

our @EXPORT = qw(external);

my sub websites { state $src ||= shift; $src }

sub init {
  my $class = shift;
  my $file  = shift;
  my $data  = loadcsv $file => sub {
    my ( $updated, $status, $locked, $link, $permalink, $title ) = @_;    ## TODO: fix header on Google Sheet
    my $gone = $status != 200;

    return Kalaclista::Data::WebSite->new(
      title => $title,
      link  => URI::Fast->new($link),
      href  => URI::Fast->new($permalink),
      gone  => $gone,
    );
  };

  websites(
    {
      map {
        (
          $_->href->to_string => $_,
          $_->link->to_string => $_,
        )
      } $data->@*
    }
  );

  return;
}

sub external : prototype($$) {
  my ( $title, $link ) = @_;

  my $website = websites->{$link};
  if ( !defined $website ) {
    return Kalaclista::Data::WebSite->new(
      title => $title,
      href  => URI::Fast->new($link),
      gone  => !!0,
    );
  }

  if ( $website->gone ) {
    return Kalaclista::Data::WebSite->new(
      title => $title,
      href  => URI::Fast->new($link),
      gone  => !!1,
    );
  }

  return $website;
}
