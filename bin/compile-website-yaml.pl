#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

BEGIN {
  if ( exists $ENV{'HARNESS_ACTIVE'} ) {
    use Test2::V0;
  }
}

use feature qw(state);

use Text::CSV qw(csv);
use YAML::XS  qw(DumpFile);
use WebSite::Context;

sub c { state $c ||= WebSite::Context->init(qr{^bin$}); $c }

sub doing {
  my $src  = c->data("website/src.csv")->path;
  my $yaml = c->cache("website/src.yaml");

  my $aoa = csv( in => $src, encoding => 'UTF-8' );
  shift $aoa->@*;

  my $data = {};
  for my $line ( $aoa->@* ) {
    my ( $updated, $label, $summary, $link, $permalink, $status, $lock, $gone, $action ) = $line->@*;
    my $payload = {
      title     => $label,
      summary   => $summary,
      link      => $link,
      permalink => $permalink,
      status    => int($status),
      lock      => ( $lock eq 'TRUE' ),
      gone      => ( $gone eq 'TRUE' ),
      updated   => int($updated),
      action    => ( $action eq 'TRUE' ),
    };

    $data->{$link} = $payload;
  }

  $yaml->parent->mkpath;
  YAML::XS::DumpFile( $yaml->path, $data );

  return 0;
}

sub testing {
  ok try_ok( sub { doing } );
  ok -e c->cache('website/src.yaml')->path;

  done_testing;

  return 0;
}

sub main {
  exit( !exists $ENV{'HARNESS_ACTIVE'} ? doing(@ARGV) : testing );
}

main;
