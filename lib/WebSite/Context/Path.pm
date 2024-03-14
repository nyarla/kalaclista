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
        env->production  ? rootdir->child('public/production')
      : env->development ? rootdir->child('public/development')
      : env->staging     ? rootdir->child('public/staging')
      :                    rootdir->child('public/test');

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
