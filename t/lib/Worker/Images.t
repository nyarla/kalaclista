#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;

use YAML::XS qw(Load);

use Kalaclista::Path;

use WebSite::Context::Path qw(srcdir distdir cachedir);

use WebSite::Worker::Images qw(copy size resize should_update worker queues);

subtest copy => sub {
  my $src  = Kalaclista::Path->tempfile;
  my $dest = Kalaclista::Path->tempdir;

  my $dist = $dest->child('foo/bar/baz');

  $src->emit('hello');

  copy $src->path, $dist->path;

  ok -e $dist->path, 'The file copy succeed';
  is $dist->load, 'hello', 'Copied file has same content as `$src`';
};

subtest size => sub {
  my $src = srcdir->child('images/foo/bar/1.png');

  ok -e $src->path, 'The test file exists';

  my ( $width, $height ) = size $src->path;

  is $width,  2048, 'The `size` function is enable to getting image width';
  is $height, 2048, 'The `size` function is enable to getting image height';
};

subtest resize => sub {
  my $src = srcdir->child('images/foo/bar/1.png');

  subtest 'should apply resize' => sub {
    my $dest = Kalaclista::Path->tempfile;
    my $size = 256;

    my $height = resize $src->path, $dest->path, $size;

    ok -e $dest->path, 'The resized file exists';
    is $height, 256, 'The image heightscaled with width';
  };

  subtest 'should not apply resize' => sub {
    my $dest = Kalaclista::Path->tempfile;
    my $size = 10280;

    my $height = resize $src->path, $dest->path, $size;

    ok -e $dest->path, 'The specific file exists';
    is $height, 2048, 'The image conveted by `cwebp`, but image size did not change';
  };
};

# FIXME: this file copied from t/lib/Worker/Markdown.t
# So we should split this utility function to another module.
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
  subtest gif => sub {
    my $src  = srcdir->child('images/foo/bar/2.gif');
    my $dest = Kalaclista::Path->tempdir->child('2.gif');
    my $data = Kalaclista::Path->tempfile->child('2.yaml');
    my $job  = {
      src   => $src->path,
      dest  => $dest->path,
      data  => $data->path,
      sizes => [ 256, 512 ],
    };

    my $result = worker($job);

    ok -e $dest->parent->child('2_1x.gif')->path, 'The gif file copied to `$dest`';
    ok -e $dest->parent->child('2_2x.gif')->path, 'The gif file copied to `$dest`';
    ok -e $data->path,                            'The metadata file exists';

    is Load( $data->load ), {
      '1x' => {
        width  => 256,
        height => 256,
      },
      '2x' => {
        width  => 256,
        height => 256,
      },
      'gif' => {
        width  => 256,
        height => 256,
      },
        },
        'The metadata described to data of gif';
  };

  subtest supported => sub {
    my $src  = srcdir->child('images/foo/bar/1.png');
    my $dest = Kalaclista::Path->tempdir->child('1.png');
    my $data = Kalaclista::Path->tempdir->child('1.yaml');
    my $job  = {
      src   => $src->path,
      dest  => $dest->path,
      data  => $data->path,
      sizes => [ 256, 512 ],
    };

    my $result = worker($job);

    ok -e $dest->parent->child('1_1x.webp')->path, 'The gif file copied to `$dest`';
    ok -e $dest->parent->child('1_2x.webp')->path, 'The gif file copied to `$dest`';
    ok -e $data->path,                             'The metadata file exists';

    is Load( $data->load ), {
      '1x' => {
        width  => 256,
        height => 256,
      },
      '2x' => {
        width  => 512,
        height => 512,
      },
        },
        'The metadata described to data of gif';
  };
};

subtest queues => sub {
  my $sizes  = [ 256, 512 ];
  my @queues = queues($sizes);

  my $srcdir  = srcdir->child('images');
  my $destdir = distdir->child('images');
  my $datadir = cachedir->child('images');

  is [@queues], +[
    {
      src   => $srcdir->child('foo/bar/1.png')->path,
      dest  => $destdir->child('foo/bar/1.png')->path,
      msg   => 'images/foo/bar/1.png',
      data  => $datadir->child('foo/bar/1.yaml')->path,
      sizes => [ 256, 512 ],
    },
    {
      src   => $srcdir->child('foo/bar/2.gif')->path,
      dest  => $destdir->child('foo/bar/2.gif')->path,
      msg   => 'images/foo/bar/2.gif',
      data  => $datadir->child('foo/bar/2.yaml')->path,
      sizes => [ 256, 512 ],
    }
      ],
      'The queues for images has valid data.';
};

done_testing;
