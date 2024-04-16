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
          classes(qw|h-entry hentry|),
          time_( classes(qw|dt-published published|), { datetime => $date }, $date ),
          a( classes(qw|u-url url p-name entry-title title|), { href => $entry->href->to_string }, $entry->title )
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
    classes(qw|entry entry__archives h-feed hfeed|),

    header( h1( a( classes(qw|p-name fn u-url|), { href => href( "/${section}/", $baseURI ) }, $website ) ) ),

    section(
      classes(qw|entry__content|),
      p( classes(qw|p-summary site-description|), $summary ),
      hr,
      ( $section ne 'notes' ? strong("${year}年：") : () ),
      ul( { class => 'archives' }, @contents ),
      ( $section ne 'notes' ? ( hr, p( classes(qw|logs|), "過去ログ：", raw( join q{/}, @archives ) ) ) : () ),
    )
  );
}

sub render {
  my $vars = shift;
  return layout( $vars => content($vars) );
}

1;
