#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Module::Load qw(load);

use Kalaclista::Constants;
use Kalaclista::Entries;
use Kalaclista::Path;

my %generators = (
  'sitemap.xml' => 'Kalaclista::Generators::SitemapXML',
);

my $const = 'Kalaclista::Constants';

sub init {
  $const->baseURI( $ENV{'URL'} // 'https://the.kalaclista.com' );
  $const->rootdir(qr{^bin$});
}

sub main {
  my $action = shift;

  my $distdir  = $const->rootdir->child('dist/public');
  my $contents = $const->rootdir->child('content/entries');

  my $entries = Kalaclista::Entries->instance( $contents->path );

  if ( $action eq 'sitemap.xml' ) {
    my $class = $generators{$action};
    load($class);

    return $class->generate(
      path => $distdir->child('sitemap.xml'),
      src  => $entries,
    );
  }

  return 1;
}

local $@;
eval {
  init;
  main(@ARGV);
};

if ($@) {
  die "application failed: ${@}";
}

exit 0;
