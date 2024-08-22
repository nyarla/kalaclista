#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;

use Kalaclista::Loader::Files qw(files);
use Kalaclista::Path;

use WebSite::Context::Path qw(srcdir);

use WebSite::Worker::Markdown qw(compile worker queues should_update highlight);

subtest compile => sub {
  my $markdown = <<'...';
# title

hello, world!
...

  my $html = <<'...';
<h1>title</h1>
<p>hello, world!</p>
...

  is compile $markdown, $html, 'The output should be a html text';
};

subtest should_update => sub {
  my $src  = Kalaclista::Path->tempfile;
  my $dest = Kalaclista::Path->tempfile;

  subtest '$dest does not exists' => sub {
    $dest->remove;
    ok should_update( $src->path, $dest->path ), 'This case should be returns true';
  };

  subtest '$dest is newer than $src' => sub {
    $dest->emit('');
    utime time + 1, time + 1, $dest->path;

    ok !should_update( $src->path, $dest->path ), 'This case should be returns false';
  };

  subtest '$dest is older thant $src' => sub {
    utime time + 2, time + 2, $src->path;

    ok should_update( $src->path, $dest->path ), 'This case should be returns true';
  };
};

subtest highlight => sub {
  my $html = '<pre><code class="language-bash">$ echo hello, world</code></pre>';
  my $dir  = Kalaclista::Path->tempdir;

  my $codes = highlight $html, $dir->path;

  is $codes, 1, 'The html has 1 highlight code';
  ok -e $dir->child('1.yml')->path, 'The highlight file exists';
};

subtest worker => sub {
  my $src      = Kalaclista::Path->tempfile;
  my $dest     = Kalaclista::Path->tempfile;
  my $markdown = <<'...';
---
title: hello
---

hello, world!

```bash
$ echo hello, world
```
...
  $dest->remove;

  $src->emit($markdown);

  my $job = {
    src  => $src->path,
    dest => $dest->path,
    msg  => 'test',
  };

  my $result = worker($job);

  ok $job->{'done'} > 0, 'The worker process is done';
  ok -e $dest->path,     'The proceed file is exists';
  is $job->{'codes'}, 1, 'The markdwon file includes 1 code block';

  $result = worker($job);

  ok $job->{'skip'} > 0, 'The worker skipped if `dest` is newer than `src`';
};

subtest queues => sub {
  my $srcdir  = srcdir->child('entries/src')->path;
  my $destdir = srcdir->child('entries/precompiled')->path;
  my $codedir = srcdir->child('entries/code')->path;

  for my $job (queues) {
    subtest $job->{'msg'} => sub {
      ok exists $job->{'msg'},  'The job has `msg` field for logging';
      ok exists $job->{'src'},  'The job has path to a `src` file';
      ok exists $job->{'dest'}, 'The job has path to a `dest` file';
      ok exists $job->{'code'}, 'The job has path to a `code` directory';
      is $job->{'codes'}, 0, 'The count to code blocks is zero';

      like $job->{'src'},  qr<^${srcdir}>,  'The `src` field begin with `$srcdir`';
      like $job->{'dest'}, qr<^${destdir}>, 'The `dest` field begin with `$destdir`';
      like $job->{'code'}, qr<^${codedir}>, 'The `code` field begin with `$codedir`';
    }
  }
};

done_testing;
