package WebSite::Widgets::Profile;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(profile);

use Kalaclista::HyperScript qw(section figure figcaption section nav p a wbr img);

use WebSite::Context;
use WebSite::Context::URI qw(href);

sub profile {
  state $profile ||= section(
    { id => 'profile' },
    figure(
      p(
        a(
          { href => href('/nyarla/')->to_string },
          img(
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
      p('『輝かしい青春』なんて失かった人。次に備えて待機中。'),
      p('今は趣味でプログラミングをして生活しています。'),
    ),

    nav(
      p(
        a( { href => 'https://github.com/nyarla/' }, 'GitHub' ),
        wbr,
        a( { href => 'https://zenn.dev/nyarla' }, 'Zenn' ),
        wbr,
        a( { href => 'https://kalaclista.com/@nyarla' }, 'GoToSocial' ),
        wbr,
        a( { href => 'https://misskey.io/@nyarla' }, 'Misskey.io' ),
      )
    )
  );
}

1;
