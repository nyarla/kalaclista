#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Kalaclista::Directory;

my $dirs = Kalaclista::Directory->new(
  dist     => 'dist',
  data     => 'content/data',
  assets   => 'content/assets',
  content  => 'content/entries',
  template => 'templates',
  build    => 'resources',
);

$dirs->rootdir( $dirs->rootdir->parent );

my $functions = {
  'postprocess.entry.meta' => sub {
    my $meta = shift;
    my $path = $meta->href->path;

    # fix path
    if ( $meta->slug ne q{} ) {
      my $slug = $meta->slug;
      utf8::decode($slug);
      $path = qq(/notes/${slug});
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
};

my $config = {
  dirs      => $dirs,
  functions => $functions,

  data => {
    global => {
      title   => 'カラクリスタ',
      summary => '『輝かしい青春』なんて失かった人の Web サイトです',
      links   => {
        internals => [
          { label => '運営方針', href => '/policies/' },
          { label => '権利情報', href => '/licenses/' },
          {
            label => '検索',
            href  =>
'https://cse.google.com/cse?cx=018101178788962105892:toz3mvb2bhr#gsc.tab=0'
          },
        ],
        externals => [
          { label => 'GitHub',   href => 'https://github.com/nyarla/' },
          { label => 'Zenn.dev', href => 'https://zenn.dev/nyarla' },
          {
            label => 'Twitter',
            href  => 'https://twitter.com/kalaclista'
          },
          { label => 'note', href => 'https://note.com/kalaclista' },
          {
            label => 'Lapras',
            href  => 'https://laspras.com/public/nyarla'
          },
          { label => 'トピア', href => 'https://user.topia.tv/5R9Y' },
        ],
      },
    },

    posts => {
      label   => 'ブログ',
      title   => 'カラクリスタ・ブログ',
      summary => '『輝かしい青春』なんて失かった人のブログです',
    },

    echos => {
      label   => '日記',
      title   => 'カラクリスタ・エコーズ',
      summary => '『輝かしい青春』なんて失かった人の日記です',
    },

    notes => {
      label   => 'メモ帳',
      title   => 'カラクリスタ・ノート',
      summary => '『輝かしい青春』なんて失かった人のメモ帳です',
    },
  },
};

$config;
