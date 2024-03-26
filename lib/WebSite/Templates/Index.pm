package WebSite::Templates::Index;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Kalaclista::HyperScript;
use WebSite::Helper::Hyperlink qw(href);

use WebSite::Context;
use WebSite::Widgets::Layout;

sub date {
  return ( split qr{T}, shift )[0];
}

sub content {
  my $page = shift;
  my $c    = WebSite::Context->instance;

  my $section = $page->section;
  my $baseURI = $c->baseURI;
  my $data    = $c->sections->{$section};
  my $website = $data->title;
  my $summary = $data->summary;
  my $year    = ( split qr{-}, date( $page->entries->[0]->date ) )[0];

  my @contents;
  my @archives;
  my $prop = $section eq 'notes' ? 'updated' : 'date';

  for my $entry ( $page->entries->@* ) {
    my $date = date( $entry->date );
    push @contents,
        li(
          time_( { datetime => $date }, $date ),
          a( { href => $entry->href->to_string, class => 'title' }, $entry->title )
        );
  }

  if ( $section ne 'notes' ) {
    for my $yr ( sort { $b <=> $a } $page->vars->{'start'} .. $page->vars->{'end'} ) {
      if ( $yr == $year ) {
        push @archives, strong($year);
        next;
      }

      push @archives, a( { href => href( "/${section}/${yr}/", $baseURI ) }, $yr );
    }
  }

  return article(
    classes(qw|entry entry__archives|),

    header( h1( a( { href => href( "/${section}/", $baseURI ) }, $website ) ) ),

    section(
      classes(qw|entry__content|),
      { class => 'entry__content' },
      p($summary),
      hr,
      ( $section ne 'notes' ? strong("${year}年：") : () ),
      ul( { class => 'archives' }, @contents ),
      ( $section ne 'notes' ? ( hr, p( { class => 'logs' }, "過去ログ：", raw( join q{/}, @archives ) ) ) : () ),
    )
  );
}

sub render {
  my $vars = shift;
  return layout( $vars => content($vars) );
}

1;
