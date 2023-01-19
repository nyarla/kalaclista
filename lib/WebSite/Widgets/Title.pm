package WebSite::Widgets::Title;

use strict;
use warnings;
use utf8;

use Exporter::Lite;

our @EXPORT = qw(banner);

use Kalaclista::HyperScript qw(header p a img hr span);

use WebSite::Helper::Hyperlink qw(hyperlink href);
use Kalaclista::Constants;

sub breadcrumb {
  my $vars    = shift;
  my $baseURI = shift;

  my @tree;

  push @tree, a(
    { href => href( '/', $baseURI ) },
    img( { src => href( '/assets/avatar.svg', $baseURI ), height => 50, width => 50 } ),
    'カラクリスタ'
  );

  if ( $vars->section =~ m{^(?:posts|echos|notes)$} ) {
    push @tree, span('→');
    push @tree, a( { href => href( $vars->section . '/', $baseURI ) }, $vars->contains->{ $vars->section }->{'label'} );
  }

  return @tree;
}

sub banner {
  my $vars    = shift;
  my $baseURI = Kalaclista::Constants->baseURI;

  return header(
    { id => 'global' },
    p( breadcrumb( $vars, $baseURI ) ),
    hr,
  );
}

1;
