my $profile = sub {
  my $vars    = shift;
  my $baseURI = shift;
  my $dir     = shift;

  my $href =
    sub { my $link = $baseURI->clone; $link->path( $_[0] ); $link->as_string };

  return section(
    { id => 'profile' },
    figure(
      p(
        a(
          { href => $href->('/nyarla/') },
          img(
            { src => $href->('/assets/avatar.svg'), height => 96, width => 96 }
          )
        )
      ),
      figcaption( a( { href => $href->('/nyarla/') }, 'にゃるら（カラクリスタ）' ) )
    ),
    section(
      { class => 'entry__content' }, p('『輝かしい青春』なんて失かった人。病気療養中の家事手伝い'),
      p('今は時々ブログを書いたりプログラミングをして生活しています。'),
    ),
    nav(
      p(
        a( { href => 'https://github.com/nyarla/' },       'GitHub' ),
        a( { href => 'https://zenn.dev/nyarla' },          'Zenn.dev' ),
        a( { href => 'https://lapras.com/public/nyarla' }, 'Lapras' ),
        a( { href => 'https://note.com/kalaclista/' },     'note' ),
        a( { href => 'https://twitter.com/kalaclista' },   'Twitter' ),
        a( { href => 'https://user.topia.tv/5R9Y' },       'トピア' )
      )
    )
  );
};

$profile;
