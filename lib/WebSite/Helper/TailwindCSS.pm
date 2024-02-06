package WebSite::Helper::TailwindCSS;

use strict;
use warnings;

use feature qw(state);

use Exporter::Lite;
use Carp qw(carp);

our @EXPORT = qw(apply classes custom);

sub classes {
  return { class => join( q{ }, split( qr{ }, join( q{ }, @_ ) ) ) };
}

1;
