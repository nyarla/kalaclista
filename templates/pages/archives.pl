use strict;
use warnings;
use utf8;

use WebSite::Widgets::Info;
use WebSite::Widgets::Menu;
use WebSite::Widgets::Profile;
use WebSite::Widgets::Title;

my $content = sub {
  my ( $vars, $baseURI ) = @_;

  my $data    = $vars->data;
  my $entries = $vars->entries;
  my $year    = ( split qr{-}, date( $entries->[0]->date ) )[0];
  my $section = $vars->section;

  my @contents;

  if ( $section eq 'notes' ) {
    my @archives;
    for my $meta ( sort { $b->lastmod cmp $a->lastmod } $entries->@* ) {
      my $date = date( $meta->date );
      push @archives,
          li(
            time_( { datetime => $date } ),
            "${date}：",
            a( { href => $meta->href->as_string, class => 'title' }, $meta->title )
          );
    }

    @contents = ul( { class => 'archives' }, @archives );
  }
  else {
    my @archives;
    for my $meta ( sort { $b->date cmp $a->date } $entries->@* ) {
      my $date = date( $meta->date );

      push @archives,
          li(
            time_( { datetime => $date }, "${date}：" ),
            a( { href => $meta->href->as_string, class => 'title' }, $meta->title )
          );
    }

    my @years;
    for my $yr ( sort { $b <=> $a } $data->{'begin'} .. ( (localtime)[5] + 1900 ) ) {
      if ( $yr == $year ) {
        push @years, strong($year);
        next;
      }

      push @years, a( { href => href( "/${section}/${yr}/", $baseURI ) }, $yr );
    }

    @contents = (
      strong("${year}年："), ul( { class => 'archives' }, @archives ),
      hr(),                p( "過去ログ：", raw( join q{ / }, @years ) )
    );
  }

  return main(
    article(
      { class => [qw(entry entry__archives)] },
      header( h1( a( { href => href( "/${section}/", $baseURI ) }, $data->{'title'} ) ) ),
      section(
        { className( 'entry', 'content' ) }, p( $data->{'summary'} ),
        hr(),                                @contents,
      ),
    )
  );
};

my $template = sub {
  my ( $vars, $baseURI ) = @_;

  return document(
    expand( 'meta/head.pl', $vars, $baseURI ),
    [
      banner($baseURI),
      profile($baseURI),
      sitemenu($baseURI),
      $content->( $vars, $baseURI ),
      siteinfo($baseURI),
    ]
  );
};

$template;
