#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use FindBin;
use Path::Tiny;

use Kalaclista::Directory;
use Kalaclista::Page::Archive;

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
  global => {
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

my $functions = {
  'file.generate.templates' => sub {
    return [ 'assets/stylesheet.css' => 'assets/stylesheet.pl', ];
  },

  'entry.postprocess.meta' => sub {
    my $meta = shift;
    my $path = $meta->href->path;

    # fix path
    if ( $meta->slug ne q{} ) {
      my $slug = $meta->slug;
      utf8::decode($slug);
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

  'entries.archives.pages' => sub {
    my @entries = @_;

    my @pages;
    my $template = $dirs->templates_dir->child("pages/archives.pl")->stringify;

    my $current = (localtime)[5] + 1900;
    for my $year ( 2006 .. $current ) {
      for my $section (qw(posts echos)) {
        if ( $section eq q{posts} || ( $section eq q{echos} && $year >= 2018 ) )
        {
          push @pages,
            Kalaclista::Page::Archive->new(
            out      => $dirs->distdir->child("${section}/${year}/index.html"),
            template => $template,
            vars     => {
              home    => !!0,
              section => $section,
              kind    => 'archive',
              year    => $year,
              entries => [
                grep { $_->date =~ m<^$year> && $_->type eq $section } @entries
              ],
              data => $data->{$section},
            },
            );

          if ( $year eq $current ) {
            push @pages,
              Kalaclista::Page::Archive->new(
              out      => $dirs->distdir->child("${section}/index.html"),
              template => $template,
              vars     => {
                home    => !!1,
                section => $section,
                kind    => 'index',
                year    => $year,
                entries => [
                  grep { $_->date =~ m<^$year> && $_->type eq $section }
                    @entries
                ],
                data => $data->{$section},
              },
              );
          }
        }
      }
    }

    push @pages,
      Kalaclista::Page::Archive->new(
      out      => $dirs->distdir->child("notes/index.html"),
      template => $template,
      vars     => {
        home    => !!1,
        section => 'notes',
        kind    => 'index',
        entries => [ grep { $_->type eq 'notes' } @entries ],
        data    => $data->{'notes'},
      },
      );

    return @pages;
  },
};

my $config = {
  dirs      => $dirs,
  functions => $functions,
  data      => $data,
};

$config;
