package WebSite::Widgets::Profile;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(profile);

use Text::HyperScript::HTML5;
use WebSite::Helper::Hyperlink qw(href hyperlink);

sub profile {
  my $baseURI = shift;
  state $result ||= section(
    { id => 'profile' },

    figure(
      p(
        a(
          { href => href( '/nyarla/', $baseURI ) },
          img(
            {
              src    => href( '/assets/avatar.svg', $baseURI ),
              height => 96,
              width  => 96,
            }
          )
        )
      ),
      figcaption( a( { href => href( '/nyarla/', $baseURI ) }, 'にゃるら（カラクリスタ）' ) )
    ),

    section(
      { class => 'entry__content' },
      p('『輝かしい青春』なんて失かった人。うつ病を抱えつつアルバイト中。'),
      p('今は業務や趣味でプログラミングをして生活しています。'),
    ),

    nav(
      p(
        hyperlink( 'GitHub',  'https://github.com/nyarla/' ),
        hyperlink( 'Zenn',    'https://zenn.dev/nyarla' ),
        hyperlink( 'Twitter', 'https://twitter.com/kalaclista' ),
        hyperlink( 'トピア',     'https://user.topia.tv/5R9Y' ),
      )
    )
  );

  return $result;
}

1;
