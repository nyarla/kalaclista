#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;

use WebSite::Helper::NeoVimColor qw(ftdetect detect render parse);

subtest ftdetect => sub {
  subtest 'by lang' => sub {
    my $lang = ftdetect 'js', '';
    is $lang, 'javascript', 'The language detected by language name';
  };

  subtest 'by filename' => sub {
    my $lang = ftdetect '', 'script.pl';
    is $lang, 'perl', 'The language detected by filename';
  };

  subtest 'by lang or filename' => sub {
    my $lang = ftdetect 'js', 'script.jsx';
    is $lang, 'javascript', 'The detected language is `javascript`';

    $lang = ftdetect 'jscript', 'script.js';
    is $lang, 'javascript', 'The detect language is `javascript`';

    $lang = ftdetect q{}, q{};
    is $lang, q{}, 'In this case, `ftdetect` cannot detect any language';
  };
};

subtest detect => sub {
  subtest 'without fix' => sub {
    my $lang = 'language-perl:script.pl';
    my ( $ft, $fn ) = detect $lang;

    is $ft, 'perl',      'The detected language is perl';
    is $fn, 'script.pl', 'The detected filename is `script.pl`';
  };

  subtest 'with fix' => sub {
    my $lang = 'language-(perl)';
    my ( $ft, undef ) = detect $lang;

    is $ft, 'perl', 'The detect language is perl';

    $lang = 'script.pl';
    my ( undef, $fn ) = detect $lang;

    is $fn, 'script.pl', 'The detected filename is `script.pl`';
  };
};

subtest 'render and parse' => sub {
  my $code = <<'...';
#!/usr/bin/env perl

use strict;
use warnings;

print "hello, world!\n";

exit 0;
...

  my $lang = 'language-perl:script.pl';

  subtest render => sub {
    my $html = render $code, $lang;
    ok $html, 'The `render` function could be rendering code.';
  };

  subtest parse => sub {
    my $html = render $code, $lang;
    my ( $code, $style ) = parse $html;

    ok $code,  'The `parse` function can extract highlighted code from html';
    ok $style, 'The `parse` function can extract highlighted style from html';
  };
};

done_testing;
