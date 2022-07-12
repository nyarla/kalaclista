#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use FindBin;
use Path::Tiny;

use Kalaclista::Directory;
use Kalaclista::Page;

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
  extensions/images.pl
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

    # for my $extension (@extensions) {
    #   my $transformer = $extension->($meta);
    #   $content->tranform($transformer);
    # }
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

  permalink => sub {
    my $content = shift;
    my $meta    = shift;

    my $path = uri_unescape( $meta->href->path );

    my $page = Kalaclista::Page->new(
      dist     => $dirs->distdir->child("${path}/index.html"),
      template => $dirs->templates_dir->child('pages/permalink.pl')->stringify,
      vars     => {
        section => $meta->type,
        data    => $data->{ $meta->type },
        meta    => $meta,
        content => $content,
      },
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
          push @pages,
            Kalaclista::Page->new(
            dist     => $dirs->distdir->child("${section}/${year}/index.html"),
            template => $template,
            vars     => {
              home    => !!0,
              section => $section,
              kind    => 'archive',
              year    => $year,
              entries => [
                grep { $_->date =~ m(^$year) && $_->type eq $section } @entries
              ],
              data => $data->{$section},
            }
            );
        }

        if ( $current eq $year ) {
          push @pages,
            Kalaclista::Page->new(
            dist     => $dirs->distdir->child("${section}/${year}/index.html"),
            template => $template,
            vars     => {
              home    => !!1,
              section => $section,
              kind    => 'archive',
              year    => $year,
              entries => [
                grep { $_->date =~ m(^$year) && $_->type eq $section } @entries
              ],
              data => $data->{$section},
            }
            );
        }
      }
    }

    push @pages,
      Kalaclista::Page->new(
      dist     => $dirs->distdir->child("notes/index.html"),
      template => $template,
      vars     => {
        home    => !!1,
        section => 'note',
        kind    => 'archive',
        entries => [ grep { $_->type eq 'notes' } @entries ],
        data    => $data->{'notes'},
      },
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
