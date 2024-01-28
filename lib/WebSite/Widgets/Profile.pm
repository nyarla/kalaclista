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

  return a( { href => $href, class => classes(@classes) }, $label );
}

sub profile {
  state $profile ||= address(
    {
      class =>
          join( q{ }, classes(qw(h-card)), apply('frame'), custom(q|text-center bg-bright sm:text-left not-italic my-16 px-4 py-2|) )
    },
    p(
      a(
        { href => href('/nyarla/'), class => classes(qw(u-url)) },
        img(
          {
            src    => href('/assets/avatar.svg'),
            height => 96,
            width  => 96,
            alt    => '',
            class  => join( q{ }, classes(qw(u-logo)), custom(q|block mx-auto sm:float-left sm:ml-2 sm:mr-6|) ),
          },
          span( { class => classes(qw(p-nickname)) }, 'にゃるら（カラクリスタ）' ),
        ),
      )
    ),
    nav(
      { class => join( q{ }, classes(qw(p-note)), custom(q|my-4 sm:my-3|) ) },
      p( { class => custom(q|block sm:mb-2 sm:ml-32|) }, "『輝かしい青春』なんて失かった人。", br( { class => custom(q|sm:hidden|) } ), "次に備えて準備中。" ),
      p( { class => custom(q|block sm:mb-2 sm:ml-32|) }, "今は趣味でプログラミングをして",   br( { class => custom(q|sm:hidden|) } ), "生活しています。" ),
      ul(
        { class => custom(q|my-4 sm:ml-32 sm:my-3|) },
        li(
          { class => custom(q|mb-4 sm:mb-0 sm:inline sm:mr-3|) },
          hlink( Email => 'mailto:nyarla@kalaclista.com', qw(u-email) ),
        ),
        li(
          { class => custom(q|mb-4 sm:mb-0 sm:inline sm:mr-3|) },
          hlink( GoToSocial => 'https://kalaclista.com/@nyarla', qw(u-url) ),
        ),
        li(
          { class => custom(q|mb-4 sm:mb-0 sm:inline|) },
          hlink( 'Misskey.io' => 'https://misskey.io/@nyarla', qw(u-url) ),
        ),
      ),
      ul(
        { class => custom(q|my-4 sm:ml-32 sm:my-3|) },
        li(
          { class => custom(q|mb-4 sm:mb-0 sm:inline sm:mr-3|) },
          hlink( GitHub => 'https://github.com/nyarla/', qw(u-url) ),
        ),
        li(
          { class => custom(q|mb-4 sm:mb-4 sm:inline sm:mr-3|) },
          hlink( Zenn => 'https://zenn.dev/nyarla/', qw(u-url) ),
        ),
        li(
          { class => custom(q|mb-4 sm:mb-4 sm:inline sm:mr-3|) },
          hlink( 'しずかなインターネット' => 'https://sizu.me/nyarla/', qw(u-url) ),
        ),
        li(
          { class => custom(q|mb-4 sm:mb-4 sm:inline|) },
          hlink( note => 'https://note.com/kalaclista/', qw(u-url) ),
        ),
      ),
    ),
  );

  return $profile;
}

1;
