#!/usr/bin/env perl

use v5.38;
use utf8;

use feature qw(state);

use Test2::V0;

use Markdown::Perl;

use Kalaclista::Loader::Content qw(content);
use Kalaclista::Path;

use WebSite::Context::Path qw(srcdir);

sub compile : prototype($) {
  state $compiler ||= Markdown::Perl->new(
    mode                   => 'github',
    use_extended_autolinks => !!0,
  );

  return $compiler->convert(shift);
}

sub doing {
  my $path = shift;
  print 'markdown: ', $path, "\n";

  my $src    = srcdir->child('entries/src');
  my $prefix = srcdir->child('entries/precompiled');

  my $markdown = content $src->child($path)->path;
  my $html     = compile $markdown;

  my $out = $prefix->child($path);
  $out->parent->mkpath;

  $out->emit($html);

  return 0;
}

sub testing {
  my $markdown = <<'...';
# Hi

hello, world!
...

  subtest compile => sub {
    my $html = compile $markdown;
    like $html, qr{<h1>};
    like $html, qr{<p>};
  };

  done_testing;
}

sub main { return exists $ENV{'HARNESS_ACTIVE'} ? testing(@_) : doing(@_); }

main(@ARGV);
