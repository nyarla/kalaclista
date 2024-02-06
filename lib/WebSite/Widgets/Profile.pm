package WebSite::Widgets::Profile;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(profile);

use Kalaclista::HyperScript qw(address nav p a img span ul li br);

use WebSite::Context;
use WebSite::Helper::TailwindCSS;

sub c { state $c ||= WebSite::Context->instance; $c }

sub href {
  my $path = shift;
  my $href = c->baseURI->clone;
  $href->path($path);

  return $href->to_string;
}

sub hlink {
  my $label   = shift;
  my $href    = shift;
  my @classes = shift;

  return a( classes(@classes), { href => $href }, $label );
}

sub profile {
  state $profile ||= address(
    classes( qw(h-card), q|card-frame text-center bg-bright sm:text-left not-italic my-16 px-4 py-2| ),
    p(
      a(
        classes(qw(u-url)),
        { href => href('/nyarla/') },
        img(
          classes( qw(u-logo), q|block mx-auto sm:float-left sm:ml-2 sm:mr-6| ),
          {
            src    => href('/assets/avatar.svg'),
            height => 96,
            width  => 96,
            alt    => '',
          }
        ),
        span( classes(qw(p-nickname)), 'にゃるら（カラクリスタ）' ),
      ),
    ),
    nav(
      classes( qw(p-note), q|my-4 sm:my-3| ),
      p( classes(q|block sm:mb-2 sm:ml-32|), '『輝かしい青春』なんて失かった人。', br( classes(q|sm:hidden|) ), '次に備えて準備中。' ),
      p( classes(q|block sm:mb-2 sm:ml-32|), "今は趣味でプログラミングをして",   br( classes(q|sm:hidden|) ), "生活しています。" ),
      ul(
        classes(q|my-4 sm:ml-32 sm:my-3|),
        li( classes(q|mb-4 sm:mb-0 sm:inline sm:mr-3|), hlink( Email        => 'mailto:nyarla@kalaclista.com',   qw(u-email) ) ),
        li( classes(q|mb-4 sm:mb-0 sm:inline sm:mr-3|), hlink( GoToSocial   => 'https://kalaclista.com/@nyarla', qw(u-url) ) ),
        li( classes(q|mb-4 sm:mb-0 sm:inline|),         hlink( 'Misskey.io' => 'https://misskey.io/@nyarla',     qw(u-url) ) ),
      ),
      ul(
        classes(q|my-4 sm:ml-32 sm:my-3|),
        li( classes(q|mb-4 sm:mb-0 sm:inline sm:mr-3|), hlink( GitHub        => 'https://github.com/nyarla/',   qw(u-url) ) ),
        li( classes(q|mb-4 sm:mb-0 sm:inline sm:mr-3|), hlink( Zenn          => 'https://zenn.dev/nyarla/',     qw(u-url) ) ),
        li( classes(q|mb-4 sm:mb-0 sm:inline sm:mr-3|), hlink( 'しずかなインターネット' => 'https://sizu.me/nyarla/',      qw(u-url) ) ),
        li( classes(q|mb-4 sm:mb-0 sm:inline sm:mr-3|), hlink( note          => 'https://note.com/kalaclista/', qw(u-url) ) ),
      ),
    ),
  );

  return $profile;
}

1;
