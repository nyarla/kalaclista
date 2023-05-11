#!/usr/bin/env perl

use strict;
use warnings;

use Kalaclista::Path;

my $rootdir = Kalaclista::Path->detect(qr{^bin$});
my $state   = $rootdir->child("public/state");
my $distdir = $rootdir->child("public/dist");

sub cache_control {
  my $path = shift;

  if ( $path =~ m{^assets/} ) {
    return 60 * 60 * 24 * 365;
  }

  if ( $path =~ m{^(?:echos|images|licenses|notes|nyarla|policies|posts)} ) {
    return 60 * 5;
  }

  if ( $path =~ m{^(?:404\.html|atom\.xml|index\.html|index\.xml|jsonfeed\.json|sitemap\.xml|.+\.js|.+\.css)$} ) {
    return 60 * 5;
  }

  return 60 * 60 * 24;
}

sub main {
  if ( -f $state->child('old.txt')->path ) {
    my %old;
    my @up;

    open( my $fh, '<', $state->child('old.txt')->path )
        or die "failed to open public/state/old.txt: ${!}";

    while ( defined( my $line = <$fh> ) ) {
      chomp($line);

      my ( $sha256sum, $path ) = split qr{ +}, $line;
      $old{$path} = $sha256sum;
    }

    close($fh) or die "failed to close public/state/old.txt: ${!}";

    open( $fh, '<', $state->child('new.txt')->path )
        or die "failed to open public/state/old.txt: ${!}";

    while ( defined( my $line = <$fh> ) ) {
      chomp($line);

      my ( $sha256sum, $path ) = split qr{ +}, $line;

      if ( !exists $old{$path} ) {
        push @up, $path;
        next;
      }

      if ( $old{$path} ne $sha256sum ) {
        push @up, $path;
      }

      delete $old{$path};
    }

    close($fh) or die "failed to close public/state/new.txt: ${!}";

    for my $file (@up) {
      $file =~ s{^\./}{};
      print "cp --cache-control @{[ cache_control($file) ]} public/dist/${file} s3://the.kalaclista.com/${file}", "\n";
    }

    for my $file ( keys %old ) {
      $file =~ s{^\./}{};
      print "rm s3://the.kalaclista.com/${file}", "\n";
    }

    exit 0;
  }

  open( my $fh, '<', $state->child('new.txt')->path )
      or die "failed to open public/state/old.txt: ${!}";
  while ( defined( my $line = <$fh> ) ) {
    chomp($line);
    my $file = ( split qr{ +}, $line )[1];
    $file =~ s{^\./}{};

    print "cp --cache-control @{[ cache_control($file) ]} public/dist/${file} s3://the.kalaclista.com/${file}", "\n";
  }

  close($fh) or die "failed to close public/state/new.txt: ${!}";
}

main;
