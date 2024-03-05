package WebSite::Context::Path;

use v5.38;
use utf8;

use feature qw(state);

use Exporter::Lite;

use Kalaclista::Context::Path qr{^(?:t|bin)$};

use WebSite::Context::Environment;

our @EXPORT = qw( rootdir distdir cachedir srcdir);

sub distdir {
  state $dir ||=
        env->production  ? rootdir->child('dist/production')
      : env->development ? rootdir->child('dist/development')
      : env->staging     ? rootdir->child('dist/staging')
      :                    rootdir->child('dist/test');

  return $dir;
}

sub cachedir {
  state $dir ||=
        env->production  ? rootdir->child('cache/production')
      : env->development ? rootdir->child('cache/development')
      : env->staging     ? rootdir->child('cache/staging')
      :                    rootdir->child('cache/test');

  return $dir;
}

sub srcdir {
  state $dir ||=
       !env->test
      ? rootdir->child('src')
      : rootdir->child('t/fixtures');

  return $dir;
}

1;
