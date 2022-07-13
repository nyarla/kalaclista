my $search =
  'https://cse.google.com/cse?cx=018101178788962105892:toz3mvb2bhr#gsc.tab=0';

my $menu = sub {
  my $baseURI = shift;

  return nav(
    { id => 'menu', class => 'entry__content' },
    hr(),
    p(
      { class => 'kind' },
      a( { href => href( '/posts/', $baseURI ) }, 'ブログ' ),
      a( { href => href( '/echos/', $baseURI ) }, '日記' ),
      a( { href => href( '/notes/', $baseURI ) }, 'メモ帳' ),
    ),
    p(
      { class => 'links' },
      a( { href => href( '/policies/', $baseURI ) }, '運営方針' ),
      a( { href => href( '/licenses/', $baseURI ) }, '権利情報' ),
      a( { href => $search }, '検索' ),
    ),
  );
};

$menu;
