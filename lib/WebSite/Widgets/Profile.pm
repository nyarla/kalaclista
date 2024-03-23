package WebSite::Widgets::Profile;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(profile);

use Kalaclista::HyperScript qw(section figure figcaption section nav p a wbr br img classes);

use WebSite::Context;
use WebSite::Context::URI qw(href);

sub profile {
  state $profile ||= section(
    { id => 'profile' },
    classes(qw|card-rounded text-center sm:text-left|),
    figure(
      p(
        classes(qw|float-none text-center mb-4 sm:float-left sm:text-left sm:mr-4|),
        a(
          { href => href('/nyarla/')->to_string },
          img(
            classes(qw|inline-block dark:bg-gray-light dark:rounded-2xl|),
            {
              src    => href('/assets/avatar.svg')->to_string,
              height => 96, width => 96,
              alt    => 'アバターアイコン兼ロゴ'
            }
          )
        )
      ),
      figcaption( a( { href => href('/nyarla/')->to_string }, 'にゃるら（カラクリスタ）' ) )
    ),

    section(
      { class => 'entry__content' },
      p( '『輝かしい青春』なんて失かった人。', br( classes(qw|sm:hidden|) ), '次に備えて待機中。' ),
      p( '今は趣味でプログラミングをして',   br( classes(qw|sm:hidden|) ), '生活しています。' ),
    ),

    nav(
      p(
        a( classes(qw|mr-2|), { href => 'https://github.com/nyarla/' }, 'GitHub' ),
        wbr,
        a( classes(qw|mr-2|), { href => 'https://zenn.dev/nyarla' }, 'Zenn' ),
        wbr,
        a( classes(qw|mr-2|), { href => 'https://kalaclista.com/@nyarla' }, 'GoToSocial' ),
        wbr,
        a( classes(qw|mr-2|), { href => 'https://misskey.io/@nyarla' }, 'Misskey.io' ),
      )
    )
  );
}

1;
