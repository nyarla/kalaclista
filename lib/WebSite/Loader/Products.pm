package WebSite::Loader::Products;

use v5.38;
use utf8;

use feature qw(state);

use Exporter::Lite;
use HTML5::DOM;
use URI::Fast;

use Kalaclista::Data::Thumbnail;
use Kalaclista::Data::WebSite;

use Kalaclista::Loader::CSV;

our @EXPORT    = qw(product);
our @EXPORT_OK = ( @EXPORT, qw(key) );

my sub products { state $src ||= shift;           $src }
my sub dom      { state $p   ||= HTML5::DOM->new; $p->parse(shift)->body }

my sub key {
  my $key = shift;

  $key =~ s{​}{}g;
  $key =~ s{[^\p{InHiragana}\p{InKatakana}\p{InCJKUnifiedIdeographs}a-zA-Z0-9\-_]}{_}g;
  $key =~ s{_+}{_}g;

  return $key;
}

sub init {
  my $class = shift;
  my $file  = shift;
  my $data  = loadcsv $file => sub {
    my ( $name, $amazon, $rakuten, $thumbnail ) = @_;

    my $gone = $amazon eq q{} && $rakuten eq q{} && $thumbnail eq q{};

    my $amzn = Kalaclista::Data::WebSite->new(
      title => $name,
      href  => URI::Fast->new($amazon),
      gone  => $gone,
    );

    my $r10t = Kalaclista::Data::WebSite->new(
      title => $name,
      href  => URI::Fast->new($rakuten),
      gone  => $gone,
    );

    my $image = $thumbnail ne q{} ? dom($thumbnail) : undef;

    return Kalaclista::Data::Thumbnail->new(
      type        => 'product',
      title       => $name,
      thumbnail   => $image,
      description => [ $amzn, $r10t ],
    );
  };

  products( { map { key( $_->title ) => $_ } $data->@* } );
  return;
}

sub product {
  my $key = key(shift);

  return products->{$key} if exists products->{$key};
  return undef;
}

1;
