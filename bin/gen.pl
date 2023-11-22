#!/usr/bin/env perl

use v5.38;
use utf8;
use builtin qw(true);
no warnings qw(experimental);

BEGIN {
  if ( exists $ENV{'HARNESS_ACTIVE'} ) {
    use Test2::V0;
  }
}

use HTML5::DOM;
use URI::Escape::XS qw(uri_unescape);

my $parser = HTML5::DOM->new( { script => 1 } );

use Kalaclista::Entries;
use Kalaclista::Entry;

use Kalaclista::Generators::Page;
use Kalaclista::Generators::SitemapXML;

use Kalaclista::Path;

use Kalaclista::Data::Page;
use Kalaclista::Data::WebSite;

use WebSite::Context;

use WebSite::Extensions::AdjustHeading;
use WebSite::Extensions::Affiliate;
use WebSite::Extensions::CodeSyntax;
use WebSite::Extensions::Furigana;
use WebSite::Extensions::Picture;
use WebSite::Extensions::WebSite;

use WebSite::Helper::Hyperlink qw(href);

sub init {
  my $c = WebSite::Context->init(qr{^bin$});

  $c->website(
    label     => 'カラクリスタ',
    title     => 'カラクリスタ',
    summary   => '『輝かしい青春』なんて失かった人の Web サイトです',
    permalink => href( '/', $c->baseURI ),
  );

  $c->sections(
    posts => {
      label     => 'ブログ',
      title     => 'カラクリスタ・ブログ',
      summary   => '『輝かしい青春』なんて失かった人のブログです',
      permalink => href( '/posts/', $c->baseURI ),
    },
    echos => {
      label     => '日記',
      title     => 'カラクリスタ・エコーズ',
      summary   => '『輝かしい青春』なんて失かった人の日記です',
      permalink => href( '/echos/', $c->baseURI ),
    },
    notes => {
      label     => 'メモ帳',
      title     => 'カラクリスタ・ノート',
      summary   => '『輝かしい青春』なんて失かった人のメモ帳です',
      permalink => href( '/notes/', $c->baseURI ),
    },
  );
}

sub filter {
  my $entry = shift;
  my $c     = WebSite::Context->instance;

  return $entry->path->path !~ m{\.draft\.md$} if $c->env->production;
  return true;
}

sub fixup {
  my ( $entry, $entries ) = @_;

  my $c = WebSite::Context->instance;

  $entry->load if !$entry->loaded;

  my $prefix = $entries->path;
  my $path   = $entry->path->path;

  if ( $path =~ m{\d{6}(?:\.draft)?\.md} ) {
    my ( $section, $year, $month, $day, $time ) = $path =~ m{/(\w+)/(\d{4})/(\d{2})/(\d{2})/(\d{6})(?:\.draft)?\.md$};
    my $pathname = "${section}/${year}/${month}/${day}/${time}/";

    my $permalink = $c->baseURI->clone;
    $permalink->path($pathname);

    $entry->href($permalink);
    $entry->type($section);
  }
  elsif ( $path =~ m{/notes/[^/]+(?:\.draft)?\.md$} ) {
    my ($page) = $path =~ m{/notes/([^/]+)(?:\.draft)?\.md};

    if ( defined( my $slug = $entry->slug ) ) {
      utf8::decode($slug);
      $slug =~ s{ }{-}g;
      $page = $slug;
    }

    my $permalink = $c->baseURI->clone;
    $permalink->path("/notes/${page}/");

    $entry->href($permalink);
    $entry->type('notes');
  }
  else {
    my $pathname = $path;
    $path =~ s{$prefix/}{};
    $path =~ s{(?:\.draft)?\.md$}{/};

    my $permalink = $c->baseURI->clone;
    $permalink->path($path);

    $entry->href($permalink);
    $entry->type('pages');
  }

  $entry->add_transformer(
    sub {
      my $entry = shift;
      my $path  = $entry->path->path;
      $path =~ s{entries/src}{entries/precompiled};
      my $precompiled = Kalaclista::Path->new( path => $path )->get;
      utf8::decode($precompiled);

      $entry->dom($precompiled);

      return $entry;
    }
  );
  $entry->add_transformer( sub { WebSite::Extensions::AdjustHeading->transform(@_) } );
  $entry->add_transformer( sub { WebSite::Extensions::CodeSyntax->transform(@_) } );
  $entry->add_transformer( sub { WebSite::Extensions::Picture->transform( @_, [ 640, 1280 ] ) } );
  $entry->add_transformer( sub { WebSite::Extensions::Furigana->transform(@_) } );
  $entry->add_transformer( sub { WebSite::Extensions::WebSite->transform(@_) } );
  $entry->add_transformer( sub { WebSite::Extensions::Affiliate->transform(@_) } );

  return $entry;
}

sub testing {
  subtest init => sub {
    local $ENV{'KALACLISTA_ENV'} = 'production';
    init;

    subtest path => sub {
      my $path  = WebSite::Context->instance->dirs->rootdir->path;
      my $check = Kalaclista::Path->detect(qr{^bin$})->path;

      is $path, $check;
    };

    subtest website => sub {
      my $website = WebSite::Context->instance->website;

      is $website->label,     'カラクリスタ';
      is $website->title,     'カラクリスタ';
      is $website->summary,   '『輝かしい青春』なんて失かった人の Web サイトです';
      is $website->permalink, 'https://the.kalaclista.com/';
    };

    subtest sections => sub {
      subtest posts => sub {
        my $website = WebSite::Context->instance->sections->{'posts'};

        is $website->label,     'ブログ';
        is $website->title,     'カラクリスタ・ブログ';
        is $website->summary,   '『輝かしい青春』なんて失かった人のブログです';
        is $website->permalink, 'https://the.kalaclista.com/posts/';
      };

      subtest echos => sub {
        my $website = WebSite::Context->instance->sections->{'echos'};

        is $website->label,     '日記';
        is $website->title,     'カラクリスタ・エコーズ';
        is $website->summary,   '『輝かしい青春』なんて失かった人の日記です';
        is $website->permalink, 'https://the.kalaclista.com/echos/';
      };

      subtest notes => sub {
        my $website = WebSite::Context->instance->sections->{'notes'};

        is $website->label,     'メモ帳';
        is $website->title,     'カラクリスタ・ノート';
        is $website->summary,   '『輝かしい青春』なんて失かった人のメモ帳です';
        is $website->permalink, 'https://the.kalaclista.com/notes/';
      };
    };
  };

  subtest filter => sub {
    subtest development => sub {
      local $ENV{'KALACLISTA_ENV'} = 'development';
      init;

      my $entry = Kalaclista::Entry->new( path => 'test.md' );
      my $draft = Kalaclista::Entry->new( path => 'test.draft.md' );

      ok !WebSite::Context->instance->env->production;
      ok filter($entry);
      ok filter($draft);
    };

    subtest production => sub {
      local $ENV{'KALACLISTA_ENV'} = 'production';
      init;

      my $entry = Kalaclista::Entry->new( path => 'test.md' );
      my $draft = Kalaclista::Entry->new( path => 'test.draft.md' );

      ok !!WebSite::Context->instance->env->production;
      ok filter($entry);
      ok !filter($draft);
    };
  };

  if ( $ENV{'KALACLISTA_ENV'} eq 'production' ) {
    subtest fixup => sub {
      init;

      my $c       = WebSite::Context->instance;
      my $entries = $c->entries;

      subtest posts => sub {
        my $entry = Kalaclista::Entry->new( path => $entries->child('posts/2023/10/06/155859.md') );

        fixup( $entry, $entries );

        is $entry->href->to_string, 'https://the.kalaclista.com/posts/2023/10/06/155859/';
        is $entry->type,            'posts';
      };

      subtest echos => sub {
        my $entry = Kalaclista::Entry->new( path => $entries->child('echos/2023/09/02/153122.md') );

        fixup( $entry, $entries );

        is $entry->href->to_string, 'https://the.kalaclista.com/echos/2023/09/02/153122/';
        is $entry->type,            'echos';
      };

      subtest notes => sub {
        my $entry = Kalaclista::Entry->new( path => $entries->child("notes/にゃるら-is-not-にゃるら.md") );

        fixup( $entry, $entries );

        is $entry->href->to_string, 'https://the.kalaclista.com/notes/nyarla-is-not-nyalra/';
        is $entry->type,            'notes';
      };

      subtest pages => sub {
        my $entry = Kalaclista::Entry->new( path => $entries->child('nyarla.md') );

        fixup( $entry, $entries );

        is $entry->href->to_string, 'https://the.kalaclista.com/nyarla/';
        is $entry->type,            'pages';
      };
    };

    subtest doing => sub {
      init;

      my $c = WebSite::Context->instance;

      subtest sitemap_xml => sub {
        doing('sitemap.xml');

        ok -e $c->distdir->child('sitemap.xml')->path;
      };

      subtest home => sub {
        doing('home');

        ok -e $c->distdir->child('index.html')->path;
        ok -e $c->distdir->child('index.xml')->path;
        ok -e $c->distdir->child('atom.xml')->path;
        ok -e $c->distdir->child('jsonfeed.json')->path;
      };

      subtest index => sub {
        subtest notes => sub {
          doing(qw(index notes));

          ok -e $c->distdir->child('notes/index.html')->path;
          ok -e $c->distdir->child('notes/index.xml')->path;
          ok -e $c->distdir->child('notes/atom.xml')->path;
          ok -e $c->distdir->child('notes/jsonfeed.json')->path;
        };

        subtest posts => sub {
          doing(qw(index posts));

          ok -e $c->distdir->child('posts/index.html')->path;
          ok -e $c->distdir->child('posts/index.xml')->path;
          ok -e $c->distdir->child('posts/atom.xml')->path;
          ok -e $c->distdir->child('posts/jsonfeed.json')->path;
        };

        subtest echos => sub {
          doing(qw(index echos));

          ok -e $c->distdir->child('echos/index.html')->path;
          ok -e $c->distdir->child('echos/index.xml')->path;
          ok -e $c->distdir->child('echos/atom.xml')->path;
          ok -e $c->distdir->child('echos/jsonfeed.json')->path;
        };
      };
    };
  }

  done_testing;

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
  init;

  my $action = shift;
  my $c      = WebSite::Context->instance;

  my $contents = $c->entries;
  my $datadir  = $c->datadir;
  my $distdir  = $c->distdir;
  my $srcdir   = $c->srcdir;

  my @options = (
    $contents->path,
    fixup => sub { fixup( $_[0], $contents ) },
  );

  if ( $action eq 'sitemap.xml' ) {
    my $entries = Kalaclista::Entries->lookup(
      @options,
      filter => sub { -f $_[0] },
      sort   => sub { $_[1]->path->path cmp $_[0]->path->path },
    );

    Kalaclista::Generators::SitemapXML->generate(
      dist    => $distdir->child('sitemap.xml'),
      entries => $entries,
    );

    return 0;
  }

  if ( $action eq 'home' ) {
    my $entries = Kalaclista::Entries->lookup(
      @options,
      sort   => sub { $_[1]->date cmp $_[0]->date },
      filter => sub { -f $_[0] && $_[0] =~ m{/(posts|echos|notes)/} },
    );

    my $page = Kalaclista::Data::Page->new(
      title   => $c->website->title,
      section => 'pages',
      kind    => 'home',
      entries => [ grep { defined $_ } @{$entries}[ 0 .. 10 ] ],
      href    => URI::Fast->new( href( '/', $c->baseURI ) ),
    );

    $page->breadcrumb->push(
      title     => $c->website->title,
      permalink => $c->website->permalink,
    );

    make( $page, 'Home', $distdir->child('index.html') );

    my @entries =
        map { $_->transform; $_ } grep { defined $_ } ( $entries->@* )[ 0 .. 4 ];

    my $feed = Kalaclista::Data::Page->new(
      title   => $c->website->title,
      summary => $c->website->summary,
      section => 'pages',
      kind    => 'home',
      entries => [@entries],
      href    => URI::Fast->new( href( "/", $c->baseURI ) ),
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
    my $entries = Kalaclista::Entries->lookup(
      @options,
      filter => sub { -f $_[0] && $_[0] =~ m{/$section/} },
      sort   => sub { $_[1]->$prop() cmp $_[0]->$prop() },
    );

    return 0 if $entries->@* == 0;

    if ( $section eq 'notes' ) {
      my $page = Kalaclista::Data::Page->new(
        title   => $c->sections->{$section}->title,
        summary => $c->sections->{$section}->summary,
        section => $section,
        kind    => 'index',
        href    => URI::Fast->new( href( "/${section}/", $c->baseURI ) ),
        entries => $entries,
      );

      $page->breadcrumb->push(
        title     => $c->website->title,
        permalink => $c->baseURI->to_string,
      );

      $page->breadcrumb->push(
        title     => $c->sections->{$section}->title,
        permalink => href( "/${section}/", $c->baseURI ),
      );

      make( $page, 'Index', $distdir->child("${section}/index.html") );

      my $feed = Kalaclista::Data::Page->new(
        title   => $c->sections->{$section}->title,
        summary => $c->sections->{$section}->summary,
        section => $section,
        kind    => 'home',
        entries => [ ( sort { $b->date cmp $a->date } grep { defined $_ } $entries->@* )[ 0 .. 4 ] ],
        href    => URI::Fast->new( href( "/${section}/", $c->baseURI ) ),
      );

      $_->transform for grep { defined $_ } $feed->entries->@*;

      make( $feed, 'RSS20Feed', $distdir->child("${section}/index.xml") );
      make( $feed, 'AtomFeed',  $distdir->child("${section}/atom.xml") );
      make( $feed, 'JSONFeed',  $distdir->child("${section}/jsonfeed.json") );
    }
    else {
      my $start = ( $entries->[-1]->date =~ m{^(\d{4})} )[0];
      my $end   = ( $entries->[0]->date  =~ m{^(\d{4})} )[0];

      for my $year ( $start .. $end ) {
        my @contents = grep { $_->date =~ m{^$year} } $entries->@*;
        next if @contents == 0;

        my $page = Kalaclista::Data::Page->new(
          title   => qq<${year}年の記事一覧>,
          summary => $c->sections->{$section}->title . "の${year}年の記事一覧です",
          section => $section,
          kind    => 'index',
          entries => [@contents],
          href    => URI::Fast->new( href( "/${section}/${year}/", $c->baseURI ) ),
          vars    => { start => $start, end => $end },
        );

        $page->breadcrumb->push(
          title     => $c->website->title,
          permalink => $c->baseURI->to_string,
        );

        $page->breadcrumb->push(
          title     => $c->sections->{$section}->title,
          permalink => href( "/${section}/", $c->baseURI ),
        );

        $page->breadcrumb->push(
          title     => $page->title,
          permalink => $page->href->to_string,
        );

        make( $page, "Index", $distdir->child("${section}/${year}/index.html") );

        if ( $year == $end ) {
          my $home = Kalaclista::Data::Page->new(
            title   => $c->sections->{$section}->title,
            summary => $c->sections->{$section}->summary,
            section => $section,
            kind    => 'home',
            entries => $page->entries,
            href    => URI::Fast->new( href( "/${section}/", $c->baseURI ) ),
            vars    => { start => $start, end => $end },
          );

          $home->breadcrumb->push(
            title     => $c->website->title,
            permalink => $c->baseURI->to_string,
          );

          $home->breadcrumb->push(
            title     => $c->sections->{$section}->title,
            permalink => href( "/${section}/", $c->baseURI ),
          );

          make( $home, 'Index', $distdir->child("${section}/index.html") );

          my $feed = Kalaclista::Data::Page->new(
            title   => $c->sections->{$section}->title,
            summary => $c->sections->{$section}->summary,
            section => $section,
            kind    => 'home',
            entries => [ grep { defined $_ } ( sort { $b->date cmp $a->date } @contents )[ 0 .. 4 ] ],
            href    => URI::Fast->new( href( "/${section}/", $c->baseURI ) ),
          );

          $_->transform for grep { defined $_ } $feed->entries->@*;

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
    my $entries = Kalaclista::Entries->lookup(
      @options,
    );

    my @entries = grep { $_->date =~ m{^$year} } $entries->@*;
    for my $entry (@entries) {
      $entry->transform;

      my $dom     = $entry->dom;
      my $summary = $entry->summary // ( ( $dom->at('.sep ~ *') // $dom->at('*:first-child') )->textContent ) . "……";

      my $page = Kalaclista::Data::Page->new(
        title   => $entry->title,
        summary => $summary,
        section => $entry->type,
        kind    => 'permalink',
        entries => [$entry],
        href    => $entry->href,
      );

      $page->breadcrumb->push(
        title     => $c->website->title,
        permalink => $c->baseURI->to_string,
      );

      if ( $entry->type ne 'pages' ) {
        $page->breadcrumb->push(
          title     => $c->sections->{ $entry->type }->title,
          permalink => $c->sections->{ $entry->type }->permalink,
        );
      }

      $page->breadcrumb->push(
        title     => $entry->title,
        permalink => $entry->href->to_string,
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
