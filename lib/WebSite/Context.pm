use v5.38;
use utf8;
use builtin qw(true false);
use feature qw(class state);
no warnings qw(experimental);

use URI::Fast;

use Kalaclista::Context;
use Kalaclista::Data::Directory;
use Kalaclista::Data::WebSite;

class WebSite::Context : isa(Kalaclista::Context) {

  sub init {
    my $class  = shift;
    my $detect = shift;

    my $stage = exists $ENV{'KALACLISTA_ENV'} ? $ENV{'KALACLISTA_ENV'} : exists $ENV{'HARNESS_ACTIVE'} ? 'test'  : 'development';
    my $on    = exists $ENV{'CI'}             ? 'ci'                   : exists $ENV{'IN_PERL_SHELL'}  ? 'local' : 'runtime';
    my $env   = Kalaclista::Context::Environment->new(
      stage => $stage,
      on    => $on,
    );

    my $baseURI =
          $env->production ? 'https://the.kalaclista.com'
        : $env->test       ? 'https://example.com'
        :                    'http://nixos:1313';

    my $cache =
          $env->production  ? 'cache/production'
        : $env->staging     ? 'cache/staging'
        : $env->development ? 'cache/development'
        : $env->test        ? 'cache/test'
        :                     'test';

    my $dist =
          $env->production  ? q{public/production}
        : $env->staging     ? q{public/staging}
        : $env->development ? q{public/development}
        :                     q{public/test};

    my $src = ( !$env->test ) ? q{src} : q{t/fixtures};

    my $href = URI::Fast->new($baseURI);
    my sub href {
      my $new = $href->clone;
      $new->path(shift);
      return $new;
    }

    my $website = Kalaclista::Data::WebSite->new(
      label   => 'カラクリスタ',
      title   => 'カラクリスタ',
      summary => '『輝かしい青春』なんて失かった人の Web サイトです',
      href    => href(''),
    );

    my $sections = {
      posts => Kalaclista::Data::WebSite->new(
        label   => 'ブログ',
        title   => 'カラクリスタ・ブログ',
        summary => '『輝かしい青春』なんて失かった人のブログです',
        href    => href('/posts/'),
      ),
      echos => Kalaclista::Data::WebSite->new(
        label   => '日記',
        title   => 'カラクリスタ・エコーズ',
        summary => '『輝かしい青春』なんて失かった人の日記です',
        href    => href('/echos/'),
      ),
      notes => Kalaclista::Data::WebSite->new(
        label   => 'メモ帳',
        title   => 'カラクリスタ・ノート',
        summary => '『輝かしい青春』なんて失かった人のメモ帳です',
        href    => href('/notes/'),
      ),
    };

    my $c = WebSite::Context->new(
      env     => $env,
      baseURI => URI::Fast->new($baseURI),
      dirs    => Kalaclista::Data::Directory->instance(
        detect => $detect,
        cache  => $cache,
        dist   => $dist,
        src    => $src,
      ),
      website  => $website,
      sections => $sections,
    );

    $class->instance($c);
    return $class->instance;
  }

  method production {
    return $self->env->production;
  }

  method staging {
    return $self->env->staging;
  }

  method development {
    return $self->env->development;
  }

  method test {
    return $self->env->test;
  }

  method cache {
    my $path = shift;
    return $self->dirs->cache($path);
  }

  method data {
    my $path = shift;
    return $self->dirs->src('data')->child($path);
  }

  method deps {
    my $path = shift;
    return $self->dirs->rootdir->child('deps')->child($path);
  }

  method dist {
    my $path = shift;
    return $self->dirs->dist($path);
  }

  method entries {
    return $self->dirs->src('entries/src');
  }

  method src {
    my $path = shift;
    return $self->dirs->src($path);
  }
}
