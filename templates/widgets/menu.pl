my $search =
  'https://cse.google.com/cse?cx=018101178788962105892:toz3mvb2bhr#gsc.tab=0';

my $menu = sub {
  my $vars    = shift;
  my $baseURI = shift;

  my $href =
    sub { my $link = $baseURI->clone; $link->path( $_[0] ); $link->as_string };

  return nav(
    { id => 'menu', class => 'entry__content' },
    hr(),
    p(
      { class => 'kind' },
      a( { href => $href->('/posts/') }, 'ブログ' ),
      a( { href => $href->('/echos/') }, '日記' ),
      a( { href => $href->('/notes/') }, 'メモ帳' ),
    ),
    p(
      { class => 'links' },
      a( { href => $href->('/policies/') }, '運営方針' ),
      a( { href => $href->('/licenses/') }, '権利情報' ),
      a( { href => $search },               '検索' ),
    ),
  );
};

$menu;
