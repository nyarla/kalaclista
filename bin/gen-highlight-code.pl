#!/usr/bin/env perl

use strict;
use warnings;

use HTML5::DOM;
use Path::Tiny qw(tempdir);
use YAML::Tiny;

use Kalaclista::Directory;
use Kalaclista::Entry::Content;
use Kalaclista::Sequential::Files;
use Kalaclista::Utils qw(make_fn);

my $dirs = Kalaclista::Directory->instance( build => 'resources' );
my $dist = $dirs->content_dir->child('data/highlight');
my $src  = $dirs->build_dir->child('contents');

my $parser = HTML5::DOM->new;

sub ftdetect {
  my $src = shift;

  if ( !defined $src || $src eq q{} ) {
    return q{txt};
  }

  my $has_ext = ( $src =~ s{.+?\.([^\.]+)$}{$1} );

  my $lang = lc $src;

  # shell
  if ( $lang eq q{bash} || $lang eq q{pkgbuild} ) {
    return q{bash};
  }

  if ( $lang eq q{bat} ) {
    return $lang;
  }

  if ( $lang eq q{cmd} || $lang eq q{prompt} ) {
    return q{cmd};
  }

  if ( $lang eq q{csh} ) {
    return $lang;
  }

  if ( $lang eq q{powershell} ) {
    return q{ps1};
  }

  if ( $lang eq q{sh} || $lang eq q{shell} ) {
    return q{sh};
  }

  if ( $lang eq q{zsh} ) {
    return $lang;
  }

  # lang
  if ( $lang eq q{css} ) {
    return $lang;
  }

  if ( $lang eq q{go} || $lang eq q{golang} ) {
    return q{go};
  }

  if ( $lang eq q{js} || $lang eq q{jsx} || $lang eq q{javascript} ) {
    return q{jsx};
  }

  if ( $lang eq q{pl} || $lang eq q{pm} || $lang eq q{t} || $lang eq q{perl} ) {
    return q{pl};
  }

  if ( $lang eq q{swift} ) {
    return $lang;
  }

  if ( $lang eq q{ts} || $lang eq q{tsx} || $lang eq q{typescript} ) {
    return q{tsx};
  }

  if ( $lang eq q{vim} || $lang eq q{nvim} ) {
    return q{vim};
  }

  # markup
  if ( $lang eq q{diff} ) {
    return $lang;
  }

  if ( $lang eq q{html} || $lang eq q{xhtml} ) {
    return q{html};
  }

  if ( $lang eq q{nix} ) {
    return $lang;
  }

  if ( $lang eq q{xml} ) {
    return $lang;
  }

  if ( $lang eq q{yaml} || $lang eq q{yml} ) {
    return q{yaml};
  }

  if ($has_ext) {
    return $lang;
  }

  return q{txt};
}

sub ftname {
  my $src = shift;

  if ( !defined $src ) {
    return q{tmp.txt};
  }

  if ( $src =~ m{ } ) {
    $src = ( grep { $_ =~ m{^language-} } ( split qr{ +}, $src ) )[0];
  }

  $src =~ s{^language-(?:_|-)*?}{};
  $src =~ s{\(*([^()]+)\)*}{$1};

  if ( $src eq q{make} || $src =~ m{\.mk$} || $src =~ m{^Makefile}i ) {
    return q{Makefile};
  }

  if ( $src =~ m{^dockerfile}i ) {
    return q{Dockerfile};
  }

  return "tmp." . ftdetect($src);
}

sub css {
  my $src = shift;

  $src =~ s{<!--([\s\S]+?)-->}{$1};
  $src =~ s<body \{[^}]+\}><>g;

  return $src;
}

sub handle {
  my $file = shift;
  my $path = make_fn $file->stringify, $src->stringify;

  my $content =
    Kalaclista::Entry::Content->load( src => $src->child("${path}.md") );

  my $idx = 1;
  for my $code ( $content->dom->find('pre > code')->@* ) {
    my $src  = $code->textContent;
    my $attr = $code->getAttribute('class');
    my $fn   = ftname($attr);

    my $tmp = tempdir( 'kalaclista_XXXXXXX', CLEANUP => 1 );
    my $in  = $tmp->child($fn);
    my $out = $tmp->child("result.html");

    $in->spew_utf8($src);

    system(
      qw(nvim --headless -u),
      $ENV{'HOME'} . '/.config/nvim/highlight.lua',
      '-c', "TOhtml | w! @{[ $out->stringify ]} | qa! ",
      $in->stringify,
    );

    if ( $out->is_file ) {
      my $dom   = $parser->parse( $out->slurp_utf8 );
      my $style = $dom->at('style')->innerText;
      my $code  = $dom->at('pre')->innerHTML;

      my $emit = $dist->child("${path}/${idx}.yaml");
      $emit->parent->mkpath;
      $emit->spew_utf8(
        YAML::Tiny::Dump( { style => css($style), code => $code } ) );
    }

    $idx++;
  }

  return {};
}

sub main {
  my $runner = Kalaclista::Sequential::Files->new(
    handle  => \&handle,
    threads => $ENV{'JOBS'} // (
      do {
        my $proc = `nproc --all --ignore 1`;
        chomp($proc);
        $proc;
      }
    ),
  );

  $runner->run( $src->stringify, "**", "*.md" );
}

main;
