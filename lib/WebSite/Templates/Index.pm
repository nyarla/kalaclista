package WebSite::Templates::Index;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Kalaclista::HyperScript;
use WebSite::Helper::Hyperlink qw(href);

use WebSite::Context;
use WebSite::Widgets::Layout;

use WebSite::Helper::TailwindCSS;

sub date {
  my $datetime = shift;
  my $date     = ( split qr{T}, $datetime )[0];
  my ( $year, $month, $day ) = split qr{-}, $date;

  $year  = int($year);
  $month = int($month);
  $day   = int($day);

  return qq<${year}年${month}月${day}日>;
}

sub content {
  my $page = shift;
  my $c    = WebSite::Context->instance;

  my $section = $page->section;
  my $href    = $c->baseURI->clone;
  $href->path("/$section/");

  my $data = $c->sections->{$section};

  my $header = header(
    h1(
      classes( qw(p-name), q|text-xl sm:text-3xl font-bold mt-2 mb-4| ),
      a( classes(qw(u-url)), { href => $href->to_string }, $data->title )
    ),
    p( classes(q|card before:bg-green text-xs sm:text-sm !pl-0.5|), $data->summary ),
  );

  my @contents;
  for my $entry ( $page->entries->@* ) {
    my $published = date( $entry->date );
    my $updated   = date( $entry->lastmod // $entry->date );

    my $datetime = dt(
      classes(q|text-xs !mt-6|),
      time_( { datetime => $entry->date }, $published ),
      ( $published ne $updated ? ( span( classes(q|mx-1|), '→' ), time_( { datetime => $entry->lastmod }, $updated ) ) : () ),
    );

    push @contents, $datetime;

    my $headline = dd(
      classes(q|!block !ml-0|),
      h2(
        classes(q|!text-base !mb-0 !mt-1|),
        a(
          { href => $entry->href->to_string },
          $entry->title,
        )
      ),
    );

    push @contents, $headline;
  }

  my @years;
  if ( $section ne q{notes} ) {
    my $begin = $section eq q{posts} ? 2006 : 2018;
    my $end   = (localtime)[5] + 1900;
    my $year  = ( split qr{-}, ( split( qr{T}, $page->entries->[0]->date ) )[0] )[0];

    for my $yr ( sort { $b <=> $a } $begin .. $end ) {
      my $href = $c->baseURI->clone;
      $href->path( $yr eq $end ? "/${section}/" : "/${section}/${yr}/" );
      push @years, (
        a(
          classes(q|block mr-4|),
          {
            href => $href,
            ( $yr == $year ? ( aria => { current => 'date' } ) : () ),
          },
          "${yr}年",
        )
      );
    }
  }

  return article(
    classes(qw(h-entry)),
    $header,
    section(
      classes(q|e-content mb-6|),
      dl(@contents),
    ),
    (
      @years > 0
      ? (
        p( classes(q|card before:bg-green text-xs sm:text-sm !pl-2 !mb-2|), "過去ログ" ),
        p(
          classes(q|flex flex-wrap leading-8 justify-start|),
          @years
        )
          )
      : ()
    ),
  );
}

sub render {
  my $vars = shift;
  return layout( $vars => content($vars) );
}

1;
