#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use feature qw(state);

BEGIN {
  if ( exists $ENV{'HARNESS_ACTIVE'} ) {
    use Test2::V0;
  }
}

use HTML5::DOM;
use URI::Fast;
use URI::Escape::XS qw(uri_unescape);

use File::Basename qw(fileparse);

use YAML::XS;

use WebSite::Context;
use Kalaclista::Files;
use Kalaclista::Path;

sub c      { state $c ||= WebSite::Context->init(qr{^bin$}); $c }
sub parser { state $p ||= HTML5::DOM->new;                   $p }

sub splitlang {
  my $ftfn = shift;

  $ftfn =~ s{^language-[\-_]*}{};

  # workaround for current entries
  $ftfn =~ s{[(]}{};
  $ftfn =~ s{[)]}{};

  if ( $ftfn =~ m{:} ) {
    my ( $ft, $fn ) = $ftfn =~ m{^([^:]+):(.+)$};
    return ( $ft, ( fileparse($fn) )[0] );
  }

  if ( $ftfn =~ m{[/\.]} ) {
    return ( q{}, ( fileparse($ftfn) )[0] );

  }

  return ( $ftfn, q{} );
}

sub filetype {
  state $matchers ||= {
    lang => {
      'bash'            => qr{^bash|shell|pkgbuild|xinitrc$}i,
      'csh'             => qr{^csh$}i,
      'css'             => qr{^css$}i,
      'diff'            => qr{^(?:diff|patch)$}i,
      'dockerfile'      => qr{^dockerfile$}i,
      'dosbatch'        => qr{^(?:bat|cmd|prompt)$}i,
      'dosini'          => qr{^ini$}i,
      'go'              => qr{^go$}i,
      'html'            => qr{^(?:html|xhtml)$}i,
      'javascript'      => qr{^(?:javascript|js)$}i,
      'javascriptreact' => qr{^jsx$}i,
      'json'            => qr{^json$}i,
      'lua'             => qr{^lua$},
      'make'            => qr{^(?:make|makefile)$}i,
      'nix'             => qr{^nix$}i,
      'perl'            => qr{^perl$}i,
      'ps1'             => qr{^(?:powershell|ps1)$}i,
      'registry'        => qr{^(?:reg|registry)$}i,
      'ruby'            => qr{^ruby$}i,
      'scss'            => qr{^scss$},
      'sh'              => qr{^(?:apkbuild|sh)$}i,
      'swift'           => qr{^swift$}i,
      'toml'            => qr{^toml$}i,
      'typescript'      => qr{^ts$}i,
      'typescriptreact' => qr{^tsx$}i,
      'vim'             => qr{^(?:nvim|vim)$}i,
      'xdefaults'       => qr{^xresources$}i,
      'xf86config'      => qr{^xorg$}i,
      'xml'             => qr{^xml$}i,
      'yaml'            => qr{^(?:yaml)$}i,
      'zsh'             => qr{^zsh$}i,
    },
    fn => {
      'bash'            => qr{\.sh$|^pkgbuild$|^.xinitrc$}i,
      'csh'             => qr{\.csh$}i,
      'css'             => qr{\.css$}i,
      'diff'            => qr{\.(?:diff|patch)$}i,
      'dockerfile'      => qr{^dockerfile}i,
      'dosbatch'        => qr{\.(?:bat|cmd)$}i,
      'dosini'          => qr{\.ini$},
      'go'              => qr{\.go$}i,
      'html'            => qr{\.x?html?$}i,
      'javascript'      => qr{\.js$}i,
      'javascriptreact' => qr{\.jsx$}i,
      'json'            => qr{\.json$}i,
      'make'            => qr{^makefile$|\.mk$}i,
      'nix'             => qr{\.nix$}i,
      'perl'            => qr{\.(?:pl|pm|t)$}i,
      'ps1'             => qr{\.ps1$}i,
      'registry'        => qr{\.reg$}i,
      'scss'            => qr{\.scss$}i,
      'sh'              => qr{\.sh$|^apkbuild$}i,
      'swift'           => qr{\.swift$}i,
      'toml'            => qr{\.toml$}i,
      'typescript'      => qr{\.ts$}i,
      'typescriptreact' => qr{\.tsx$}i,
      'vim'             => qr{\.n?vim}i,
      'xdefaults'       => qr{^\.Xresources$}i,
      'xml'             => qr{\.(?:atom|opml|rss|xml)$}i,
      'yaml'            => qr{\.(?:yaml|yml)$}i,
      'zsh'             => qr{\.zsh$}i,
    },
  };

  my ( $lang, $fn ) = @_;

  if ( $lang ne q{} ) {
    for my $ft ( sort keys $matchers->{'lang'}->%* ) {
      my $re = $matchers->{'lang'}->{$ft};
      return $ft if $lang =~ $re;
    }
  }

  if ( $fn ne q{} ) {
    for my $ft ( sort keys $matchers->{'fn'}->%* ) {
      my $re = $matchers->{'fn'}->{$ft};
      return $ft if $fn =~ $re;
    }
  }

  return q{};
}

sub compile {
  state $nvimrc ||= $ENV{'HOME'} . '/.config/nvim/highlight.lua';
  my ( $data, $ftfn ) = @_;

  my $ft    = filetype( splitlang($ftfn) );
  my $ftcmd = defined $ft && $ft ne q{} ? "set ft=${ft}" : "filetype detect";

  my $in  = Kalaclista::Path->tempfile;
  my $out = Kalaclista::Path->tempfile;

  utf8::encode($data) if utf8::is_utf8($data);
  $in->emit($data);

  my @cmd = (
    qw(nvim --headless -n), ( -e $nvimrc ? ( '-u', $nvimrc ) : () ),
    qw(-c), "e @{[ $in->path ]} | ${ftcmd} | TOhtml | w! @{[ $out->path ]} | qa!"
  );

  system(@cmd);

  my $html = $out->load;
  $html =~ s{\n+}{\n}g;

  utf8::decode($html);
  return $html;
}

sub parse {
  my $html = shift;

  my $dom   = parser->parse($html);
  my $style = $dom->at('head > style')->innerHTML;
  my $code  = $dom->at('body > pre')->innerHTML;

  $style =~ s{^<!--|-->$}{}gm;
  $style =~ s{^\s*|\s*$}{}gm;
  $style =~ s<(?:pre|body|\*)[^\n]+\n><>g;

  return ( $style, $code );
}

sub doing {
  my $entry  = shift;
  my $prefix = c->entries->parent->child('precompiled');
  my $data   = c->entries->parent->child('code');
  my $dom    = parser->parse( $prefix->child($entry)->load )->at('body');

  my $idx = 1;
  for my $el ( $dom->find('pre > code[class]')->@* ) {
    my $code = $el->textContent;
    my $lang = $el->getAttribute('class');

    my ( $style, $highlight ) = parse( compile( $code, $lang ) );
    my $path = $entry;
    $path =~ s|\.md$|/${idx}.yml|;

    my $yaml = YAML::XS::Dump( { style => $style, highlight => $highlight } );
    my $item = $data->child($path);
    $item->parent->mkpath;

    $item->emit($yaml);

    $idx++;
  }

  return 0;
}

sub testing {
  subtest splitlang => sub {
    my $cases = [
      ## filetype with filename
      [ 'language-perl:test.pl',          [ 'perl', 'test.pl' ] ],
      [ 'language-perl:/path/to/test.pl', [ 'perl', 'test.pl' ] ],

      ## filename
      [ 'language-test.pl',          [ '', 'test.pl' ] ],
      [ 'language-/path/to/test.pl', [ '', 'test.pl' ] ],

      ## filetype
      [ 'language-perl', [ 'perl', '' ] ],

      ## workaround
      [ 'language-(perl:test.pl)',          [ 'perl', 'test.pl' ] ],
      [ 'language-(perl:/path/to/test.pl)', [ 'perl', 'test.pl' ] ],
      [ 'language-(test.pl)',               [ '',     'test.pl' ] ],
      [ 'language-(/path/to/test.pl)',      [ '',     'test.pl' ] ],
      [ 'language-(perl)',                  [ 'perl', '' ] ],
    ];

    for my $test ( $cases->@* ) {
      subtest $test->[0] => sub {
        is [ splitlang( $test->[0] ) ], $test->[1];
      };
    }
  };

  subtest filetype => sub {
    my $cases = [
      [ 'language-perl:test.pl',     'perl' ],
      [ 'language-test.pl',          'perl' ],
      [ 'language-/path/to/test.pl', 'perl' ],
      [ 'language-perl',             'perl' ],
    ];

    for my $test ( $cases->@* ) {
      subtest $test->[0] => sub {
        is filetype( splitlang( $test->[0] ) ), $test->[1];
      };
    }
  };

  my $code = <<'...';
#!/usr/bin/env

use strict;
use warnings;
use utf8;

print "こんにちは！こんにちは！\n";
...

  subtest compile => sub {
    my $cases = [
      'language-perl',
      'language-test.pl',
      'language-/path/to/perl.pl',
      'language-perl',
    ];

    for my $case ( $cases->@* ) {
      my $out = compile( $code, $case );

      subtest $case => sub {
        like $out, qr{<html>};
        like $out, qr{content="perl"};
      };
    }
  };

  subtest parse => sub {
    my $html = compile( $code, 'test.pl' );

    my ( $style, $highlight ) = parse($html);

    ok $style ne q{};
    like $highlight, qr{class="Statement"};
  };

  subtest doing => sub {
    my $path  = c->production ? 'notes/ChromeOS-on-MacbookAirMid2011' : 'posts/2023/01/01/000000';
    my $entry = "${path}.md";
    my $done  = lives {
      doing($entry);

      my $data = c->entries->parent->child('code')->child("${path}/1.yml")->path;

      ok -e $data;
    };

    ok $done;
  };

  done_testing;

  return 0;
}

sub main {
  exit( !exists $ENV{'HARNESS_ACTIVE'} ? doing(@_) : testing );
}

main(@ARGV);
