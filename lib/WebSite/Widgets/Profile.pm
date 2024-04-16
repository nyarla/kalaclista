package WebSite::Widgets::Profile;

use v5.38;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(profile);

use Kalaclista::HyperScript qw(section figure figcaption nav p a wbr br img classes);

use WebSite::Context::URI qw(href);

sub profile {
  state $profile ||= section(
    { id => 'profile' },
    classes( q|h-card vcard|, qw|card-rounded text-center sm:text-left| ),
    figure(
      p(
        classes(qw|float-none text-center mb-4 sm:float-left sm:text-left sm:mr-4|),
        a(
          { href => href('/nyarla/')->to_string },
          img(
            classes( q|u-logo logo|, qw|inline-block dark:bg-gray-light dark:rounded-2xl| ),
            {
              src    => href('/assets/avatar.svg')->to_string,
              height => 96, width => 96, alt => ''
            }
          )
        )
      ),
      figcaption( a( classes(q|p-nickname u-url|), { href => href('/nyarla/')->to_string }, 'にゃるら（カラクリスタ）' ) )
    ),

    section(
      classes( q|p-note note|, qw|ms:ml-28| ),
      p( classes(qw|my-2|), '『輝かしい青春』なんて失かった人。', br( classes(qw|sm:hidden|) ), '次に備えて待機中。' ),
      p( classes(qw|my-2|), '今は趣味でプログラミングをして',   br( classes(qw|sm:hidden|) ), '生活しています。' ),
    ),

    nav(
      classes(qw|sm:ml-28 [&>p>a]:inline-block [&>p>a]:mb-2 [&>p>a]:mr-3 [&>p>a]:text-nowrap|),
      p(
        classes(qw|h-listing|),
        a( classes(q|u-url url p-name fn|), { href => 'https://github.com/nyarla/' }, 'GitHub' ),
        wbr,
        a( classes(q|u-url url p-name fn|), { href => 'https://zenn.dev/nyarla' }, 'Zenn' ),
        wbr,
        a( classes(q|u-url url p-name fn|), { href => 'https://note.com/kalaclista/' }, 'note' ),
        wbr,
        a( classes(q|u-url url p-name fn|), { href => 'https://sizu.me/nyarla' }, 'しずかなインターネット' ),
      ),
      p(
        classes(qw|h-listing|),
        a( classes(q|u-url url p-name fn|), { href => 'https://kalaclista.com/@nyarla' }, 'GoToSocial' ),
        wbr,
        a( classes(q|u-url url p-name fn|), { href => 'https://misskey.io/@nyarla' }, 'Misskey.io' ),
        wbr,
        a(
          classes(q|u-url url p-name fn|), { href => 'https://bsky.app/profile/kalaclista.com' },
          'Bluesky'
        ),
        wbr,
        a(
          classes(q|u-url url p-name fn|), { href => 'https://www.threads.net/@kalaclista' },
          'threads.net'
        ),
      ),
    )
  );

  return $profile;
}

1;
