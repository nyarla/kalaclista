#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use FindBin;
use URI;
use Path::Tiny;
use URI::Escape qw(uri_unescape);

use Kalaclista::Directory;
use Kalaclista::Page;
use Kalaclista::Variables;

require Kalaclista::Template;

my $root = path($FindBin::Bin);
do {
  if ( $root->child('app')->realpath->is_dir ) {
    goto NEXT;
  }
} while ( defined( $root = $root->parent ) );

NEXT:

my $dirs = Kalaclista::Directory->instance(
  root     => $root,
  dist     => 'dist',
  data     => 'content/data',
  assets   => 'content/assets',
  content  => 'content/entries',
  template => 'templates',
  build    => 'resources',
);

my $baseURL = URI->new( $ENV{'URL'} // q{https://the.kalaclista.com} );

my $data = {
  pages => {
    label   => 'カラクリスタ',
    title   => 'カラクリスタ',
    summary => '『輝かしい青春』なんて失かった人の Web サイトです。',
  },

  posts => {
    label   => 'ブログ',
    title   => 'カラクリスタ・ブログ',
    summary => '『輝かしい青春』なんて失かった人のブログです。',
    begin   => 2006,
  },

  echos => {
    label   => '日記',
    title   => 'カラクリスタ・エコーズ',
    summary => '『輝かしい青春』なんて失かった人の日記です。',
    begin   => 2018,
  },

  notes => {
    label   => 'メモ帳',
    title   => 'カラクリスタ・ノート',
    summary => '『輝かしい青春』なんて失かった人のメモ帳です。',
  },
};

my @extensions = map {
  Kalaclista::Template::load( $dirs->templates_dir->child($_)->stringify )
  } qw(
  extensions/affiliate.pl
  extensions/highlight.pl
  extensions/images.pl
  extensions/ruby.pl
  );

my $fixup = {
  'Kalaclista::Entry::Meta' => sub {
    my $meta = shift;
    my $path = $meta->href->path;

    # fix path
    if ( $meta->slug ne q{} ) {
      my $slug = $meta->slug;
      utf8::decode($slug);
      $slug =~ s{ }{-}g;
      $path = qq(/notes/${slug}/);
    }

    if ( $path =~ m{/index} ) {
      $path =~ s{/index$}{/};
    }

    $meta->href->path($path);

    if ( $path =~ m{^/(posts|notes|echos)/} ) {
      $meta->type($1);
    }
    else {
      $meta->type('pages');
    }
  },

  'Kalaclista::Entry::Content' => sub {
    my $content = shift;
    my $meta    = shift;

    for my $extension (@extensions) {
      my $transformer = $extension->($meta);
      $content->transform($transformer);
    }
  },
};

my $call = {
  fixup => sub {
    my $object = shift;
    my @args   = @_;
    my $class  = ref $object;
    if ( exists $fixup->{$class} ) {
      $fixup->{$class}->( $object, @args );
    }
  },
};

my $query = {
  assets => sub {
    return ( 'assets/stylesheet.css' => 'assets/stylesheet.pl', );
  },

  page => sub {
    my $content = shift;
    my $meta    = shift;

    my $path = uri_unescape( $meta->href->path );

    my $description = $content->dom->at('*:first-child')->textContent . '……';

    my $vars = Kalaclista::Variables->new(
      title       => $meta->title,
      website     => $data->{ $meta->type }->{'title'},
      description => $description,
      section     => $meta->type,
      kind        => 'permalink',
      data        => $data->{ $meta->type },
      entries     => [ [ $meta, $content ], ],
      href        => $meta->href->as_string,
      breadcrumb  => [
        {
          name => 'カラクリスタ',
          href => do { my $u = $baseURL->clone; $u->path('/'); $u->as_string },
        },
        {
          name => $data->{ $meta->type }->{'title'},
          href => do {
            my $u = $baseURL->clone;
            $u->path("/@{[ $meta->type ]}/");
            $u->as_string;
          },
        },
        {
          name => $meta->title,
          href => $meta->href->as_string,
        }
      ],
    );

    my $page = Kalaclista::Page->new(
      dist     => $dirs->distdir->child("${path}/index.html"),
      template => $dirs->templates_dir->child('pages/permalink.pl')->stringify,
      vars     => $vars,
    );

    return $page;
  },

  archives => sub {
    my @entries  = @_;
    my $template = $dirs->templates_dir->child('pages/archives.pl')->stringify;
    my $current  = (localtime)[5] + 1900;

    my @pages;

    for my $year ( 2006 .. $current ) {
      for my $section (qw(posts echos)) {
        if ( $section eq q{posts} || $year >= 2018 ) {
          my $title       = sprintf "%04d年の記事一覧", $year;
          my $website     = $data->{$section}->{'title'};
          my $description = "${website}の${title}です";

          my $vars = Kalaclista::Variables->new(
            title       => $title,
            website     => $data->{$section}->{'title'},
            description => $description,
            section     => $section,
            kind        => 'home',
            data        => $data->{$section},
            entries     => [
              map  { [$_] }
              grep { $_->date =~ m{^$year} && $_->type eq $section } @entries
            ],
            href => do {
              my $u = $baseURL->clone;
              $u->path("/$section/${year}/");
              $u->as_string;
            },
          );

          $vars->breadcrumb(
            [
              {
                name => 'カラクリスタ',
                href =>
                  do { my $u = $baseURL->clone; $u->path("/"); $u->as_string }
              },
              {
                name => $vars->website,
                href => do {
                  my $u = $baseURL->clone;
                  $u->path("/${section}/");
                  $u->as_string;
                },
              },
              {
                name => $vars->title,
                href => $vars->href,
              }
            ]
          );

          push @pages,
            Kalaclista::Page->new(
            dist     => $dirs->distdir->child("${section}/${year}/index.html"),
            template => $template,
            vars     => $vars,
            );
        }

        if ( $current eq $year ) {
          my $vars = Kalaclista::Variables->new(
            title       => $data->{$section}->{'title'},
            website     => $data->{$section}->{'title'},
            description => $data->{$section}->{'summary'},
            section     => $section,
            kind        => 'archive',
            data        => $data->{$section},
            entries     => [
              map  { [$_] }
              grep { $_->date =~ m{^$year} && $_->type eq $section } @entries
            ],
            href => do {
              my $u = $baseURL->clone;
              $u->path("/${section}/");
              $u->as_string;
            },
          );

          $vars->breadcrumb(
            [
              {
                name => 'カラクリスタ',
                href =>
                  do { my $u = $baseURL->clone; $u->path("/"); $u->as_string }
              },
              {
                name => $vars->website,
                href => do {
                  my $u = $baseURL->clone;
                  $u->path("/${section}/");
                  $u->as_string;
                },
              }
            ]
          );

          push @pages,
            Kalaclista::Page->new(
            dist     => $dirs->distdir->child("${section}/index.html"),
            template => $template,
            vars     => $vars,
            );

        }
      }
    }

    my $vars = Kalaclista::Variables->new(
      title       => $data->{'notes'}->{'title'},
      website     => $data->{'notes'}->{'title'},
      description => $data->{'notes'}->{'summary'},
      section     => 'notes',
      kind        => 'archive',
      data        => $data->{'notes'},
      entries     => [ map { [$_] } grep { $_->type eq 'notes' } @entries ],
      href        => do {
        my $u = $baseURL->clone;
        $u->path('/notes/');
        $u->as_string;
      },
      breadcrumb => do {
        [
          {
            name => 'カラクリスタ',
            href => do {
              my $u = $baseURL->clone;
              $u->path("/");
              $u->as_string;
            },
          },
          {
            name => $data->{'notes'}->{'title'},
            href => do {
              my $u = $baseURL->clone;
              $u->path("/notes/");
              $u->as_string;
            },
          }
        ];
      },
    );

    push @pages,
      Kalaclista::Page->new(
      dist     => $dirs->distdir->child("notes/index.html"),
      template => $template,
      vars     => $vars,
      );

    return @pages;
  },
};

my $config = {
  call  => $call,
  data  => $data,
  dirs  => $dirs,
  query => $query,
};

$config;
