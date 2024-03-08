package WebSite::Widgets::Title;

use strict;
use warnings;
use utf8;

use Exporter::Lite;

our @EXPORT = qw(banner);

use Kalaclista::HyperScript qw(nav p a img hr span br);

use WebSite::Context;
use WebSite::Context::URI qw(href);

sub breadcrumb {
  my $page = shift;
  my $c    = WebSite::Context->instance;
  my @tree;

  push @tree, a(
    { href => href('/')->to_string },
    img( { src => href('/assets/avatar.svg')->to_string, height => 50, width => 50, alt => '' } ),
    br,
    'カラクリスタ'
  );

  if ( $page->section =~ m{^(?:posts|echos|notes)$} ) {
    push @tree, span('→');
    push @tree, a( { href => href("/@{[ $page->section ]}/") }, $c->sections->{ $page->section }->label );
  }

  return @tree;
}

sub banner {
  return nav( { id => 'global' }, p( breadcrumb(shift) ) );
}

1;
