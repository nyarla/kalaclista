#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;

use Kalaclista::Loader::Files qw(files);
use Kalaclista::Path;

use WebSite::Context::Path qw(srcdir);

use WebSite::Worker::Markdown qw(compile worker queues should_update);

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

subtest worker => sub {
  my $src      = Kalaclista::Path->tempfile;
  my $dest     = Kalaclista::Path->tempfile;
  my $markdown = <<'...';
---
title: hello
---

hello, world!
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

  $result = worker($job);

  ok $job->{'skip'} > 0, 'The worker skipped if `dest` is newer than `src`';
};

subtest queues => sub {
  my $srcdir  = srcdir->child('entries/src')->path;
  my $destdir = srcdir->child('entries/precompiled')->path;

  my @srcs  = sort { $a cmp $b } files $srcdir;
  my @dests = sort { $a cmp $b } files $destdir;
  my @msgs  = sort { $a cmp $b } map { s<${srcdir}><>; $_ } files $srcdir;

  my @queues = queues;

  is 0+ @queues, 0+ @srcs, 'Job queues should be a same length of Markdown files';

  is $queues[0]->{'src'},  $srcs[0],  'The first job has right source';
  is $queues[-1]->{'src'}, $srcs[-1], 'The last job hsa right source';

  is $queues[0]->{'dest'},  $dests[0],  'The first job has right destination path';
  is $queues[-1]->{'dest'}, $dests[-1], 'The last job has right destination path';

  is $queues[0]->{'msg'},  $msgs[0],  'The first job has right msg path';
  is $queues[-1]->{'msg'}, $msgs[-1], 'The last job has right msg path';
};

done_testing;
