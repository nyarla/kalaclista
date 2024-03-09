#!/usr/bin/env perl

use v5.38;
use utf8;
use builtin qw(true);
no warnings qw(experimental);

use HTML5::DOM;
use URI::Escape::XS qw(uri_unescape);

use Kalaclista::Generators::Page;
use Kalaclista::Generators::SitemapXML;

use Kalaclista::Data::Page;
use Kalaclista::Data::WebSite;

use WebSite::Context::Path;
use WebSite::Context::URI;

use WebSite::Loader::Entry;

use WebSite::Context;

sub testing {
  return 0;
}

sub make {
  my ( $page, $tmpl, $dist ) = @_;
  my $template = "WebSite::Templates::${tmpl}";

  Kalaclista::Generators::Page->generate(
    dist     => $dist,
    template => $template,
    page     => $page,
  );
}

sub doing {
  my $action  = shift;
  my $c       = WebSite::Context->init(qr{^bin$});
  my $distdir = distdir;

  if ( $action eq 'sitemap.xml' ) {
    my @entries = entries {
      map { prop $_ } sort { $b cmp $a } @_
    };

    Kalaclista::Generators::SitemapXML->generate(
      dist    => $distdir->child('sitemap.xml'),
      entries => [@entries],
    );

    return 0;
  }

  if ( $action eq 'home' ) {
    my @entries = entries {
      sort { $b->date cmp $a->date } map { prop $_ } grep { m/^(post|echos|notes)/ } @_
    };

    my $page = Kalaclista::Data::Page->new(
      title   => $c->website->title,
      section => 'pages',
      kind    => 'home',
      entries => [ grep { defined $_ } @entries[ 0 .. 10 ] ],
      href    => href('/'),
    );

    $page->breadcrumb->push(
      label   => $c->website->label,
      title   => $c->website->title,
      summary => $c->website->summary,
      href    => href('/'),
    );

    make( $page, 'Home', $distdir->child('index.html') );

    my $feed = Kalaclista::Data::Page->new(
      title   => $c->website->title,
      summary => $c->website->summary,
      section => 'pages',
      kind    => 'home',
      entries => [ map { entry $_ } grep { defined $_ } @entries[ 0 .. 5 ] ],
      href    => href('/'),
    );

    make( $feed, 'RSS20Feed', $distdir->child('index.xml') );
    make( $feed, 'AtomFeed',  $distdir->child('atom.xml') );
    make( $feed, 'JSONFeed',  $distdir->child('jsonfeed.json') );

    $page = Kalaclista::Data::Page->new(
      title   => 'ページが見つかりません',
      section => 'pages',
      kind    => '404',
      entries => [],
    );

    make( $page, 'NotFound', $distdir->child('404.html') );

    return 0;
  }

  if ( $action eq 'index' ) {
    my $section = shift;
    my $prop    = $section eq 'notes' ? "updated" : "date";
    my @entries = entries {
      sort { $b->$prop() cmp $a->$prop() } map { prop $_ } grep { m/^$section/ } @_
    };

    return 0 if @entries == 0;

    if ( $section eq 'notes' ) {
      my $page = Kalaclista::Data::Page->new(
        title   => $c->sections->{$section}->title,
        summary => $c->sections->{$section}->summary,
        section => $section,
        kind    => 'home',
        href    => href("/${section}/"),
        entries => [@entries],
      );

      $page->breadcrumb->push(
        label   => $c->website->label,
        title   => $c->website->title,
        summary => $c->website->summary,
        href    => $c->website->href->clone,
      );

      $page->breadcrumb->push(
        label   => $c->sections->{$section}->label,
        title   => $c->sections->{$section}->title,
        summary => $c->sections->{$section}->summary,
        href    => href("/${section}/"),
      );

      make( $page, 'Index', $distdir->child("${section}/index.html") );

      my $feed = Kalaclista::Data::Page->new(
        title   => $c->sections->{$section}->title,
        summary => $c->sections->{$section}->summary,
        section => $section,
        kind    => 'home',
        entries => [ map { entry $_ } grep { defined $_ } ( sort { $b->date cmp $a->date } @entries )[ 0 .. 4 ] ],
        href    => href("/${section}/"),
      );

      make( $feed, 'RSS20Feed', $distdir->child("${section}/index.xml") );
      make( $feed, 'AtomFeed',  $distdir->child("${section}/atom.xml") );
      make( $feed, 'JSONFeed',  $distdir->child("${section}/jsonfeed.json") );
    }
    else {
      my $start = ( $entries[-1]->date =~ m{^(\d{4})} )[0];
      my $end   = ( $entries[0]->date  =~ m{^(\d{4})} )[0];

      for my $year ( $start .. $end ) {
        my @contents = grep { $_->date =~ m{^$year} } @entries;
        next if @contents == 0;

        my $page = Kalaclista::Data::Page->new(
          title   => qq<${year}年の記事一覧>,
          summary => $c->sections->{$section}->title . "の${year}年の記事一覧です",
          section => $section,
          kind    => 'index',
          entries => [@contents],
          href    => href("/${section}/${year}/"),
          vars    => { start => $start, end => $end },
        );

        $page->breadcrumb->push(
          label   => $c->website->label,
          title   => $c->website->title,
          summary => $c->website->summary,
          href    => $c->website->href->clone,
        );

        $page->breadcrumb->push(
          label   => $c->sections->{$section}->label,
          title   => $c->sections->{$section}->title,
          summary => $c->sections->{$section}->summary,
          href    => href("/${section}/"),
        );

        $page->breadcrumb->push(
          label   => $c->sections->{$section}->label,
          title   => $page->title,
          summary => $page->summary,
          href    => $page->href->clone,
        );

        make( $page, "Index", $distdir->child("${section}/${year}/index.html") );

        if ( $year == $end ) {
          my $home = Kalaclista::Data::Page->new(
            title   => $c->sections->{$section}->title,
            summary => $c->sections->{$section}->summary,
            section => $section,
            kind    => 'home',
            entries => $page->entries,
            href    => href("/${section}/"),
            vars    => { start => $start, end => $end },
          );

          $home->breadcrumb->push(
            label   => $c->website->label,
            title   => $c->website->title,
            summary => $c->website->summary,
            href    => $c->website->href->clone,
          );

          $home->breadcrumb->push(
            label   => $c->sections->{$section}->label,
            title   => $c->sections->{$section}->title,
            summary => $c->sections->{$section}->summary,
            href    => href("/${section}/"),
          );

          make( $home, 'Index', $distdir->child("${section}/index.html") );

          my $feed = Kalaclista::Data::Page->new(
            title   => $c->sections->{$section}->title,
            summary => $c->sections->{$section}->summary,
            section => $section,
            kind    => 'home',
            entries => [ map { entry $_ } grep { defined $_ } ( sort { $b->date cmp $a->date } @entries )[ 0 .. 4 ] ],
            href    => href("/${section}/"),
          );

          make( $feed, 'RSS20Feed', $distdir->child("${section}/index.xml") );
          make( $feed, 'AtomFeed',  $distdir->child("${section}/atom.xml") );
          make( $feed, 'JSONFeed',  $distdir->child("${section}/jsonfeed.json") );
        }
      }
    }

    return 0;
  }

  if ( $action eq 'permalinks' ) {
    my $year    = shift;
    my @entries = entries {
      grep { $_->date =~ m{^$year} } map { prop $_ } @_
    };

    for my $entry (@entries) {
      my $dom     = $entry->dom;
      my $summary = $entry->summary // ( ( $dom->at('.sep ~ *') // $dom->at('*:first-child') )->textContent ) . "……";

      my $page = Kalaclista::Data::Page->new(
        title   => $entry->title,
        summary => $summary,
        section => $entry->section,
        kind    => 'permalink',
        entries => [ entry $entry->meta->{'path'} ],
        href    => $entry->href,
      );

      $page->breadcrumb->push(
        label   => $c->website->label,
        title   => $c->website->title,
        summary => $c->website->summary,
        href    => $c->website->href->clone,
      );

      if ( $entry->section ne 'pages' ) {
        $page->breadcrumb->push(
          label   => $c->sections->{ $entry->section }->label,
          title   => $c->sections->{ $entry->section }->title,
          summary => $c->sections->{ $entry->section }->summary,
          href    => href("/@{[ $entry->section ]}/"),
        );
      }

      $page->breadcrumb->push(
        label   => ( $entry->section eq 'pages' ? $c->website : $c->sections->{ $entry->section } )->label,
        title   => $entry->title,
        summary => $entry->summary,
        href    => $entry->href->clone,
      );

      my $path = $entry->href->path;
      make( $page, 'Permalink', $distdir->child("${path}index.html") );
    }

    return 0;
  }
}

sub main {
  exit( !exists $ENV{'HARNESS_ACTIVE'} ? doing(@_) : testing );
}

main(@ARGV);
