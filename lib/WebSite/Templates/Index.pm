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
  my $vars = shift;
  my $c    = WebSite::Context->instance;

  my $section = $vars->section;
  my $baseURI = $c->baseURI;
  my $data    = $vars->contains->{$section};
  my $website = $data->{'website'};
  my $summary = $data->{'description'};
  my $year    = ( split q{-}, date( $vars->entries->[0]->date ) )[0];

  my @contents;
  my @archives;
  my $prop = $section eq 'notes' ? 'lastmod' : 'date';

  for my $entry ( sort { $b->$prop cmp $a->$prop } $vars->entries->@* ) {
    my $date = date( $entry->date );
    push @contents,
        li(
          time_( { datetime => $date }, "${date}：" ),
          a( { href => $entry->href->to_string, class => 'title' }, $entry->title )
        );
  }

  if ( $section ne 'notes' ) {
    for my $yr ( sort { $b <=> $a } $vars->begin .. $vars->end ) {
      if ( $yr == $year ) {
        push @archives, strong($year);
        next;
      }

      push @archives, a( { href => href( "/${section}/${yr}/", $baseURI ) }, $yr );
    }
  }

  return article(
    { class => [qw( entry entry__archives )] },

    header( h1( a( { href => href( "/${section}/", $baseURI ) }, $website ) ) ),

    section(
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
