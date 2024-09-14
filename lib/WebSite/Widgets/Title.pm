package WebSite::Widgets::Title;

use strict;
use warnings;
use utf8;

use Exporter::Lite;

our @EXPORT = qw(banner);

use Kalaclista::HyperScript qw(nav p a img hr span br classes);

use WebSite::Context::WebSite qw(section);
use WebSite::Context::URI     qw(href);

sub breadcrumb {
  my $page = shift;
  my @tree;

  push @tree, a(
    { href => href('/')->to_string },
    img(
      classes(qw|card-rounded-md inline-block box-content my-4|),
      { src => href('/assets/avatar.svg')->to_string, height => 50, width => 50, alt => '' }
    ),
    br(),
    'カラクリスタ'
  );

  if ( $page->section =~ m{^(?:posts|echos|notes)$} ) {
    my $section = section( $page->section );
    push @tree, span( classes(qw|inline-block mx-1|), '→' );
    push @tree, a( { href => $section->href, }, $section->label );
  }

  return @tree;
}

sub banner {
  return nav( classes(qw|text-center|), { id => 'global' }, p( breadcrumb(shift) ) );
}

1;
