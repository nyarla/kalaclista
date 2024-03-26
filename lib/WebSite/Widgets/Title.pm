package WebSite::Widgets::Title;

use strict;
use warnings;
use utf8;

use Exporter::Lite;

our @EXPORT = qw(banner);

use Kalaclista::HyperScript qw(nav p a img hr span br classes);

use WebSite::Context;
use WebSite::Context::URI qw(href);

sub breadcrumb {
  my $page = shift;
  my $c    = WebSite::Context->instance;
  my @tree;

  push @tree, a(
    { href => href('/')->to_string },
    img(
      classes(qw|card-rounded-md inline-block box-content my-4 dark:border-gray-darker dark:bg-gray-lightest|),
      { src => href('/assets/avatar.svg')->to_string, height => 50, width => 50, alt => '' }
    ),
    br(),
    'カラクリスタ'
  );

  if ( $page->section =~ m{^(?:posts|echos|notes)$} ) {
    push @tree, span( classes(qw|inline-block mx-1|), '→' );
    push @tree, a( { href => href("/@{[ $page->section ]}/") }, $c->sections->{ $page->section }->label );
  }

  return @tree;
}

sub banner {
  return nav( classes(qw|text-center|), { id => 'global' }, p( breadcrumb(shift) ) );
}

1;
