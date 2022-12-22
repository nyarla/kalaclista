#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use HTML5::DOM;
use URI::Fast;
use URI::Escape qw(uri_unescape);
use YAML::XS;

BEGIN {
  use Kalaclista::Constants;
  Kalaclista::Constants->baseURI('https://the.kalaclista.com');
}

use Kalaclista::Path;
use Kalaclista::Entry;
use Kalaclista::Entries;

use Kalaclista::Utils qw(make_fn);

my $content = Kalaclista::Path->detect(qr{^bin$})->child('content');
my $dist    = $content->child('data/highlight');
my $src     = $content->child('entries');

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
  my $entry = shift;
  my $path  = $entry->href->path;
  $path = uri_unescape($path);

  my $idx = 1;
  for my $code ( $entry->dom->find('pre > code')->@* ) {
    my $src  = $code->textContent;
    my $attr = $code->getAttribute('class');
    my $fn   = ftname($attr);

    my $tmp = Kalaclista::Path->tempdir;
    my $in  = $tmp->child($fn);
    my $out = $tmp->child('result.html');

    $in->emit($src);

    system(
      qw(nvim --headless -u),
      $ENV{'HOME'} . '/.config/nvim/highlight.lua',
      '-c', "TOhtml | w! @{[ $out->path ]} | qa! ",
      $in->path,
    );

    if ( -f $out->path ) {
      my $dom   = $parser->parse( $out->get );
      my $style = $dom->at('style')->innerText;
      my $code  = $dom->at('pre')->innerHTML;

      utf8::decode($code);

      my $emit = $dist->child("${path}/${idx}.yaml");
      $emit->parent->mkpath;
      $emit->emit( YAML::XS::Dump( { code => $code, style => css($style) } ) );
    }

    $idx++;
  }

  return {};
}

sub main {
  my $entries = Kalaclista::Entries->instance(
    $src->path,
  );

  handle($_) for $entries->entries->@*;
}

main;
